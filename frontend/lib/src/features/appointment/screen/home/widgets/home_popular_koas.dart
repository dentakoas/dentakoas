import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/koas_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/screen/dentist/all_koas.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/cards/doctor_card.dart';
import 'package:denta_koas/src/features/appointment/screen/koas/koas_details/koas_detail.dart';
import 'package:denta_koas/src/features/personalization/controller/koas_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePopularKoasSection extends StatelessWidget {
  const HomePopularKoasSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KoasController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Heading
          SectionHeading(
            title: 'Popular Koas',
            showActionButton: true,
            onPressed: () => Get.to(() => const AllKoasScreen()),
          ),

          // Popular Koas
          Obx(
            () {
              if (controller.isLoading.value) {
                return DGridLayout(
                  itemCount: 2,
                  mainAxisExtent: 205,
                  crossAxisCount: 1,
                  itemBuilder: (_, index) {
                    return const KoasCardShimmer();
                  },
                );
              }
              if (controller.popularKoas.isEmpty) {
                return KoasCard(
                  name: 'Dr. John Doe',
                  university: 'University of Lagos',
                  distance: '1 KM',
                  rating: 4.5,
                  totalReviews: 100,
                  image: TImages.userProfileImage3,
                  onTap: () => Get.to(() => const KoasDetailScreen()),
                );
                // return const KoasCardShimmer();
              }
              return DGridLayout(
                itemCount: controller.popularKoas.length,
                crossAxisCount: 1,
                mainAxisExtent: 210,
                itemBuilder: (_, index) {
                  final popularKoas = controller.popularKoas[index];
                  return KoasCard(
                    name: popularKoas.fullName,
                    university: popularKoas.koasProfile!.university!,
                    distance: '1 KM',
                    rating: popularKoas.koasProfile!.stats!.averageRating,
                    totalReviews: popularKoas.koasProfile!.stats!.totalReviews,
                    image: popularKoas.image ?? TImages.user,
                    onTap: () => Get.to(
                      () => const KoasDetailScreen(),
                      arguments: popularKoas,
                    ),
                  );
                },
              );
            }, 
          ),
        ],
      ),
    );
  }
}
