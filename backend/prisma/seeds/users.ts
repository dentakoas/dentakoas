import { PrismaClient, Role, StatusKoas } from '@prisma/client';
import firebaseAdmin from '../../lib/firebase-admin';
import { UserRecord } from 'firebase-admin/auth';
import { faker } from '@faker-js/faker';
import { UserSeedResult, FirebaseCreateData, KoasData } from '../types/seeding';

import { koasUser } from '../data/users';

// Helper function to generate avatar URL based on gender
const getGenderBasedAvatar = (gender?: string): string => {
  // Default to random gender if not specified
  const sex = gender?.toLowerCase() === 'female' ? 'female' : 'male';
  return faker.image.personPortrait({ sex });
};

// Create a helper function to generate a short bio that won't exceed DB limits
const generateShortBio = (): string => {
  return faker.lorem.sentence(5);
};

// Helper function to generate a consistent phone number
const generatePhoneNumber = (): string => {
  return `08${faker.string.numeric(10)}`;
};

// Helper function to generate WhatsApp link from phone number
const generateWhatsAppLink = (phone: string): string => {
  const cleanPhone = phone.replace(/[+\s]/g, '');
  return `https://wa.me/${cleanPhone}`;
};

// Helper function to generate a unique name
const generateUniqueName = (
  firstName: string,
  lastName: string,
  index: number
): string => {
  return `${firstName} ${lastName}${index > 0 ? ` ${index}` : ''}`;
};

export const seedUsers = async (
  prisma: PrismaClient,
  resetFirebase: boolean = true
): Promise<UserSeedResult> => {
  try {
    console.log('Starting user seeding process...');
    console.log(
      `Firebase reset option: ${resetFirebase ? 'ENABLED' : 'DISABLED'}`
    );

    // Always delete database records first
    console.log('Clearing database records...');

    // Need to clear related tables first due to foreign key constraints
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
    await prisma.session.deleteMany({});
    await prisma.account.deleteMany({});

    console.log('All database records cleared');

    // Get or create university
    const universities = await prisma.university.findMany();
    let defaultUniversity = universities.length > 0 ? universities[0] : null;

    if (!defaultUniversity) {
      defaultUniversity = await prisma.university.create({
        data: {
          name: 'Universitas Negeri Jember',
          alias: 'UNEJ',
          location: 'Jl. Kalimantan No.37, Krajan Timur, Sumbersari, Jember',
          latitude: -8.1649,
          longitude: 113.7169,
          image:
            'https://upload.wikimedia.org/wikipedia/id/7/70/Logo_Universitas_Jember.png',
        },
      });
      console.log('Created default university:', defaultUniversity.name);
    }

    const universityId = defaultUniversity.id;
    const phoneNumbers = new Map<string, string>();

    // Store existing Firebase users if we're not resetting
    let existingFirebaseUsers: UserRecord[] = [];

    if (resetFirebase) {
      // If we're resetting Firebase, we'll delete and recreate all users
      console.log('Resetting Firebase users...');

      try {
        // Get all current Firebase users
        const listUsersResult = await firebaseAdmin.auth().listUsers(1000);

        // Delete all existing Firebase users
        const deletePromises = listUsersResult.users.map((user) =>
          firebaseAdmin.auth().deleteUser(user.uid)
        );

        await Promise.all(deletePromises);
        console.log(`Deleted ${listUsersResult.users.length} Firebase users`);
      } catch (error) {
        console.error('Error deleting Firebase users:', error);
        // Continue with creating new users
      }

      // Create new users from scratch
      return await createAllUsersFromScratch(prisma, universityId);
    } else {
      // If not resetting Firebase, we'll use existing Firebase users and sync with database
      console.log('Preserving Firebase users and syncing to database...');

      try {
        // Get all current Firebase users
        const listUsersResult = await firebaseAdmin.auth().listUsers(1000);
        existingFirebaseUsers = listUsersResult.users;
        console.log(
          `Found ${existingFirebaseUsers.length} existing Firebase users`
        );
      } catch (error) {
        console.error('Error listing Firebase users:', error);
        existingFirebaseUsers = [];
      }

      // If we have existing Firebase users, create database records for them
      if (existingFirebaseUsers.length > 0) {
        return await syncExistingFirebaseUsers(
          prisma,
          existingFirebaseUsers,
          universityId
        );
      } else {
        // If no existing users, create new ones
        console.log(
          'No existing Firebase users found. Creating from scratch...'
        );
        return await createAllUsersFromScratch(prisma, universityId);
      }
    }
  } catch (error) {
    console.error('Error seeding users:', error);
    throw error;
  }
};

