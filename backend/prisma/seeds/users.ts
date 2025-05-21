import { PrismaClient, Role, StatusKoas } from '@prisma/client';
import firebaseAdmin from '../../lib/firebase-admin';
import { UserRecord } from 'firebase-admin/auth';
import { faker } from '@faker-js/faker';
import { UserSeedResult, FirebaseCreateData, KoasData } from '../types/seeding';
import { getRandomAvatar } from '../../utils/cloudinaryHelper';

export const seedUsers = async (
  prisma: PrismaClient
): Promise<UserSeedResult> => {
  try {
    // First check if there are users in Firebase Auth
    console.log('Fetching existing users from Firebase Auth...');
    let existingFirebaseUsers: UserRecord[] = [];

    try {
      // ListUsers returns up to 1000 users per page
      const listUsersResult = await firebaseAdmin.auth().listUsers(1000);
      existingFirebaseUsers = listUsersResult.users;
      console.log(
        `Found ${existingFirebaseUsers.length} users in Firebase Auth`
      );
    } catch (error) {
      console.error('Error listing Firebase users:', error);
      existingFirebaseUsers = [];
    }

    // If we have Firebase users, let's check if they're in our database
    if (existingFirebaseUsers.length > 0) {
      console.log('Syncing Firebase Auth users with database...');

      // Get existing database users
      const dbUsers = await prisma.user.findMany({
        select: { id: true },
      });

      const dbUserIds = new Set(dbUsers.map((user) => user.id));

      // Filter users not in database
      const newUsers = existingFirebaseUsers.filter(
        (fbUser) => !dbUserIds.has(fbUser.uid)
      );

      if (newUsers.length > 0) {
        console.log(
          `Found ${newUsers.length} Firebase users not in database. Adding them...`
        );

        // Process users in batches to avoid overloading the database
        const batchSize = 50;
        for (let i = 0; i < newUsers.length; i += batchSize) {
          const batch = newUsers.slice(i, i + batchSize);

          // Create database users from Firebase users
          await prisma.user.createMany({
            data: batch.map((fbUser) => {
              // Determine role from custom claims or default to Pasien
              const customClaims = fbUser.customClaims as
                | { role?: string }
                | undefined;
              const role = (customClaims?.role || 'Pasien') as Role;

              // Extract names from displayName
              const nameParts = fbUser.displayName?.split(' ') || [];
              const givenName = nameParts[0] || '';
              const familyName = nameParts.slice(1).join(' ') || '';

              return {
                id: fbUser.uid,
                email: fbUser.email,
                name:
                  fbUser.displayName ||
                  fbUser.email?.split('@')[0] ||
                  fbUser.uid,
                givenName: givenName,
                familyName: familyName,
                image: fbUser.photoURL || getRandomAvatar(),
                role: role, // Cast to Role enum
                password:
                  '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // Default hashed password
              };
            }),
            skipDuplicates: true,
          });

          console.log(
            `Added users ${i + 1} to ${Math.min(
              i + batchSize,
              newUsers.length
            )}`
          );

          // Create corresponding profiles based on roles
          for (const fbUser of batch) {
            const customClaims = fbUser.customClaims as
              | { role?: string }
              | undefined;
            const role = customClaims?.role || 'Pasien';

            if (role === 'Koas') {
              // Check if KoasProfile already exists
              const existingProfile = await prisma.koasProfile.findUnique({
                where: { userId: fbUser.uid },
              });

              if (!existingProfile) {
                await prisma.koasProfile.create({
                  data: {
                    userId: fbUser.uid,
                    koasNumber: `${faker.helpers.arrayElement([
                      23, 24,
                    ])}1611${faker.string.numeric(6)}`,
                    status: 'Approved',
                    gender: faker.helpers.arrayElement(['Male', 'Female']),
                    departement: 'Profesi Dokter Gigi',
                    university: 'Universitas Negeri Jember',
                    experience: faker.helpers.rangeToNumber({ min: 0, max: 5 }),
                  },
                });
              }
            } else if (role === 'Pasien') {
              // Check if PasienProfile already exists
              const existingProfile = await prisma.pasienProfile.findUnique({
                where: { userId: fbUser.uid },
              });

              if (!existingProfile) {
                await prisma.pasienProfile.create({
                  data: {
                    userId: fbUser.uid,
                    age: faker.helpers
                      .rangeToNumber({ min: 18, max: 70 })
                      .toString(),
                    gender: faker.helpers.arrayElement(['Male', 'Female']),
                    bio: faker.lorem.sentence(),
                  },
                });
              }
            } else if (role === 'Fasilitator') {
              // Check if FasilitatorProfile already exists
              const existingProfile =
                await prisma.fasilitatorProfile.findUnique({
                  where: { userId: fbUser.uid },
                });

              if (!existingProfile) {
                await prisma.fasilitatorProfile.create({
                  data: {
                    userId: fbUser.uid,
                    university: 'Universitas Negeri Jember',
                  },
                });
              }
            }
          }
        }
      } else {
        console.log('All Firebase users are already in the database.');
      }
    }

    // Check if admin user already exists in Firebase
    let adminUser;
    let adminFirebase;
    try {
      adminFirebase = await firebaseAdmin
        .auth()
        .getUserByEmail('admin@dentakoas.com');
      console.log('Admin user already exists in Firebase, skipping creation');

      // Check if admin exists in database
      adminUser = await prisma.user.findUnique({
        where: { id: adminFirebase.uid },
      });

      if (!adminUser) {
        console.log(
          'Admin user exists in Firebase but not in database, creating database record'
        );

        // Important: This is the fix - we need to supply a string value that matches exactly
        adminUser = await prisma.user.create({
          data: {
            id: adminFirebase.uid,
            givenName: 'Admin',
            familyName: 'User',
            name: 'Admin User',
            email: 'admin@dentakoas.com',
            password:
              '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
            // Explicitly use string value that exactly matches the database enum
            role: 'Admin',
            image: adminFirebase.photoURL || getRandomAvatar(),
          },
        });
      }
    } catch (error) {
      // Admin user doesn't exist, clear data and create new users
      console.log(
        'Admin user not found in Firebase, clearing existing data and creating new users'
      );

      // Clear existing data
      await prisma.user.deleteMany({});
      await prisma.notification.deleteMany({});
      await prisma.like.deleteMany({});
      await prisma.review.deleteMany({});
      await prisma.appointment.deleteMany({});
      await prisma.timeslot.deleteMany({});
      await prisma.schedule.deleteMany({});
      await prisma.post.deleteMany({});
      await prisma.koasProfile.deleteMany({});
      await prisma.pasienProfile.deleteMany({});
      await prisma.fasilitatorProfile.deleteMany({});

      // Create Admin user
      adminFirebase = await firebaseAdmin.auth().createUser({
        email: 'admin@dentakoas.com',
        password: 'password123',
        displayName: 'Admin User',
        photoURL: getRandomAvatar(),
      });

      // When setting custom claims, use string values for Firebase
      await firebaseAdmin
        .auth()
        .setCustomUserClaims(adminFirebase.uid, { role: 'Admin' });

      adminUser = await prisma.user.create({
        data: {
          id: adminFirebase.uid,
          givenName: 'Admin',
          familyName: 'User',
          name: 'Admin User',
          email: 'admin@dentakoas.com',
          password:
            adminFirebase.passwordHash ||
            '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
          role: 'Admin', // Using enum value
          image: adminFirebase.photoURL || getRandomAvatar(),
        },
      });
    }

    // Check if we already have users in the database
    const fasilitatorCount = await prisma.fasilitatorProfile.count();
    const koasCount = await prisma.koasProfile.count();
    const pasienCount = await prisma.pasienProfile.count();

    // If we have existing users, return the counts
    if (fasilitatorCount > 0 || koasCount > 0 || pasienCount > 0) {
      console.log(
        'Users already exist in database, skipping creation of new users'
      );

      console.log(
        `Found ${fasilitatorCount} fasilitators, ${koasCount} koas, and ${pasienCount} pasien accounts`
      );

      return {
        admin: adminUser,
        fasilitatorCount,
        koasCount,
        pasienCount,
      };
    }

    // If we reached here, we need to create new users
    console.log('Creating new users since none exist in the database...');

    // If we need to create new users
    const fasilitatorCountToCreate = 5;
    const fasilitatorFirebaseUsers: UserRecord[] = [];

    // Create multiple Fasilitator users using Faker
    for (let i = 0; i < fasilitatorCountToCreate; i++) {
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      const email = faker.internet
        .email({ firstName, lastName, provider: 'unej.ac.id' })
        .toLowerCase();

      const firebaseUser = await firebaseAdmin.auth().createUser({
        email: email,
        password: 'password123',
        displayName: `Dr. ${firstName} ${lastName}`,
        photoURL: getRandomAvatar(),
      });

      // Fix roles in Firebase claims - use string value
      await firebaseAdmin
        .auth()
        .setCustomUserClaims(firebaseUser.uid, { role: 'Fasilitator' });
      fasilitatorFirebaseUsers.push(firebaseUser);
    }

    // Use createMany for fasilitator users in database
    await prisma.user.createMany({
      data: fasilitatorFirebaseUsers.map((fbUser) => ({
        id: fbUser.uid,
        givenName: `Dr. ${fbUser.displayName?.split(' ')[1] || ''}`,
        familyName: fbUser.displayName?.split(' ')[2] || '',
        name: fbUser.displayName || '',
        email: fbUser.email || '',
        password:
          fbUser.passwordHash ||
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Fasilitator', // Use string value instead of enum
        image: fbUser.photoURL || getRandomAvatar(),
      })),
    });

    // Create fasilitator profiles
    const fasilitatorIds = fasilitatorFirebaseUsers.map((fbUser) => fbUser.uid);
    await prisma.fasilitatorProfile.createMany({
      data: fasilitatorIds.map((id) => ({
        userId: id,
        university: 'Universitas Negeri Jember',
      })),
    });

    // Create multiple Koas users using Faker
    const koasCountToCreate = 20;
    const koasFirebaseUsers: UserRecord[] = [];
    const koasData: KoasData[] = [];

    for (let i = 0; i < koasCountToCreate; i++) {
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      const email = faker.internet
        .email({ firstName, lastName, provider: 'student.unej.ac.id' })
        .toLowerCase();

      // Generate koasNumber: only use years 23 or 24 (2023 or 2024)
      const entryYear = faker.helpers.arrayElement([23, 24]); // Only 2023 or 2024
      const koasNumber = `${entryYear}1611${faker.string.numeric(6)}`;

      const firebaseUser = await firebaseAdmin.auth().createUser({
        email: email,
        password: 'password123',
        displayName: `${firstName} ${lastName}`,
        photoURL: getRandomAvatar(),
      });

      // Fix roles in Firebase claims - use string value
      await firebaseAdmin
        .auth()
        .setCustomUserClaims(firebaseUser.uid, { role: 'Koas' });
      koasFirebaseUsers.push(firebaseUser);

      koasData.push({
        id: firebaseUser.uid,
        koasNumber: koasNumber,
        entryYear: entryYear,
      });
    }

    // Use createMany for koas users in database
    await prisma.user.createMany({
      data: koasFirebaseUsers.map((fbUser) => ({
        id: fbUser.uid,
        givenName: fbUser.displayName?.split(' ')[0] || '',
        familyName: fbUser.displayName?.split(' ')[1] || '',
        name: fbUser.displayName || '',
        email: fbUser.email || '',
        password:
          fbUser.passwordHash ||
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Koas', // Use string value instead of enum
        image: fbUser.photoURL || getRandomAvatar(),
      })),
    });

    // Create koas profiles with academic year from koasNumber
    for (const koas of koasData) {
      await prisma.koasProfile.create({
        data: {
          userId: koas.id,
          koasNumber: koas.koasNumber,
          age: `20${koas.entryYear}`,
          gender: faker.helpers.arrayElement(['Male', 'Female']),
          departement: 'Profesi Dokter Gigi',
          university: 'Universitas Negeri Jember',
          bio: faker.lorem.sentence(),
          whatsappLink: `https://wa.me/628${faker.string.numeric(10)}`,
          // Use string value for StatusKoas enum
          status: faker.helpers.weightedArrayElement([
            { value: 'Approved' as StatusKoas, weight: 70 },
            { value: 'Pending' as StatusKoas, weight: 30 },
          ]),
          experience: faker.helpers.rangeToNumber({ min: 0, max: 5 }),
        },
      });
    }

    // Create multiple Pasien users using Faker
    const pasienCountToCreate = 30;
    const pasienFirebaseUsers: UserRecord[] = [];

    for (let i = 0; i < pasienCountToCreate; i++) {
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      const email = faker.internet.email({ firstName, lastName }).toLowerCase();

      const firebaseUser = await firebaseAdmin.auth().createUser({
        email: email,
        password: 'password123',
        displayName: `${firstName} ${lastName}`,
        photoURL: getRandomAvatar(),
      });

      // Fix roles in Firebase claims - use string value
      await firebaseAdmin
        .auth()
        .setCustomUserClaims(firebaseUser.uid, { role: 'Pasien' });
      pasienFirebaseUsers.push(firebaseUser);
    }

    // Use createMany for pasien users in database
    await prisma.user.createMany({
      data: pasienFirebaseUsers.map((fbUser) => ({
        id: fbUser.uid,
        givenName: fbUser.displayName?.split(' ')[0] || '',
        familyName: fbUser.displayName?.split(' ')[1] || '',
        name: fbUser.displayName || '',
        email: fbUser.email || '',
        password:
          fbUser.passwordHash ||
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Pasien', // Use string value instead of enum
        image: fbUser.photoURL || getRandomAvatar(),
      })),
    });

    // Create pasien profiles
    await prisma.pasienProfile.createMany({
      data: pasienFirebaseUsers.map((fbUser) => ({
        userId: fbUser.uid,
        age: faker.helpers.rangeToNumber({ min: 18, max: 70 }).toString(),
        gender: faker.helpers.arrayElement(['Male', 'Female']),
        bio: faker.lorem.sentence(),
      })),
    });

    console.log(
      `Seeded ${fasilitatorCount} fasilitators, ${koasCount} koas, and ${pasienCountToCreate} pasien accounts`
    );

    // Collect user counts for return
    const allUsers: UserSeedResult = {
      admin: adminUser,
      fasilitatorCount: fasilitatorCount,
      koasCount: koasCount,
      pasienCount: pasienCountToCreate,
    };

    return allUsers;
  } catch (error) {
    console.error('Error seeding users:', error);
    throw error;
  }
};
