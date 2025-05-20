import { TreatmentTypes } from '@/data/treatment-type';
import { PrismaClient } from '@prisma/client';

export const seedTreatments = async (prisma: PrismaClient) => {
  // Clean up existing data
  await prisma.treatmentType.deleteMany({});

  // Create treatment types
  const treatments = await Promise.all([
    prisma.treatmentType.createMany({
      data: TreatmentTypes,
      skipDuplicates: true,
    }),
  ]);

  return treatments;
};