// Helper function to create users from scratch
async function createAllUsersFromScratch(
  prisma: PrismaClient,
  universityId: string
): Promise<UserSeedResult> {
  console.log('Creating new users from scratch...');

  // Create admin user
  const adminUser = await createAdminUser(prisma);

  // Set up arrays to store user data
  const fasilitatorFirebaseUsers: UserRecord[] = [];
  const koasFirebaseUsers: UserRecord[] = [];
  const pasienFirebaseUsers: UserRecord[] = [];
  const koasData: KoasData[] = [];

  // Create users
  const fasilitatorCountToCreate = 5;
  const pasienCountToCreate = 10;

  await createFasilitators(fasilitatorCountToCreate, fasilitatorFirebaseUsers);
  await createKoasFromData(koasFirebaseUsers, koasData); // Ganti ke fungsi baru
  await createPatients(pasienCountToCreate, pasienFirebaseUsers);

  // Create database records
  await createFasilitatorRecords(prisma, fasilitatorFirebaseUsers);
  await createKoasRecords(prisma, koasFirebaseUsers, koasData, universityId);
  await createPatientRecords(prisma, pasienFirebaseUsers);

  console.log('User creation complete!');
  console.log(
    `Created ${fasilitatorFirebaseUsers.length} facilitators, ${koasFirebaseUsers.length} koas, and ${pasienFirebaseUsers.length} patient accounts`
  );

  return {
    admin: adminUser,
    fasilitatorCount: fasilitatorFirebaseUsers.length,
    koasCount: koasFirebaseUsers.length,
    pasienCount: pasienFirebaseUsers.length,
  };
}

// Create admin user if none exists
async function createAdminUser(prisma: PrismaClient) {
  let adminFirebase;

  try {
    // Check if admin already exists
    adminFirebase = await firebaseAdmin
      .auth()
      .getUserByEmail('admin@dentakoas.com');
    console.log('Admin user exists in Firebase');
  } catch (error) {
    // Create new admin if not exists
    adminFirebase = await firebaseAdmin.auth().createUser({
      email: 'admin@dentakoas.com',
      password: 'Password123',
      displayName: 'Admin User',
      photoURL: getGenderBasedAvatar('male'), // Default to male for admin
      emailVerified: true,
    });

    await firebaseAdmin
      .auth()
      .setCustomUserClaims(adminFirebase.uid, { role: 'Admin' });

    console.log('Created new admin user in Firebase');
  }

  // Create admin record in database
  const phoneNumber = generatePhoneNumber();
  const adminUser = await prisma.user.create({
    data: {
      id: adminFirebase.uid,
      givenName: 'Admin',
      familyName: 'User',
      name: 'Admin User',
      email: 'admin@dentakoas.com',
      password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
      role: 'Admin',
      image: adminFirebase.photoURL || getGenderBasedAvatar('male'),
      phone: phoneNumber,
      address: 'Jl. Kalimantan No.37, Jember',
      emailVerified: new Date(),
    },
  });

  console.log('Created admin record in database');
  return adminUser;
}

// Create admin from existing Firebase user
async function createExistingAdminRecord(
  prisma: PrismaClient,
  adminFirebase: UserRecord
) {
  const phoneNumber = generatePhoneNumber();

  const adminUser = await prisma.user.create({
    data: {
      id: adminFirebase.uid,
      givenName: 'Admin',
      familyName: 'User',
      name: adminFirebase.displayName || 'Admin User',
      email: adminFirebase.email || 'admin@dentakoas.com',
      password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
      role: 'Admin',
      image: adminFirebase.photoURL || getGenderBasedAvatar('male'),
      phone: phoneNumber,
      address: 'Jl. Kalimantan No.37, Jember',
      emailVerified: new Date(),
    },
  });

  console.log('Created admin record in database from existing Firebase user');
  return adminUser;
}

