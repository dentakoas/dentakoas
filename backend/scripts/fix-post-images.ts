import { PrismaClient } from '@prisma/client';
import { faker } from '@faker-js/faker';

// Helper function to check if value is boolean-like
const isBooleanValue = (value: any): boolean => {
  if (typeof value === 'boolean') return true;
  if (value === 'true' || value === 'false') return true;
  return false;
};

export async function fixPostImages() {
  console.log('Starting to fix boolean image values in Post table...');
  const prisma = new PrismaClient();

  try {
    // Get all posts
    const posts = await prisma.post.findMany({
      select: {
        id: true,
        title: true,
        images: true,
        treatment: {
          select: {
            name: true,
          },
        },
      },
    });

    console.log(`Found ${posts.length} posts to check for image issues`);
    let fixedCount = 0;

    // Process each post
    for (const post of posts) {
      // Check if images is a boolean value
      if (isBooleanValue(post.images)) {
        console.log(`Post ${post.id} has boolean image value: ${post.images}`);

        // Generate array of 1-3 dental images related to the treatment
        const imageCount = faker.number.int({ min: 1, max: 3 });
        const treatmentName = post.treatment?.name || 'dental';

        // Update the post with the new images
        const images = Array.from({ length: imageCount }, () =>
          faker.image.urlPicsumPhotos({})
        );

        await prisma.post.update({
          where: { id: post.id },
          data: {
            images: images,
          },
        });

        console.log(`Updated post ${post.id} with ${imageCount} new images`);
        fixedCount++;
      }
    }

    if (fixedCount === 0) {
      console.log('No posts found with boolean image values');
    } else {
      console.log(
        `Successfully fixed ${fixedCount} posts with boolean image values`
      );
    }
  } catch (error) {
    console.error('Error fixing post images:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the function
fixPostImages().catch((e) => {
  console.error(e);
  process.exit(1);
});
