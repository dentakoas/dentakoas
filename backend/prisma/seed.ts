import { PrismaClient } from "@prisma/client";
import { seedUsers } from './seeds/users';
import { seedUniversities } from './seeds/universities';
import { seedTreatments } from './seeds/treatments';
import { seedPosts } from './seeds/posts';
import { seedSchedules } from './seeds/schedules';
import { seedAppointments } from './seeds/appointments';
import { seedReviews } from './seeds/reviews';
import { seedNotifications } from './seeds/notifications';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  try {
    // Seed in order to respect foreign key constraints
    console.log('🧑‍💼 Seeding users...');
    const users = await seedUsers(prisma);

    console.log('🏫 Seeding universities...');
    const universities = await seedUniversities(prisma);

    console.log('🦷 Seeding treatment types...');
    const treatments = await seedTreatments(prisma);

    console.log('📝 Seeding posts...');
    const posts = await seedPosts(prisma, users, treatments);

    console.log('📅 Seeding schedules and timeslots...');
    const schedules = await seedSchedules(prisma, posts);

    console.log('🤝 Seeding appointments...');
    await seedAppointments(prisma, users, schedules);

    console.log('⭐ Seeding reviews...');
    await seedReviews(prisma, users, posts);

    console.log('🔔 Seeding notifications...');
    await seedNotifications(prisma, users);

    console.log('✅ Seeding complete!');
  } catch (e) {
    console.error('❌ Seeding failed:');
    console.error(e);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