// Create facilitator users in Firebase
async function createFasilitators(count: number, userList: UserRecord[]) {
  for (let i = 0; i < count; i++) {
    // Determine gender randomly
    const gender = faker.helpers.arrayElement(['male', 'female']);
    const firstName = faker.person.firstName(gender as any);
    const lastName = faker.person.lastName();
    const email = faker.internet
      .email({ firstName, lastName, provider: 'unej.ac.id' })
      .toLowerCase();

    // Add index to name to ensure uniqueness
    const displayName = generateUniqueName(`Dr. ${firstName}`, lastName, i);

    const firebaseUser = await firebaseAdmin.auth().createUser({
      email: email,
      password: 'Password123',
      displayName: displayName,
      photoURL: getGenderBasedAvatar(gender),
      emailVerified: true,
    });

    await firebaseAdmin
      .auth()
      .setCustomUserClaims(firebaseUser.uid, { role: 'Fasilitator', gender });

    userList.push(firebaseUser);
  }
}

// Create koas users in Firebase
async function createKoasFromData(
  userList: UserRecord[],
  koasDataList: KoasData[]
) {
  // Cek email duplikat dan skip jika sudah pernah diproses
  const emailSet = new Set<string>();
  for (const koas of koasUser) {
    const email = koas.email.trim().toLowerCase();
    if (emailSet.has(email)) {
      console.warn(
        `SKIP: Duplicate email detected for ${koas.nama} (${email})`
      );
      continue;
    }
    emailSet.add(email);

    // Normalisasi gender
    const gender = koas.gender?.toLowerCase().includes('laki')
      ? 'male'
      : 'female';
    const displayName = koas.nama;
    const koasNumber = koas.koas_number;
    const entryYear =
      typeof koas.entry_year === 'number' ? koas.entry_year : 2023;
    const photoURL = koas.img;
    const phone = koas.phone;

    try {
      const firebaseUser = await firebaseAdmin.auth().createUser({
        email: email,
        password: 'Password123',
        displayName: displayName,
        photoURL: photoURL || getGenderBasedAvatar(gender),
        emailVerified: true,
      });

      await firebaseAdmin
        .auth()
        .setCustomUserClaims(firebaseUser.uid, { role: 'Koas', gender });

      userList.push(firebaseUser);
      koasDataList.push({
        id: firebaseUser.uid,
        koasNumber: koasNumber,
        entryYear: entryYear,
        gender: gender,
        phone: phone,
      });
    } catch (err) {
      console.error(
        `Error creating Firebase user for koas: ${displayName} (${email})`
      );
      throw err;
    }
  }
}

// Create patient users in Firebase
async function createPatients(count: number, userList: UserRecord[]) {
  const usedNames = new Set<string>();

  for (let i = 0; i < count; i++) {
    // Determine gender randomly
    const gender = faker.helpers.arrayElement(['male', 'female']);
    const firstName = faker.person.firstName(gender as any);
    const lastName = faker.person.lastName();

    // Create a unique name with index suffix if needed
    let displayName = `${firstName} ${lastName}`;
    let nameIndex = 0;

    // If name already exists, add a number suffix
    while (usedNames.has(displayName.toLowerCase())) {
      nameIndex++;
      displayName = generateUniqueName(firstName, lastName, nameIndex);
    }

    usedNames.add(displayName.toLowerCase());

    const email = faker.internet.email({ firstName, lastName }).toLowerCase();

    const firebaseUser = await firebaseAdmin.auth().createUser({
      email: email,
      password: 'Password123',
      displayName: displayName,
      photoURL: getGenderBasedAvatar(gender),
      emailVerified: true,
    });

    await firebaseAdmin
      .auth()
      .setCustomUserClaims(firebaseUser.uid, { role: 'Pasien', gender });

    userList.push(firebaseUser);
  }
}

