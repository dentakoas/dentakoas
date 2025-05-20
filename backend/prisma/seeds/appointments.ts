import { PrismaClient, StatusAppointment } from '@prisma/client';
import { addDays, format } from 'date-fns';

export const seedAppointments = async (
  prisma: PrismaClient,
  users: any,
  schedules: any
) => {
  // Clean up existing data
  await prisma.appointment.deleteMany({});

  const pasienProfiles = await prisma.pasienProfile.findMany();
  const koasProfiles = await prisma.koasProfile.findMany({
    where: { status: 'Approved' },
  });

  const appointments = [];
  const now = new Date();

  // Create some random appointments
  for (const schedule of schedules) {
    // Select random timeslots (1-3) from this schedule
    const timeslots = schedule.timeslot;
    const numAppointments = 1 + Math.floor(Math.random() * 3); // 1-3 appointments

    for (let i = 0; i < Math.min(numAppointments, timeslots.length); i++) {
      // Select a random pasien
      const pasienIndex = Math.floor(Math.random() * pasienProfiles.length);
      const pasien = pasienProfiles[pasienIndex];

      // Find the koas from the post
      const post = await prisma.post.findUnique({
        where: { id: schedule.postId },
        include: { koas: true },
      });

      const koas = post?.koas;

      if (koas) {
        // Random date between schedule start and end
        const scheduleStartDate = new Date(schedule.dateStart);
        const scheduleEndDate = new Date(schedule.dateEnd);
        const daysDiff = Math.floor(
          (scheduleEndDate.getTime() - scheduleStartDate.getTime()) /
            (1000 * 60 * 60 * 24)
        );
        const randomDays = Math.floor(Math.random() * daysDiff);
        const appointmentDate = addDays(scheduleStartDate, randomDays);

        // Format date as YYYY-MM-DD
        const formattedDate = format(appointmentDate, 'yyyy-MM-dd');

        // Random status
        const statuses: StatusAppointment[] = [
          'Pending',
          'Confirmed',
          'Completed',
          'Canceled',
          'Rejected',
        ];
        const randomStatusIndex = Math.floor(Math.random() * statuses.length);
        const status = statuses[randomStatusIndex];

        const appointment = await prisma.appointment.create({
          data: {
            pasienId: pasien.id,
            koasId: koas.id,
            scheduleId: schedule.id,
            timeslotId: timeslots[i].id,
            date: formattedDate,
            status: status,
          },
        });

        appointments.push(appointment);

        // Update current participants if status is Confirmed
        if (status === 'Confirmed') {
          await prisma.timeslot.update({
            where: { id: timeslots[i].id },
            data: {
              currentParticipants: {
                increment: 1,
              },
            },
          });
        }
      }
    }
  }

  return appointments;
};
