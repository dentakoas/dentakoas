import { PrismaClient } from '@prisma/client';

export const seedPosts = async (
  prisma: PrismaClient,
  users: any,
  treatments: any
) => {
  // Clean up existing data
  await prisma.post.deleteMany({});

  // Extract user IDs
  const koasUsers = users.koasUsers;

  // Sample post descriptions
  const postDescriptions = [
    'Looking for patients who need dental cleaning. Treatment will be supervised by a senior dentist.',
    'Root canal treatment available for patients with tooth decay or infection. Supervised by Dr. Ahmad.',
    'Offering dental fillings for cavities. This is part of my clinical practice requirement.',
    'Need patients for orthodontic consultation and treatment planning. Will be supervised by specialists.',
    'Wisdom tooth extraction service available. This is part of my surgical dentistry module.',
    'Seeking patients for complete dental check-up and cleaning as part of my clinical assessment.',
    'Offering teeth whitening treatment. Looking for patients with mild to moderate discoloration.',
    'Gum disease treatment available. Seeking patients with gingivitis or early periodontitis.',
    'Dental crown preparation and fitting service. Need patients with damaged teeth.',
    'Pediatric dental care available. Looking for children aged 6-12 for routine check-ups.',
  ];

  // Create posts for each koas user
  const posts = [];

  for (let i = 0; i < koasUsers.length; i++) {
    const koas = koasUsers[i];

    // Create 2-3 posts for each koas
    const numPosts = 2 + Math.floor(Math.random() * 2); // 2 or 3 posts

    for (let j = 0; j < numPosts; j++) {
      const treatmentIndex = Math.floor(Math.random() * treatments.length);
      const treatment = treatments[treatmentIndex];

      const descIndex = Math.floor(Math.random() * postDescriptions.length);
      const description = postDescriptions[descIndex];

      const requiredParticipants = 2 + Math.floor(Math.random() * 5); // 2-6 participants

      const post = await prisma.post.create({
        data: {
          userId: koas.id,
          koasId: koas.KoasProfile.id,
          treatmentId: treatment.id,
          title: `${treatment.name} Service by ${koas.name}`,
          desc: description,
          images: JSON.stringify(['/data/post-image.jpg']),
          patientRequirement: JSON.stringify({
            ageMin: 18,
            ageMax: 60,
            conditions: ['No severe heart disease', 'No uncontrolled diabetes'],
          }),
          requiredParticipant: requiredParticipants,
          status: 'Open',
          published: true,
        },
      });

      posts.push(post);
    }
  }

  return posts;
};
