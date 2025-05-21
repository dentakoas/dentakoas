import { PrismaClient } from '@prisma/client';
import { TreatmentSeedData } from '../types/seeding';
import { getTreatmentImage } from '../../utils/cloudinaryHelper';

export const seedTreatmentTypes = async (
  prisma: PrismaClient
): Promise<TreatmentSeedData[]> => {
  // Clean up existing data
  await prisma.treatmentType.deleteMany({});

  // Define dental treatments
  const treatments: Omit<TreatmentSeedData, 'id' | 'createdAt' | 'updateAt'>[] =
    [
      {
        name: 'Pemeriksaan Gigi Rutin',
        alias: 'Regular Checkup',
        image: getTreatmentImage('Regular Checkup'),
      },
      {
        name: 'Pembersihan Karang Gigi',
        alias: 'Scaling',
        image: getTreatmentImage('Scaling'),
      },
      {
        name: 'Perawatan Saluran Akar',
        alias: 'Root Canal',
        image: getTreatmentImage('Root Canal'),
      },
      {
        name: 'Tambal Gigi',
        alias: 'Filling',
        image: getTreatmentImage('Filling'),
      },
      {
        name: 'Cabut Gigi',
        alias: 'Extraction',
        image: getTreatmentImage('Extraction'),
      },
      {
        name: 'Bleaching Gigi',
        alias: 'Bleaching',
        image: getTreatmentImage('Bleaching'),
      },
      {
        name: 'Pemasangan Kawat Gigi',
        alias: 'Braces',
        image: getTreatmentImage('Braces'),
      },
      {
        name: 'Perawatan Gusi',
        alias: 'Gum Treatment',
        image: getTreatmentImage('Gum Treatment'),
      },
      {
        name: 'Gigi Tiruan',
        alias: 'Dentures',
        image: getTreatmentImage('Dentures'),
      },
      {
        name: 'Implan Gigi',
        alias: 'Implant',
        image: getTreatmentImage('Implant'),
      },
    ];

  try {
    const createdTreatments = await prisma.treatmentType.createMany({
      data: treatments.map((treatment) => ({
        name: treatment.name,
        alias: treatment.alias,
        image: treatment.image,
      })),
    });

    console.log(`Created ${createdTreatments.count} treatment types`);

    // Return the created treatments with complete data
    const savedTreatments = await prisma.treatmentType.findMany();
    return savedTreatments.map((treatment) => ({
      id: treatment.id,
      name: treatment.name,
      alias: treatment.alias,
      image: treatment.image,
      createdAt: treatment.createdAt,
      updateAt: treatment.updateAt,
    }));
  } catch (error) {
    console.error('Error creating treatments:', error);
    throw error;
  }
};
