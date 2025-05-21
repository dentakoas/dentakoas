import { PrismaClient, User } from '@prisma/client';
import { faker } from '@faker-js/faker';
import { LikeData, PostWithRelations } from '../types/seeding';

export const seedLikes = async (
  prisma: PrismaClient,
  posts: PostWithRelations[]
): Promise<LikeData[]> => {
  // Clean up existing data
  await prisma.like.deleteMany({});

  // Get users who can like posts (pasien and koas)
  const users = await prisma.user.findMany({
    where: {
      OR: [{ role: 'Pasien' }, { role: 'Koas' }],
    },
  });

  const likes: LikeData[] = [];
  const likedPairs = new Set<string>(); // To avoid duplicate likes from the same user on the same post

  // Each post gets 0-20 likes
  for (const post of posts) {
    const numLikes = faker.helpers.rangeToNumber({ min: 0, max: 20 });

    for (let i = 0; i < numLikes; i++) {
      // Select a random user
      const user = faker.helpers.arrayElement(users);

      // Check if this user already liked this post
      const pairKey = `${user.id}-${post.id}`;
      if (likedPairs.has(pairKey)) {
        continue; // Skip duplicate like
      }

      likedPairs.add(pairKey);

      try {
        const like = await prisma.like.create({
          data: {
            postId: post.id,
            userId: user.id,
            createdAt: faker.date.between({
              from: post.createdAt,
              to: new Date(),
            }),
          },
        });

        likes.push(like);
      } catch (error) {
        console.error(
          `Error creating like for post ${post.id} by user ${user.id}:`,
          error
        );
      }
    }
  }

  console.log(`Successfully created ${likes.length} likes`);
  return likes;
};
