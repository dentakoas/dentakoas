import { PrismaClient, StatusPost } from '@prisma/client';
import { faker } from '@faker-js/faker';
import {
  PostWithRelations,
  KoasProfileWithUser,
  TreatmentSeedData,
} from '../types/seeding';
import { getRandomPostImages } from '../../utils/cloudinaryHelper';

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
    const now = new Date();
    const totalPostsToCreate = 50; // Create 50 posts

    for (let i = 0; i < totalPostsToCreate; i++) {
      // Select a random koas
      const koas = faker.helpers.arrayElement(koasProfiles);

      // Select a random treatment
      const treatment = faker.helpers.arrayElement(treatments);

      // Generate 1-3 random images for the post
      const numImages = faker.helpers.rangeToNumber({ min: 1, max: 3 });

      // Prefer the new images for most posts (80% chance)
      const useNewImages = faker.helpers.weightedArrayElement([
        { value: true, weight: 80 },
        { value: false, weight: 20 },
      ]);

      // Get post images, preferring new ones if specified
      const postImages = useNewImages;

      getRandomPostImages(numImages, false);

      // Generate 2-5 patient requirements
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

      // Generate required participants (3-10)
      const requiredParticipant = faker.helpers.rangeToNumber({
        min: 3,
        max: 10,
      });

      // Create post title based on treatment
      const titles = [
        `Mencari Pasien untuk ${treatment.name}`,
        `${treatment.alias} - Butuh Partisipan`,
        `Program ${treatment.name} oleh KOAS UNJ`,
        `${treatment.name} - Gratis untuk Pasien Terpilih`,
        `Jadwal Terbuka: ${treatment.alias}`,
      ];
      const title = faker.helpers.arrayElement(titles);

      // Post description
      const desc = faker.lorem.paragraph().substring(0, 500);

      // 70% chance post is published
      const published = faker.helpers.weightedArrayElement([
        { value: true, weight: 70 },
        { value: false, weight: 30 },
      ]);

      // Post status based on publishing state
      let status: StatusPost;
      if (!published) {
        status = 'Pending';
      } else {
        // For published posts, 70% Open, 30% Closed
        status = faker.helpers.weightedArrayElement([
          { value: 'Open' as StatusPost, weight: 70 },
          { value: 'Closed' as StatusPost, weight: 30 },
        ]);
      }

      try {
        const post = await prisma.post.create({
          data: {
            userId: koas.userId,
            koasId: koas.id,
            treatmentId: treatment.id || '', // Ensure we have an ID
            title: title,
            desc: desc,
            // Use Cloudinary images
            images: postImages, // Use the selected Cloudinary images
            patientRequirement: patientRequirements, // Prisma will handle JSON conversion
            requiredParticipant: requiredParticipant,
            status: status,
            published: published,
            createdAt: faker.date.recent({ days: 90 }),
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