// Helper function to sync existing Firebase users to database
async function syncExistingFirebaseUsers(
  prisma: PrismaClient,
  existingFirebaseUsers: UserRecord[],
  universityId: string
): Promise<UserSeedResult> {
  console.log('Syncing existing Firebase users to database...');

  // Track used names to ensure uniqueness
  const usedNames = new Set<string>();

  // Group users by role (from custom claims)
  const adminUsers: UserRecord[] = [];
  const fasilitatorUsers: UserRecord[] = [];
  const koasUsers: UserRecord[] = [];
  const pasienUsers: UserRecord[] = [];
  const koasData: KoasData[] = [];

  // First pass to collect all existing names
  for (const user of existingFirebaseUsers) {
    if (user.displayName) {
      usedNames.add(user.displayName.toLowerCase());
    }
  }

  // Process users by role
  for (let user of existingFirebaseUsers) {
    const customClaims = user.customClaims as
      | { role?: string; gender?: string }
      | undefined;
    const role = customClaims?.role || 'Pasien';

    // Ensure user has a unique display name
    if (!user.displayName || user.displayName.trim() === '') {
      // Generate a display name if none exists
      const nameParts = user.email?.split('@')[0].split('.') || ['User'];
      const firstName =
        nameParts[0]?.charAt(0).toUpperCase() + nameParts[0]?.slice(1) ||
        'User';
      const lastName =
        nameParts[1]?.charAt(0).toUpperCase() + nameParts[1]?.slice(1) || '';

      // Create a base display name
      let displayName = `${firstName}${lastName ? ' ' + lastName : ''}`;
      let nameIndex = 0;

      // Ensure uniqueness
      while (usedNames.has(displayName.toLowerCase())) {
        nameIndex++;
        displayName = `${firstName}${
          lastName ? ' ' + lastName : ''
        } ${nameIndex}`;
      }

      usedNames.add(displayName.toLowerCase());

      // Update Firebase user with the new display name
      await firebaseAdmin.auth().updateUser(user.uid, {
        displayName: displayName,
      });

      // Update our local user record
      user = await firebaseAdmin.auth().getUser(user.uid);
    }

    switch (role) {
      case 'Admin':
        adminUsers.push(user);
        break;
      case 'Fasilitator':
        fasilitatorUsers.push(user);
        break;
      case 'Koas':
        koasUsers.push(user);
        // Generate koas number if syncing existing users
        const entryYear = faker.helpers.arrayElement([23, 24]);
        const koasNumber = `${entryYear}1611${faker.string.numeric(6)}`;
        koasData.push({
          id: user.uid,
          koasNumber: koasNumber,
          entryYear: entryYear,
        });
        break;
      default: // Pasien or unknown roles
        pasienUsers.push(user);
        break;
    }
  }

  console.log(
    `Categorized users: ${adminUsers.length} admins, ${fasilitatorUsers.length} facilitators, ${koasUsers.length} koas, ${pasienUsers.length} patients`
  );

  // Create database records for each user type
  let adminUser = null;
  if (adminUsers.length > 0) {
    adminUser = await createExistingAdminRecord(prisma, adminUsers[0]);
  } else {
    // Create admin if none exists
    adminUser = await createAdminUser(prisma);
  }

  await createFasilitatorRecords(prisma, fasilitatorUsers);
  await createKoasRecords(prisma, koasUsers, koasData, universityId);
  await createPatientRecords(prisma, pasienUsers);

  console.log('User synchronization complete!');

  return {
    admin: adminUser,
    fasilitatorCount: fasilitatorUsers.length,
    koasCount: koasUsers.length,
    pasienCount: pasienUsers.length,
  };
}

// Create facilitator records in database
async function createFasilitatorRecords(
  prisma: PrismaClient,
  users: UserRecord[]
) {
  // Skip if no users
  if (users.length === 0) return;

  // Create user records one by one to handle potential duplicates
  for (const fbUser of users) {
    try {
      // Determine gender from claims
      const customClaims = fbUser.customClaims as
        | { gender?: string }
        | undefined;
      const gender = customClaims?.gender || 'male';

      const phoneNumber = generatePhoneNumber();

      await prisma.user.create({
        data: {
          id: fbUser.uid,
          givenName: fbUser.displayName?.split(' ')[1] || '', // Skip "Dr." prefix
          familyName: fbUser.displayName?.split(' ').slice(2).join(' ') || '',
          name: fbUser.displayName || 'User' + fbUser.uid.substring(0, 6), // Ensure uniqueness
          email: fbUser.email || '',
          emailVerified: new Date(),
          password:
            '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
          role: 'Fasilitator',
          image: fbUser.photoURL || getGenderBasedAvatar(gender),
          phone: phoneNumber,
          address: faker.location.streetAddress(),
        },
      });

      // Create facilitator profile
      await prisma.fasilitatorProfile.create({
        data: {
          userId: fbUser.uid,
          university: 'Universitas Negeri Jember',
        },
      });
    } catch (error) {
      console.error(
        `Error creating Fasilitator record for ${fbUser.uid}:`,
        error
      );
    }
  }
}

