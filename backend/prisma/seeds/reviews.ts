import { PrismaClient } from '@prisma/client';

export const seedReviews = async (
  prisma: PrismaClient,
  users: any,
  posts: any
) => {
  // Clean up existing data
  await prisma.review.deleteMany({});

  const pasienUsers = users.pasienUsers;

  // Review comments
  const reviewComments = [
    'Great service! Very professional and gentle approach.',
    'The treatment was excellent, and the koas was very knowledgeable.',
    'Very satisfied with the procedure. Will definitely come back again.',
    'The koas was very thorough and explained everything clearly.',
    'Good service overall, but had to wait a bit longer than expected.',
    'Very friendly and patient. Made me feel comfortable throughout the procedure.',
    'Excellent care and attention to detail.',
    'Highly recommend! The treatment was painless and effective.',
    'Very professional service. The koas was well-prepared and confident.',
    'Good job with the treatment. No complaints.',
  ];

  const reviews = [];

  // Create reviews for completed appointments
  const completedAppointments = await prisma.appointment.findMany({
    where: { status: 'Completed' },
    include: {
      pasien: { include: { user: true } },
      koas: { include: { user: true } },
      schedule: { include: { post: true } },
    },
  });

  for (const appointment of completedAppointments) {
    // 80% chance of having a review
    if (Math.random() < 0.8) {
      // Random rating between 3.5 and 5.0
      const rating = (3.5 + Math.random() * 1.5).toFixed(1);

      // Random comment
      const commentIndex = Math.floor(Math.random() * reviewComments.length);
      const comment = reviewComments[commentIndex];

      const review = await prisma.review.create({
        data: {
          postId: appointment.schedule.post.id,
          pasienId: appointment.pasien.user.id,
          koasId: appointment.koas.userId,
          rating: rating,
          comment: comment,
        },
      });

      reviews.push(review);
    }
  }

  // Add some additional reviews for posts without appointments
  for (const post of posts) {
    const existingReviews = await prisma.review.count({
      where: { postId: post.id },
    });

    // If no reviews yet, add a couple
    if (existingReviews === 0 && Math.random() < 0.7) {
      // Pick 1-2 random pasien users
      const numReviews = 1 + Math.floor(Math.random() * 2);

      for (let i = 0; i < numReviews; i++) {
        const pasienIndex = Math.floor(Math.random() * pasienUsers.length);
        const pasien = pasienUsers[pasienIndex];

        // Get the koas from the post
        const postDetails = await prisma.post.findUnique({
          where: { id: post.id },
          include: { koas: { include: { user: true } } },
        });

        if (postDetails && postDetails.koas) {
          // Random rating and comment
          const rating = (3.0 + Math.random() * 2.0).toFixed(1);
          const commentIndex = Math.floor(
            Math.random() * reviewComments.length
          );
          const comment = reviewComments[commentIndex];

          const review = await prisma.review.create({
            data: {
              postId: post.id,
              pasienId: pasien.id,
              koasId: postDetails.koas.userId,
              rating: rating,
              comment: comment,
            },
          });

          reviews.push(review);
        }
      }
    }
  }

  return reviews;
};
