import { PrismaClient, Role, StatusKoas } from '@prisma/client';
import firebaseAdmin from '../../lib/firebase-admin';
import { UserRecord } from 'firebase-admin/auth';
import { faker } from '@faker-js/faker';
import { UserSeedResult, FirebaseCreateData, KoasData } from '../types/seeding';

// Helper function to generate avatar URL based on gender
const getGenderBasedAvatar = (gender?: string): string => {
  // Default to random gender if not specified
  const sex = gender?.toLowerCase() === 'female' ? 'female' : 'male';
  return faker.image.personPortrait({ sex })
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

export const seedUsers = async (
  prisma: PrismaClient,
  resetFirebase: boolean = false
): Promise<UserSeedResult> => {
  try {
    console.log('Starting user seeding process...');
    console.log(`Firebase reset option: ${resetFirebase ? 'ENABLED' : 'DISABLED'}`);
    
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
          image: 'https://upload.wikimedia.org/wikipedia/id/7/70/Logo_Universitas_Jember.png',
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
        const deletePromises = listUsersResult.users.map(user => 
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
        console.log(`Found ${existingFirebaseUsers.length} existing Firebase users`);
      } catch (error) {
        console.error('Error listing Firebase users:', error);
        existingFirebaseUsers = [];
      }
      
      // If we have existing Firebase users, create database records for them
      if (existingFirebaseUsers.length > 0) {
        return await syncExistingFirebaseUsers(prisma, existingFirebaseUsers, universityId);
      } else {
        // If no existing users, create new ones
        console.log('No existing Firebase users found. Creating from scratch...');
        return await createAllUsersFromScratch(prisma, universityId);
      }
    }
  } catch (error) {
    console.error('Error seeding users:', error);
    throw error;
  }
};

