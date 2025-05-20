import { PrismaClient } from '@prisma/client';

export const seedUniversities = async (prisma: PrismaClient) => {
  // Clean up existing data
  await prisma.university.deleteMany({});

  // Create only Universitas Negeri Jember
  const universities = await Promise.all([
    prisma.university.create({
      data: {
        name: 'Universitas Negeri Jember',
        alias: 'UNEJ',
        location: 'Jember, Jawa Timur',
        latitude: -8.1682,
        longitude: 113.7023,
        image:
          'https://unej.ac.id/wp-content/uploads/2021/02/cropped-logo-unej-png.png',
      },
    }),
  ]);

  return universities;
};
