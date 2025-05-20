import { PrismaClient } from '@prisma/client';
import { addDays } from 'date-fns';

export const seedSchedules = async (prisma: PrismaClient, posts: any) => {
  // Clean up existing data
  await prisma.schedule.deleteMany({});

  const schedules = [];
  const now = new Date();

  // Create schedules for each post
  for (const post of posts) {
    // Create a schedule starting from tomorrow to 30 days ahead
    const startDate = addDays(now, 1);
    const endDate = addDays(now, 30);

    const schedule = await prisma.schedule.create({
      data: {
        postId: post.id,
        dateStart: startDate,
        dateEnd: endDate,
        timeslot: {
          create: [
            // Morning slots
            {
              startTime: '08:00',
              endTime: '09:00',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
            {
              startTime: '09:30',
              endTime: '10:30',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
            {
              startTime: '11:00',
              endTime: '12:00',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
            // Afternoon slots
            {
              startTime: '13:00',
              endTime: '14:00',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
            {
              startTime: '14:30',
              endTime: '15:30',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
            {
              startTime: '16:00',
              endTime: '17:00',
              maxParticipants: 2,
              currentParticipants: 0,
              isAvailable: true,
            },
          ],
        },
      },
      include: {
        timeslot: true,
      },
    });

    schedules.push(schedule);
  }

  return schedules;
};
