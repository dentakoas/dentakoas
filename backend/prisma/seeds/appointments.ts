import {
  PrismaClient,
  StatusAppointment,
  StatusNotification,
} from '@prisma/client';
import { addDays, format, subDays } from 'date-fns';
import { faker } from '@faker-js/faker';
import {
  AppointmentData,
  PasienProfileWithUser,
  KoasProfileWithUser,
  PostWithRelations,
  ScheduleWithRelations,
  SlotUsage,
  UserSeedResult,
} from '../types/seeding';

export const seedAppointments = async (
  prisma: PrismaClient,
  users: UserSeedResult,
  schedules: ScheduleWithRelations[]
): Promise<AppointmentData[]> => {
  // Clean up existing data
  await prisma.appointment.deleteMany({});

  // Get all pasien profiles
  const pasienProfiles = (await prisma.pasienProfile.findMany({
    include: { user: true },
  })) as PasienProfileWithUser[];

  // Get all approved koas profiles
  const koasProfiles = (await prisma.koasProfile.findMany({
    where: { status: 'Approved' },
    include: { user: true },
  })) as KoasProfileWithUser[];

  // Get all posts with their associated koas and treatments
  const posts = (await prisma.post.findMany({
    include: {
      koas: {
        include: { user: true },
      },
      treatment: true,
    },
  })) as PostWithRelations[];

  const appointments: AppointmentData[] = [];
  const now = new Date();

  console.log(
    `Found ${pasienProfiles.length} pasien profiles and ${koasProfiles.length} approved koas profiles`
  );
  console.log(`Seeding appointments for ${schedules.length} schedules`);

  // Create appointments with more realistic distribution
  for (const schedule of schedules) {
    // Find the related post for this schedule to ensure koas-post relationships are maintained
    const relatedPost = posts.find((post) => post.id === schedule.postId);

    if (!relatedPost || !relatedPost.koas) {
      console.log(
        `Skipping schedule ${schedule.id} - no related post or koas found`
      );
      continue;
    }

    const koasForSchedule = relatedPost.koas;
    const treatmentType = relatedPost.treatment?.name || 'Dental Treatment';

    // Get timeslots for this schedule
    const timeslots = schedule.timeslot;
    if (!timeslots || timeslots.length === 0) {
      console.log(`Skipping schedule ${schedule.id} - no timeslots available`);
      continue;
    }

    // Calculate target appointments based on timeslot capacity
    const scheduleCapacity = timeslots.reduce((total, slot) => {
      return total + (slot.maxParticipants || 3); // Default to 3 if not specified
    }, 0);

    // Generate between 30-80% of capacity for more realistic distribution
    const targetAppointments = Math.floor(
      scheduleCapacity * faker.number.float({ min: 0.3, max: 0.8 })
    );
    console.log(
      `Creating ${targetAppointments} appointments for schedule ${schedule.id} (capacity: ${scheduleCapacity})`
    );

    // Track filled slots to avoid overallocating
    const slotUsage: SlotUsage = {};
    timeslots.forEach((slot) => {
      slotUsage[slot.id] = {
        used: 0,
        max: slot.maxParticipants || 3,
      };
    });

    for (let i = 0; i < targetAppointments; i++) {
      // Find an available timeslot
      const availableSlots = timeslots.filter(
        (slot) => slotUsage[slot.id].used < slotUsage[slot.id].max
      );

      if (availableSlots.length === 0) break; // All slots filled

      // Select a random timeslot from available ones
      const selectedTimeslot = faker.helpers.arrayElement(availableSlots);
      slotUsage[selectedTimeslot.id].used++;

      // Select a random pasien
      const pasien = faker.helpers.arrayElement(pasienProfiles);

      // Schedule date logic - use more realistic date ranges
      const scheduleStartDate = new Date(schedule.dateStart);
      const scheduleEndDate = new Date(schedule.dateEnd);

      // For future appointments, keep them within schedule range
      // For past appointments, ensure they're in the past
      let appointmentDate;
      if (scheduleEndDate > now) {
        // For future/current schedules, some may be in past, some in future
        if (scheduleStartDate < now) {
          // Schedule spans current date
          appointmentDate = faker.date.between({
            from: scheduleStartDate,
            to: faker.helpers.arrayElement([scheduleEndDate, now]),
          });
        } else {
          // Future schedule
          appointmentDate = faker.date.between({
            from: scheduleStartDate,
            to: scheduleEndDate,
          });
        }
      } else {
        // Past schedule, all appointments in past
        appointmentDate = faker.date.between({
          from: scheduleStartDate,
          to: scheduleEndDate,
        });
      }

      // Format date for display
      const formattedDate = format(appointmentDate, 'd MMM yyyy');

      // Status distribution based on date and business logic
      let status: StatusAppointment;

      if (appointmentDate > now) {
        // Future appointments can only be Pending or Confirmed
        status = faker.helpers.arrayElement([
          'Pending',
          'Confirmed',
        ] as StatusAppointment[]);
      } else {
        // Past appointments can be Completed, Canceled, or Rejected
        const daysPast = Math.floor(
          (now.getTime() - appointmentDate.getTime()) / (1000 * 60 * 60 * 24)
        );

        if (daysPast > 14) {
          // Older appointments usually completed or canceled
          status = faker.helpers.weightedArrayElement([
            { value: 'Completed' as StatusAppointment, weight: 80 },
            { value: 'Canceled' as StatusAppointment, weight: 15 },
            { value: 'Rejected' as StatusAppointment, weight: 5 },
          ]);
        } else {
          // Recent appointments more variety
          status = faker.helpers.weightedArrayElement([
            { value: 'Completed' as StatusAppointment, weight: 50 },
            { value: 'Canceled' as StatusAppointment, weight: 20 },
            { value: 'Rejected' as StatusAppointment, weight: 10 },
            { value: 'Confirmed' as StatusAppointment, weight: 20 }, // Some still marked as confirmed
          ]);
        }
      }

      try {
        // Create the appointment
        const appointment = (await prisma.appointment.create({
          data: {
            pasienId: pasien.id,
            koasId: koasForSchedule.id,
            scheduleId: schedule.id,
            timeslotId: selectedTimeslot.id,
            date: formattedDate,
            status: status,
          },
        })) as AppointmentData;

        appointments.push(appointment);

        // Update timeslot current participants if status is Confirmed
        if (status === 'Confirmed' || status === 'Completed') {
          await prisma.timeslot.update({
            where: { id: selectedTimeslot.id },
            data: {
              currentParticipants: {
                increment: 1,
              },
              isAvailable: selectedTimeslot.maxParticipants
                ? slotUsage[selectedTimeslot.id].used <
                  selectedTimeslot.maxParticipants
                : true,
            },
          });
        }

        // Create notifications for certain appointment statuses
        if (
          status === 'Confirmed' ||
          status === 'Rejected' ||
          status === 'Canceled'
        ) {
          // Notification for pasien
          await prisma.notification.create({
            data: {
              userId: pasien.userId,
              title: `Appointment ${status}`,
              message: `Your appointment for ${treatmentType} has been ${status.toLowerCase()}.`,
              status: StatusNotification.Unread, // Use explicit enum reference
              createdAt:
                appointmentDate < now
                  ? faker.date.between({ from: appointmentDate, to: now })
                  : new Date(),
            },
          });

          // Notification for koas
          await prisma.notification.create({
            data: {
              userId: koasForSchedule.userId,
              title: `Patient Appointment ${status}`,
              message: `Appointment with ${
                pasien.user.name
              } for ${treatmentType} has been ${status.toLowerCase()}.`,
              status: StatusNotification.Unread, // Use explicit enum reference
              createdAt:
                appointmentDate < now
                  ? faker.date.between({ from: appointmentDate, to: now })
                  : new Date(),
            },
          });
        }

        // Create reviews for completed appointments that happened more than 2 days ago
        if (status === 'Completed' && appointmentDate < subDays(now, 2)) {
          // 70% chance of having a review
          if (faker.datatype.boolean(0.7)) {
            const rating = faker.number.int({ min: 3, max: 5 }); // Most reviews tend to be positive

            await prisma.review.create({
              data: {
                postId: relatedPost.id,
                pasienId: pasien.userId, // Make sure this field name matches the schema (used to be userId)
                rating: rating,
                comment: faker.helpers.arrayElement([
                  `Great experience with ${
                    koasForSchedule.user?.name || 'the koas'
                  }! Very professional.`,
                  `The treatment was ${
                    rating >= 4 ? 'excellent' : 'good'
                  }. Would recommend.`,
                  `${
                    koasForSchedule.user?.givenName || 'The dentist'
                  } was very knowledgeable about ${treatmentType}.`,
                  `The procedure went well. The koas explained everything clearly.`,
                  `${
                    rating === 5
                      ? 'Fantastic service!'
                      : 'Good service overall.'
                  } The facility was clean.`,
                ]),
                createdAt: faker.date.between({
                  from: appointmentDate,
                  to: now,
                }),
              },
            });
          }
        }
      } catch (error) {
        console.error(
          `Failed to create appointment for schedule ${schedule.id}:`,
          error
        );
      }
    }
  }

  console.log(`Successfully created ${appointments.length} appointments`);
  return appointments;
};
