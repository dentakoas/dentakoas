import { PrismaClient } from '@prisma/client';
import { faker } from '@faker-js/faker';
import { addDays, format, addWeeks, subDays } from 'date-fns';
import {
  ScheduleWithRelations,
  PostWithRelations,
  TimeslotData,
} from '../types/seeding';

export const seedSchedules = async (
  prisma: PrismaClient,
  posts: PostWithRelations[]
): Promise<ScheduleWithRelations[]> => {
  // Clean up existing data
  await prisma.schedule.deleteMany({});
  await prisma.timeslot.deleteMany({});

  const schedules: ScheduleWithRelations[] = [];
  const now = new Date();
  const publishedPosts = posts.filter((post) => post.published === true);

  console.log(
    `Creating schedules for ${publishedPosts.length} published posts`
  );

  // Common time slots patterns
  const timeSlotPatterns = [
    // Morning, Afternoon, Evening pattern
    [
      { start: '06:00', end: '09:00' },
      { start: '12:00', end: '15:00' },
      { start: '18:00', end: '21:00' },
    ],
    // Morning and Afternoon pattern
    [
      { start: '08:00', end: '11:00' },
      { start: '13:00', end: '16:00' },
    ],
    // Full day pattern
    [
      { start: '09:00', end: '12:00' },
      { start: '14:00', end: '17:00' },
      { start: '19:00', end: '21:00' },
    ],
  ];

  for (const post of publishedPosts) {
    try {
      // Number of schedules per post (1-2)
      const numSchedules = faker.helpers.rangeToNumber({ min: 1, max: 2 });

      const postSchedules = [];

      for (let i = 0; i < numSchedules; i++) {
        // Schedule start date logic
        let scheduleStartDate: Date;
        let scheduleEndDate: Date;

        const scheduleType = faker.helpers.weightedArrayElement([
          { value: 'past', weight: 20 },
          { value: 'current', weight: 40 },
          { value: 'future', weight: 40 },
        ]);

        if (scheduleType === 'past') {
          // Past schedule (20-60 days ago)
          const daysAgo = faker.helpers.rangeToNumber({ min: 20, max: 60 });
          scheduleStartDate = subDays(now, daysAgo);
          scheduleEndDate = addDays(
            scheduleStartDate,
            faker.helpers.rangeToNumber({ min: 2, max: 5 })
          );
        } else if (scheduleType === 'current') {
          // Current schedule (started recently, ends in near future)
          const daysAgo = faker.helpers.rangeToNumber({ min: 1, max: 3 });
          scheduleStartDate = subDays(now, daysAgo);
          scheduleEndDate = addDays(
            now,
            faker.helpers.rangeToNumber({ min: 2, max: 7 })
          );
        } else {
          // Future schedule (starting soon)
          const daysAhead = faker.helpers.rangeToNumber({ min: 1, max: 14 });
          scheduleStartDate = addDays(now, daysAhead);
          scheduleEndDate = addDays(
            scheduleStartDate,
            faker.helpers.rangeToNumber({ min: 2, max: 5 })
          );
        }

        // Create the schedule
        const schedule = await prisma.schedule.create({
          data: {
            postId: post.id,
            dateStart: scheduleStartDate,
            dateEnd: scheduleEndDate,
          },
        });

        // Select a time slot pattern
        const selectedPattern = faker.helpers.arrayElement(timeSlotPatterns);
        let totalCurrentParticipants = 0;
        const timeslots: TimeslotData[] = [];

        // Create timeslots for this schedule
        for (const slot of selectedPattern) {
          const maxParticipants = faker.helpers.rangeToNumber({
            min: 1,
            max: 5,
          });

          // For completed or near-completed schedules, add some participants
          let currentParticipants = 0;
          let isAvailable = true;

          if (
            scheduleType === 'past' ||
            (scheduleType === 'current' && post.status === 'Closed')
          ) {
            // For past or closed schedules, potentially fill slots
            currentParticipants = faker.helpers.rangeToNumber({
              min: 0,
              max: maxParticipants,
            });

            // If closed, at least one slot should be full
            if (post.status === 'Closed' && slot === selectedPattern[0]) {
              currentParticipants = maxParticipants;
            }

            isAvailable = currentParticipants < maxParticipants;
          }

          totalCurrentParticipants += currentParticipants;

          const timeslot = await prisma.timeslot.create({
            data: {
              scheduleId: schedule.id,
              startTime: slot.start,
              endTime: slot.end,
              maxParticipants: maxParticipants,
              currentParticipants: currentParticipants,
              isAvailable: isAvailable,
            },
          });

          timeslots.push(timeslot as TimeslotData);
        }

        // Create the enhanced schedule object with timeslots
        const scheduleWithTimeslots: ScheduleWithRelations = {
          ...schedule,
          timeslot: timeslots,
          totalCurrentParticipants,
        };

        schedules.push(scheduleWithTimeslots);
        postSchedules.push(scheduleWithTimeslots);
      }

      // Update the post with its schedules
      if (post.Schedule) {
        post.Schedule = postSchedules;
      } else {
        post.Schedule = postSchedules;
      }

      // If post status is Closed, ensure total participants meets or exceeds requiredParticipant
      if (post.status === 'Closed' && postSchedules.length > 0) {
        const totalParticipantsForPost = postSchedules.reduce(
          (total, schedule) => total + (schedule.totalCurrentParticipants || 0),
          0
        );

        if (totalParticipantsForPost < post.requiredParticipant) {
          // Get first timeslot
          const firstSchedule = postSchedules[0];
          if (
            firstSchedule &&
            firstSchedule.timeslot &&
            firstSchedule.timeslot.length > 0
          ) {
            const firstTimeslot = firstSchedule.timeslot[0];
            const participantsNeeded =
              post.requiredParticipant - totalParticipantsForPost;
            const newParticipantCount =
              firstTimeslot.currentParticipants + participantsNeeded;

            // Update the timeslot
            await prisma.timeslot.update({
              where: { id: firstTimeslot.id },
              data: {
                currentParticipants: newParticipantCount,
                maxParticipants: Math.max(
                  firstTimeslot.maxParticipants || 0,
                  newParticipantCount
                ),
                isAvailable: false,
              },
            });

            // Update our local copy
            firstTimeslot.currentParticipants = newParticipantCount;
            firstTimeslot.isAvailable = false;
            if (firstSchedule.totalCurrentParticipants !== undefined) {
              firstSchedule.totalCurrentParticipants += participantsNeeded;
            }
          }
        }
      }
    } catch (error) {
      console.error(`Error creating schedule for post ${post.id}:`, error);
      console.error(error instanceof Error ? error.message : 'Unknown error');
    }
  }

  console.log(
    `Successfully created ${schedules.length} schedules with timeslots`
  );
  return schedules;
};
