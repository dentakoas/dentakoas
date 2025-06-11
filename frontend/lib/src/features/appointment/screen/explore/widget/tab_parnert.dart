import 'package:denta_koas/src/commons/widgets/images/rounded_image_container.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/partnert/partner_showcase.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/card_showcase_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/university_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/university.controller/university_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/parnert_post/post_with_specific_university.dart';
import 'package:denta_koas/src/features/appointment/screen/universities/all_universities.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TabParnert extends StatelessWidget {
 
  const TabParnert({
    super.key,
  });
  

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UniversityController());

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // 🔥 Popular Universities Showcase
              Obx(() {
                if (controller.isLoading.isTrue) {
                  return const CardShowcaseShimmer();
                }
                if (controller.popularUniversities.isEmpty) {
                  return const CardShowcase(
                    title: 'Popular Universities is empty',
                    subtitle:
                        'Unfortunately, there are no popular universities',
                  );
                }

                final popularImages = controller.popularUniversities
                    .take(3)
                    .map((university) => university.image)
                    .whereType<String>()
                    .toList();

                return const CardShowcase(
                  title: 'Our Top Partners',
                  subtitle: 'Find the best partners in your area',
                  images: [
                    TImages.defaultUniversity,
                    TImages.defaultUniversity,
                    TImages.defaultUniversity,
                  ],
                );
              }),

              const SizedBox(height: TSizes.spaceBtwItems),

              // 🔥 Newest Universities Showcase
              Obx(() {
                if (controller.isLoading.isTrue) {
                  return const CardShowcaseShimmer();
                }
                if (controller.newestUniversities.isEmpty) {
                  return const CardShowcase(
                    title: 'Newest Universities is empty',
                    subtitle: 'Unfortunately, there are no newest universities',
                  );
                }

                final newestImages = controller.newestUniversities
                    .take(3)
                    .map((university) => university.image)
                    .whereType<String>()
                    .toList();

                return const CardShowcase(
                  title: 'Newest Universities',
                  subtitle: 'Check out the latest universities',
                  images: [
                    TImages.defaultUniversity,
                    TImages.defaultUniversity,
                    TImages.defaultUniversity,
                  ],
                );
              }),

              const SizedBox(height: TSizes.spaceBtwItems),

              // 🔥 Section Heading
              SectionHeading(
                title: 'You might interest',
                onPressed: () => Get.to(() => const AllUniversitiesScreen()),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // 🔥 Featured Universities List
              Obx(() {
                if (controller.isLoading.value) {
                  return DGridLayout(
                    itemCount: controller.featuredUniversities.length,
                    mainAxisExtent: 330,
                    crossAxisCount: 1,
                    itemBuilder: (_, index) {
                      return const UniversityCardShimmer();
                    },
                  );
                }
                if (controller.featuredUniversities.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const StateScreen(
                      image: TImages.emptySearch2,
                      title: "Parnert not found",
                      subtitle: "Oppss. There is no post with this category",
                    ),
                  );
                }

                return DGridLayout(
                  itemCount: controller.featuredUniversities.length,
                  crossAxisCount: 1,
                  mainAxisExtent: 330,
                  itemBuilder: (_, index) {
                    final university = controller.featuredUniversities[index];
                    return UniversityCard(
                      image: Faker()
                          .image
                          .loremPicsum(random: 1, width: 200, height: 200),
                      title: university.name,
                      subtitle: university.alias,
                      address: university.location,
                      distance: '1.5km',
                      time: '15 min',
                      koasCount: university.koasCount,
                      onTap: () => Get.to(
                        () => const PostWithSpecificUniversity(),
                        arguments: university,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

}

class UniversityCard extends StatelessWidget {
  const UniversityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.address,
    required this.distance,
    required this.time,
    required this.koasCount,
    required this.image,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String address;
  final String distance;
  final String time;
  final int koasCount;
  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with fallback handling
            RoundedImage(
              width: double.infinity,
              height: 150,
              isNetworkImage: image.isNotEmpty && image.startsWith('http'),
              imageUrl: image.isNotEmpty
                  ? image
                  : Faker()
                      .image
                      .loremPicsum(random: 1, width: 200, height: 200),
              applyImageRadius: true,
              borderRadius: 10,
              fit: BoxFit.cover,
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.favorite_border, color: Colors.white),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                color: Colors.black54,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.person_2_fill,
                        color: TColors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '$koasCount Koas',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Iconsax.location5,
                          size: 14, color: TColors.primary),
                      const SizedBox(width: 5),
                      Text(address),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Iconsax.clock5,
                          size: 14, color: TColors.primary),
                      const SizedBox(width: 5),
                      Text('$time • $distance'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
