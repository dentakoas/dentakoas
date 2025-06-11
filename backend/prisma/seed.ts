import { PrismaClient } from '@prisma/client';
import { seedUsers } from './seeds/users';
import { seedTreatmentTypes } from './seeds/treatments';
import { seedPosts } from './seeds/posts';
import { seedSchedules } from './seeds/schedules';
import { seedAppointments } from './seeds/appointments';
import { seedLikes } from './seeds/likes';
import { seedUniversities } from './seeds/universities';
import { fixPostImages } from '../scripts/fix-post-images';

const prisma = new PrismaClient({
  log: ['error'],
});

async function main() {
  try {
    console.log('Starting database seeding...');

    // Seed the univesity data
    console.log('Seeding university data...');
    const universities = await seedUniversities(prisma);
    console.log('University data seeding completed');

    // Check if data already exists and seed users
    console.log('Checking existing users and seeding if needed...');
    const users = await seedUsers(prisma);
    console.log('Users seeding completed');

    // Check if treatments already exist
    const existingTreatmentsCount = await prisma.treatmentType.count();
    let treatments;

    if (existingTreatmentsCount > 0) {
      console.log('Treatments already exist, fetching existing data');
      treatments = await prisma.treatmentType.findMany();
    } else {
      console.log('Seeding treatment types...');
      treatments = await seedTreatmentTypes(prisma);
      console.log('Treatment types seeding completed');
    }

    // Check if posts already exist
    const existingPostsCount = await prisma.post.count();
    let posts;

    if (existingPostsCount > 0) {
      console.log('Posts already exist, fetching existing data');
      posts = await prisma.post.findMany({
        include: {
          koas: true,
          treatment: true,
        },
      });
    } else {
      console.log('Seeding posts...');
      posts = await seedPosts(prisma, treatments);
      console.log('Posts seeding completed');
    }

    // Check if schedules already exist
    const existingSchedulesCount = await prisma.schedule.count();
    let schedules;

    if (existingSchedulesCount > 0) {
      console.log('Schedules already exist, fetching existing data');
      schedules = await prisma.schedule.findMany({
        include: {
          timeslot: true,
          post: {
            include: {
              treatment: true,
              koas: true,
            },
          },
        },
      });
    } else {
      console.log('Seeding schedules and timeslots...');
      schedules = await seedSchedules(prisma, posts);
      console.log('Schedules and timeslots seeding completed');
    }

    // Check if likes already exist
    const existingLikesCount = await prisma.like.count();

    if (existingLikesCount > 0) {
      console.log('Likes already exist, skipping likes seeding');
    } else {
      console.log('Seeding likes...');
      await seedLikes(prisma, posts);
      console.log('Likes seeding completed');
    }

    // Check if appointments already exist
    const existingAppointmentsCount = await prisma.appointment.count();

    if (existingAppointmentsCount > 0) {
      console.log('Appointments already exist, skipping appointments seeding');
    } else {
      console.log('Seeding appointments...');
      await seedAppointments(prisma, users, schedules);
      console.log('Appointments seeding completed');
    }

    console.log('Database seeding completed successfully');

    // await fixPostImages();
  } catch (error) {
    console.error('Error during database seeding:', error);
    if (error instanceof Error) console.error(error.stack);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
