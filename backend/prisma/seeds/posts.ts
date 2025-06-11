import { PrismaClient, StatusPost } from '@prisma/client';
import { faker } from '@faker-js/faker';
import {
  PostWithRelations,
  KoasProfileWithUser,
  TreatmentSeedData,
} from '../types/seeding';
import { getRandomPostImages } from '../../utils/cloudinaryHelper';
import { koasUser } from '../data/users'; // pastikan import ini

export const seedPosts = async (
  prisma: PrismaClient,
  treatments: TreatmentSeedData[]
): Promise<PostWithRelations[]> => {
  try {
    // Clean up existing data
    await prisma.post.deleteMany({});

    // Get all approved koas profiles
    const koasProfiles = (await prisma.koasProfile.findMany({
      where: { status: 'Approved' },
      include: {
        user: true,
      },
    })) as KoasProfileWithUser[];

    if (koasProfiles.length === 0) {
      console.log('No approved koas profiles found. Skipping post creation.');
      return [];
    }

    // Ensure we have treatments to work with
    if (!treatments || treatments.length === 0) {
      console.log('No treatments found. Skipping post creation.');
      return [];
    }

    const posts: PostWithRelations[] = [];

    // Buat 1 post untuk setiap koasUser, desc & image sesuai data
    for (const koas of koasUser) {
      // Cari koasProfile yang email-nya sama
      const koasProfile = koasProfiles.find(
        (kp) => kp.user?.email?.toLowerCase() === koas.email.toLowerCase()
      );
      if (!koasProfile) continue;

      // Pilih treatment random
      const treatment = faker.helpers.arrayElement(treatments);

      // Title random
      const titles = [
        `Mencari Pasien untuk ${treatment.name}`,
        `${treatment.alias} - Butuh Partisipan`,
        `Program ${treatment.name} oleh KOAS UNJ`,
        `${treatment.name} - Gratis untuk Pasien Terpilih`,
        `Jadwal Terbuka: ${treatment.alias}`,
      ];
      const title = faker.helpers.arrayElement(titles);

      // Patient requirement random
      const numRequirements = faker.helpers.rangeToNumber({ min: 2, max: 5 });
      const patientRequirements: string[] = [];
      const possibleRequirements = [
        'Tidak memiliki riwayat penyakit jantung',
        'Tidak sedang mengonsumsi obat pengencer darah',
        'Tidak memiliki alergi anestesi',
        'Tidak sedang hamil',
        'Usia minimal 18 tahun',
        'Tidak memiliki infeksi gusi akut',
        'Sudah pernah melakukan pemeriksaan gigi sebelumnya',
        'Tidak memiliki riwayat diabetes',
        'Tidak mengalami tekanan darah tinggi',
        'Bersedia mengikuti instruksi pasca perawatan',
        'Membawa KTP',
        'Bersedia Review',
        'Membawa Tissue',
      ];
      for (let j = 0; j < numRequirements; j++) {
        const req = faker.helpers.arrayElement(possibleRequirements);
        if (!patientRequirements.includes(req)) {
          patientRequirements.push(req);
        }
      }

      // Required participant random
      const requiredParticipant = faker.helpers.rangeToNumber({
        min: 3,
        max: 10,
      });

      // Set status always 'Open' and createdAt default (today)
      const status: StatusPost = 'Open';
      const published = true;

      try {
        const post = await prisma.post.create({
          data: {
            userId: koasProfile.userId,
            koasId: koasProfile.id,
            treatmentId: treatment.id || '',
            title: title,
            desc: koas.desc,
            images: [koas.img],
            patientRequirement: patientRequirements,
            requiredParticipant: requiredParticipant,
            status: status,
            published: published,
            // createdAt: default (today)
          },
          include: {
            user: {
              include: {
                KoasProfile: true,
              },
            },
            koas: {
              include: {
                user: true,
              },
            },
            treatment: true,
          },
        });

        posts.push({
          ...post,
          likes: 0,
          Schedule: [],
        } as PostWithRelations);
      } catch (error) {
        console.error('Error creating post:', error);
      }
    }

    console.log(`Successfully created ${posts.length} posts`);
    return posts;
  } catch (error) {
    console.error('Error in seedPosts:', error);
    return [];
  }
};
