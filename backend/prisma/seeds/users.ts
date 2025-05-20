import { PrismaClient, Role } from '@prisma/client';

export const seedUsers = async (prisma: PrismaClient) => {
  // Clear existing data
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
  await prisma.user.deleteMany({});

  // Create Admin user
  const admin = await prisma.user.create({
    data: {
      id: 'admin-id-123456',
      givenName: 'Admin',
      familyName: 'User',
      name: 'Admin User',
      email: 'admin@dentakoas.com',
      password: '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
      role: Role.Admin,
      image: 'https://randomuser.me/api/portraits/men/1.jpg',
    },
  });

  // Create Fasilitator users with Universitas Negeri Jember
  const fasilitators = await Promise.all([
    prisma.user.create({
      data: {
        id: 'fasil-id-123456',
        givenName: 'Dr. Budi',
        familyName: 'Santoso',
        name: 'Dr. Budi Santoso',
        email: 'budi@unej.ac.id',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Fasilitator,
        image: 'https://randomuser.me/api/portraits/men/2.jpg',
        FasilitatorProfile: {
          create: {
            university: 'Universitas Negeri Jember',
          },
        },
      },
    }),
    prisma.user.create({
      data: {
        id: 'fasil-id-789012',
        givenName: 'Dr. Siti',
        familyName: 'Rahma',
        name: 'Dr. Siti Rahma',
        email: 'siti@unej.ac.id',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Fasilitator,
        image: 'https://randomuser.me/api/portraits/women/2.jpg',
        FasilitatorProfile: {
          create: {
            university: 'Universitas Negeri Jember',
          },
        },
      },
    }),
  ]);

  // Create Koas users with valid NIM formats for Universitas Negeri Jember
  const koasUsers = await Promise.all([
    prisma.user.create({
      data: {
        id: 'koas-id-123456',
        givenName: 'Andi',
        familyName: 'Wijaya',
        name: 'Andi Wijaya',
        email: 'andi@student.unej.ac.id',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Koas,
        image: 'https://randomuser.me/api/portraits/men/3.jpg',
        KoasProfile: {
          create: {
            koasNumber: '231611101055', // Following the pattern: 23+16+11+101055
            age: '23',
            gender: 'Male',
            departement: 'Periodontics',
            university: 'Universitas Negeri Jember',
            bio: 'Clinical student specializing in periodontal treatments',
            whatsappLink: 'https://wa.me/6281234567890',
            status: 'Approved',
            experience: 2,
          },
        },
      },
    }),
    prisma.user.create({
      data: {
        id: 'koas-id-789012',
        givenName: 'Dina',
        familyName: 'Putri',
        name: 'Dina Putri',
        email: 'dina@student.unej.ac.id',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Koas,
        image: 'https://randomuser.me/api/portraits/women/3.jpg',
        KoasProfile: {
          create: {
            koasNumber: '231611102066', // Following the pattern: 23+16+11+102066
            age: '24',
            gender: 'Female',
            departement: 'Orthodontics',
            university: 'Universitas Negeri Jember',
            bio: 'Specializing in corrective treatments for teeth alignment',
            whatsappLink: 'https://wa.me/6289876543210',
            status: 'Approved',
            experience: 3,
          },
        },
      },
    }),
    prisma.user.create({
      data: {
        id: 'koas-id-345678',
        givenName: 'Rudi',
        familyName: 'Hartono',
        name: 'Rudi Hartono',
        email: 'rudi@student.unej.ac.id',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Koas,
        image: 'https://randomuser.me/api/portraits/men/4.jpg',
        KoasProfile: {
          create: {
            koasNumber: '241611103077', // Following the pattern: 24+16+11+103077
            age: '22',
            gender: 'Male',
            departement: 'Endodontics',
            university: 'Universitas Negeri Jember',
            bio: 'Focusing on root canal treatments and dental pulp issues',
            whatsappLink: 'https://wa.me/6282345678901',
            status: 'Pending',
            experience: 1,
          },
        },
      },
    }),
  ]);

  // Create Pasien users
  const pasienUsers = await Promise.all([
    prisma.user.create({
      data: {
        id: 'pasien-id-123456',
        givenName: 'Dewi',
        familyName: 'Lestari',
        name: 'Dewi Lestari',
        email: 'dewi@example.com',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Pasien,
        image: 'https://randomuser.me/api/portraits/women/4.jpg',
        PasienProfile: {
          create: {
            age: '35',
            gender: 'Female',
            bio: 'Looking for dental treatment options',
          },
        },
      },
    }),
    prisma.user.create({
      data: {
        id: 'pasien-id-789012',
        givenName: 'Joko',
        familyName: 'Susanto',
        name: 'Joko Susanto',
        email: 'joko@example.com',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Pasien,
        image: 'https://randomuser.me/api/portraits/men/5.jpg',
        PasienProfile: {
          create: {
            age: '42',
            gender: 'Male',
            bio: 'Need help with teeth cleaning and cavity treatment',
          },
        },
      },
    }),
    prisma.user.create({
      data: {
        id: 'pasien-id-345678',
        givenName: 'Maya',
        familyName: 'Purnama',
        name: 'Maya Purnama',
        email: 'maya@example.com',
        password:
          '$2a$10$Ab6y1GO/BF.MMuZ97zj9B.S2s8wVEMRFXDn8GK9tmlpHt.T2HzYHW', // password123
        role: Role.Pasien,
        image: 'https://randomuser.me/api/portraits/women/5.jpg',
        PasienProfile: {
          create: {
            age: '28',
            gender: 'Female',
            bio: 'Seeking help for teeth alignment options',
          },
        },
      },
    }),
  ]);

  // Collect all users for return
  const allUsers = {
    admin,
    fasilitators,
    koasUsers,
    pasienUsers,
  };

  return allUsers;
};