// Helper function to create users from scratch
async function createAllUsersFromScratch(prisma: PrismaClient, universityId: string): Promise<UserSeedResult> {
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
  const koasCountToCreate = 20;
  const pasienCountToCreate = 30;
  
  await createFasilitators(fasilitatorCountToCreate, fasilitatorFirebaseUsers);
  await createKoas(koasCountToCreate, koasFirebaseUsers, koasData);
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

// Helper function to sync existing Firebase users to database
async function syncExistingFirebaseUsers(
  prisma: PrismaClient, 
  existingFirebaseUsers: UserRecord[], 
  universityId: string
): Promise<UserSeedResult> {
  console.log('Syncing existing Firebase users to database...');
  
  // Group users by role (from custom claims)
  const adminUsers: UserRecord[] = [];
  const fasilitatorUsers: UserRecord[] = [];
  const koasUsers: UserRecord[] = [];
  const pasienUsers: UserRecord[] = [];
  const koasData: KoasData[] = [];
  
  for (const user of existingFirebaseUsers) {
    const customClaims = user.customClaims as { role?: string } | undefined;
    const role = customClaims?.role || 'Pasien'; // Default to Pasien
    
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
  
  console.log(`Categorized users: ${adminUsers.length} admins, ${fasilitatorUsers.length} facilitators, ${koasUsers.length} koas, ${pasienUsers.length} patients`);
  
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

// Create admin user if none exists
async function createAdminUser(prisma: PrismaClient) {
  let adminFirebase;
  
  try {
    // Check if admin already exists
    adminFirebase = await firebaseAdmin.auth().getUserByEmail('admin@dentakoas.com');
    console.log('Admin user exists in Firebase');
  } catch (error) {
    // Create new admin if not exists
    adminFirebase = await firebaseAdmin.auth().createUser({
      email: 'admin@dentakoas.com',
      password: 'password123',
      displayName: 'Admin User',
      photoURL: getGenderBasedAvatar('male'), // Default to male for admin
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
    },
  });
  
  console.log('Created admin record in database');
  return adminUser;
}

// Create admin from existing Firebase user
async function createExistingAdminRecord(prisma: PrismaClient, adminFirebase: UserRecord) {
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
    
    const firebaseUser = await firebaseAdmin.auth().createUser({
      email: email,
      password: 'password123',
      displayName: `Dr. ${firstName} ${lastName}`,
      photoURL: getGenderBasedAvatar(gender),
    });
    
    await firebaseAdmin
      .auth()
      .setCustomUserClaims(firebaseUser.uid, { role: 'Fasilitator' });
      
    userList.push(firebaseUser);
  }
}

// Create koas users in Firebase
async function createKoas(count: number, userList: UserRecord[], koasDataList: KoasData[]) {
  for (let i = 0; i < count; i++) {
    // Determine gender randomly
    const gender = faker.helpers.arrayElement(['male', 'female']);
    const firstName = faker.person.firstName(gender as any);
    const lastName = faker.person.lastName();
    const email = faker.internet
      .email({ firstName, lastName, provider: 'student.unej.ac.id' })
      .toLowerCase();
    
    const entryYear = faker.helpers.arrayElement([23, 24]);
    const koasNumber = `${entryYear}1611${faker.string.numeric(6)}`;
    
    const firebaseUser = await firebaseAdmin.auth().createUser({
      email: email,
      password: 'password123',
      displayName: `${firstName} ${lastName}`,
      photoURL: getGenderBasedAvatar(gender),
    });
    
    await firebaseAdmin
      .auth()
      .setCustomUserClaims(firebaseUser.uid, { role: 'Koas' });
      
    userList.push(firebaseUser);
    koasDataList.push({
      id: firebaseUser.uid,
      koasNumber: koasNumber,
      entryYear: entryYear,
      gender: gender,
    });
  }
}

// Create patient users in Firebase
async function createPatients(count: number, userList: UserRecord[]) {
  for (let i = 0; i < count; i++) {
    // Determine gender randomly
    const gender = faker.helpers.arrayElement(['male', 'female']);
    const firstName = faker.person.firstName(gender as any);
    const lastName = faker.person.lastName();
    const email = faker.internet.email({ firstName, lastName }).toLowerCase();
    
    const firebaseUser = await firebaseAdmin.auth().createUser({
      email: email,
      password: 'password123',
      displayName: `${firstName} ${lastName}`,
      photoURL: getGenderBasedAvatar(gender),
    });
    
    await firebaseAdmin
      .auth()
      .setCustomUserClaims(firebaseUser.uid, { role: 'Pasien' });
      
    userList.push(firebaseUser);
  }
}

// Create facilitator records in database
async function createFasilitatorRecords(prisma: PrismaClient, users: UserRecord[]) {
  // Skip if no users
  if (users.length === 0) return;
  
  // Create user records
  await prisma.user.createMany({
    data: users.map((fbUser) => {
      // Determine gender from displayName or use random
      const displayName = fbUser.displayName || '';
      // Simple heuristic for gender detection from Firebase user
      let gender = 'male';
      if (fbUser.customClaims?.gender) {
        gender = fbUser.customClaims.gender as string;
      }
      
      const phoneNumber = generatePhoneNumber();
      
      return {
        id: fbUser.uid,
        givenName: `Dr. ${displayName.split(' ')[1] || ''}`,
        familyName: displayName.split(' ')[2] || '',
        name: displayName,
        email: fbUser.email || '',
        password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Fasilitator',
        image: fbUser.photoURL || getGenderBasedAvatar(gender),
        phone: phoneNumber,
        address: faker.location.streetAddress(),
      };
    }),
  });
  
  // Create facilitator profiles
  const facilitatorIds = users.map((fbUser) => fbUser.uid);
  await prisma.fasilitatorProfile.createMany({
    data: facilitatorIds.map((id) => ({
      userId: id,
      university: 'Universitas Negeri Jember',
    })),
  });
}

// Create koas records in database
async function createKoasRecords(prisma: PrismaClient, users: UserRecord[], koasData: KoasData[], universityId: string) {
  // Skip if no users
  if (users.length === 0) return;
  
  // Create user records
  await prisma.user.createMany({
    data: users.map((fbUser) => {
      // Find koas data to get gender
      const koasInfo = koasData.find(k => k.id === fbUser.uid);
      const gender = koasInfo?.gender || 'male';
      
      const phoneNumber = generatePhoneNumber();
      
      return {
        id: fbUser.uid,
        givenName: fbUser.displayName?.split(' ')[0] || '',
        familyName: fbUser.displayName?.split(' ')[1] || '',
        name: fbUser.displayName || '',
        email: fbUser.email || '',
        password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Koas',
        image: fbUser.photoURL || getGenderBasedAvatar(gender),
        phone: phoneNumber,
        address: faker.location.streetAddress(),
      };
    }),
  });
  
  // Create koas profiles
  for (const user of users) {
    // Find corresponding koas data
    const koasInfo = koasData.find(k => k.id === user.uid);
    
    if (!koasInfo) {
      console.log(`No koas data found for user ${user.uid}, skipping profile creation`);
      continue;
    }
    
    const koasUser = await prisma.user.findUnique({
      where: { id: user.uid },
      select: { phone: true },
    });
    
    const phoneNumber = koasUser?.phone || generatePhoneNumber();
    const whatsappLink = generateWhatsAppLink(phoneNumber);
    const formattedAge = `20${koasInfo.koasNumber.substring(0, 2)}`;
    const gender = koasInfo.gender || faker.helpers.arrayElement(['male', 'female']);
    
    await prisma.koasProfile.create({
      data: {
        userId: user.uid,
        koasNumber: koasInfo.koasNumber,
        age: formattedAge,
        gender: gender === 'female' ? 'Female' : 'Male',
        departement: 'Profesi Dokter Gigi',
        university: 'Universitas Negeri Jember',
        universityId: universityId,
        bio: generateShortBio(),
        whatsappLink: whatsappLink,
        status: faker.helpers.weightedArrayElement([
          { value: 'Approved' as StatusKoas, weight: 70 },
          { value: 'Pending' as StatusKoas, weight: 30 },
        ]),
        experience: faker.helpers.rangeToNumber({ min: 0, max: 5 }),
      },
    });
  }
}

// Create patient records in database
async function createPatientRecords(prisma: PrismaClient, users: UserRecord[]) {
  // Skip if no users
  if (users.length === 0) return;
  
  // Create user records
  await prisma.user.createMany({
    data: users.map((fbUser) => {
      // Extract gender from the name or avatar or use random
      let gender = 'male';
      if (fbUser.customClaims?.gender) {
        gender = fbUser.customClaims.gender as string;
      }
      
      return {
        id: fbUser.uid,
        givenName: fbUser.displayName?.split(' ')[0] || '',
        familyName: fbUser.displayName?.split(' ')[1] || '',
        name: fbUser.displayName || '',
        email: fbUser.email || '',
        password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW',
        role: 'Pasien',
        image: fbUser.photoURL || getGenderBasedAvatar(gender),
        phone: generatePhoneNumber(),
        address: faker.location.streetAddress(),
      };
    }),
  });
  
  // Create patient profiles
  await prisma.pasienProfile.createMany({
    data: users.map((fbUser) => {
      let gender = 'male';
      if (fbUser.customClaims?.gender) {
        gender = fbUser.customClaims.gender as string;
      }
      
      return {
        userId: fbUser.uid,
        age: faker.helpers.rangeToNumber({ min: 18, max: 70 }).toString(),
        gender: gender === 'female' ? 'Female' : 'Male',
        bio: generateShortBio(),
      };
    }),
  });
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