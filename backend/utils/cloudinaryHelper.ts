import { faker } from '@faker-js/faker';

// Dental treatment images
export const treatmentImages = {
  'Regular Checkup':
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/dental-check_mwxzul.png',
  Scaling:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/scaling_hzca8n.png',
  'Root Canal':
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/root-canal_w4knms.png',
  Filling:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262996/avatars/filling_abxhlv.png',
  Extraction:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/extraction_hmaptl.png',
  Bleaching:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/bleaching_b2tn3f.png',
  Braces:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/braces_tahpip.png',
  'Gum Treatment':
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262996/avatars/gum_rpwvi9.png',
  Dentures:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/denture_y3rlpq.png',
  Implant:
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262996/avatars/implant_tasdvi.png',
};

// Fixed post images from Cloudinary
export const cloudinaryPostImages = [
  'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1752358200/7938868b3f87a5774176f1d08b4f441e.jpg',
  'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1752358201/f80b26ba2c658623d83e5fbd3f4b6ff6.jpg',
  'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1752358203/562e01bdc3d519a4eca522a3d7b46897.jpg',
  'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1752358204/3aa63e31d7b829c90e33fabfec00db9f.jpg',
  'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1752358206/ac1042305c199be9c8322c416b178158.jpg',
];

// Dental-related categories for dynamic image generation
const dentalCategories = [
  'dental',
  'dentist',
  'teeth',
  'clinic',
  'dentistry',
  'medical',
  'healthcare',
  'dental+chair',
  'dental+care',
  'dental+clinic',
];

/**
 * Get a random avatar image using Faker
 */
export function getRandomAvatar(): string {
  return faker.image.avatar();
}

/**
 * Generate a dental-related image URL using faker
 */
export function generateDentalImage(): string {
  const category = faker.helpers.arrayElement(dentalCategories);
  return faker.image.urlLoremFlickr({ category });
}

/**
 * Get a single random post image - can be either from Cloudinary or dynamically generated
 * @param useCloudinaryOnly Whether to only use Cloudinary images
 */
export function getRandomPostImage(useCloudinaryOnly: boolean = false): string {
  if (useCloudinaryOnly) {
    return faker.helpers.arrayElement(cloudinaryPostImages);
  }

  // 70% chance to use Cloudinary images, 30% chance to use dynamically generated images
  return faker.helpers.weightedArrayElement([
    { value: faker.helpers.arrayElement(cloudinaryPostImages), weight: 70 },
    { value: generateDentalImage(), weight: 30 },
  ]);
}

/**
 * Get multiple random post images
 * @param count Number of images to get
 * @param useCloudinaryOnly Whether to only use Cloudinary images
 */
export function getRandomPostImages(
  count: number = 1,
  useCloudinaryOnly: boolean = false
): string[] {
  const images: string[] = [];

  if (useCloudinaryOnly) {
    // Use only Cloudinary images
    const shuffled = [...cloudinaryPostImages].sort(() => 0.5 - Math.random());
    for (let i = 0; i < Math.min(count, shuffled.length); i++) {
      images.push(shuffled[i]);
    }
  } else {
    // Mix of Cloudinary and dynamically generated images
    for (let i = 0; i < count; i++) {
      images.push(getRandomPostImage());
    }
  }

  return images;
}

/**
 * Get only the Cloudinary post images
 * @param count Number of images to get
 */
export function getCloudinaryPostImages(count: number = 1): string[] {
  const shuffled = [...cloudinaryPostImages].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, Math.min(count, cloudinaryPostImages.length));
}

/**
 * Get an image specific to a treatment type
 * @param treatmentAlias The alias of the treatment
 */
export function getTreatmentImage(treatmentAlias: string): string {
  return (
    treatmentImages[treatmentAlias as keyof typeof treatmentImages] ||
    'https://res.cloudinary.com/dxw9ywgfq/image/upload/v1740262995/avatars/dental-check_mwxzul.png'
  );
}

/**
 * Get a random university image using Faker
 */
export function getRandomUniversityImage(): string {
  return faker.image.urlLoremFlickr({ category: 'university,campus,college' });
}