// Create koas records in database
async function createKoasRecords(
  prisma: PrismaClient,
  users: UserRecord[],
  koasData: KoasData[],
  universityId: string
) {
  if (users.length === 0) return;

  for (const fbUser of users) {
    try {
      // Ambil data koas dari koasData
      const koasInfo = koasData.find((k) => k.id === fbUser.uid);
      // Fallback jika tidak ada
      const gender = koasInfo?.gender;
      const phone = koasInfo?.phone;
      const koasNumber = koasInfo?.koasNumber || '';
      const entryYear = koasInfo?.entryYear || 2023;

      const nama = fbUser.displayName!;

      // Split nama untuk givenName dan familyName
      const nameParts = nama.split(' ');
      const givenName = nameParts[0] || '';
      const familyName = nameParts.slice(1).join(' ') || '';

      // Insert ke tabel User
      await prisma.user.create({
        data: {
          id: fbUser.uid,
          givenName: givenName,
          familyName: familyName,
          name: nama,
          email: fbUser.email || '',
          emailVerified: new Date(),
          password:
            '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
          role: 'Koas',
          phone: phone,
          address: faker.location.streetAddress(),
        },
      });

      // Insert ke tabel KoasProfile
      await prisma.koasProfile.create({
        data: {
          userId: fbUser.uid,
          koasNumber: koasNumber,
          age: entryYear ? entryYear.toString() : undefined,
          gender: gender === 'female' ? 'Female' : 'Male',
          departement: 'Profesi Dokter Gigi',
          university: 'Universitas Negeri Jember',
          universityId: universityId,
          bio: generateShortBio(),
          whatsappLink: phone ? generateWhatsAppLink(phone) : '',
          status: 'Approved' as StatusKoas,
          experience: faker.helpers.rangeToNumber({ min: 0, max: 5 }),
        },
      });
    } catch (error) {
      console.error(`Error creating Koas record for ${fbUser.uid}:`, error);
    }
  }
}

// Create patient records in database
async function createPatientRecords(prisma: PrismaClient, users: UserRecord[]) {
  // Skip if no users
  if (users.length === 0) return;

  // Create user records one by one to handle potential duplicates
  for (const fbUser of users) {
    try {
      // Extract gender from claims
      const customClaims = fbUser.customClaims as
        | { gender?: string }
        | undefined;
      const gender = customClaims?.gender || 'male';

      const phoneNumber = generatePhoneNumber();

      // Create user record
      await prisma.user.create({
        data: {
          id: fbUser.uid,
          givenName: fbUser.displayName?.split(' ')[0] || '',
          familyName: fbUser.displayName?.split(' ').slice(1).join(' ') || '',
          name: fbUser.displayName || 'User' + fbUser.uid.substring(0, 6), // Ensure uniqueness
          email: fbUser.email || '',
          emailVerified: new Date(),
          password:
            '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
          role: 'Pasien',
          image: fbUser.photoURL || getGenderBasedAvatar(gender),
          phone: phoneNumber,
          address: faker.location.streetAddress(),
        },
      });

      // Create patient profile
      await prisma.pasienProfile.create({
        data: {
          userId: fbUser.uid,
          age: faker.helpers.rangeToNumber({ min: 18, max: 70 }).toString(),
          gender: gender === 'female' ? 'Female' : 'Male',
          bio: generateShortBio(),
        },
      });
    } catch (error) {
      console.error(`Error creating Pasien record for ${fbUser.uid}:`, error);
    }
  }
}

// Helper function to generate a hash from a string (for consistent avatar IDs)
function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return Math.abs(hash);
}
