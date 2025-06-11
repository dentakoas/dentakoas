import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/university_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/university.controller/university_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/explore/widget/tab_parnert.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/parnert_post/post_with_specific_university.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllUniversitiesScreen extends StatelessWidget {
  const AllUniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UniversityController());
    return Scaffold(
      appBar: const DAppBar(
        title: Text('University'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return DGridLayout(
            itemCount: controller.universityWithImages.isNotEmpty
                ? controller.universityWithImages.length
                : 3,
            mainAxisExtent: 330,
            crossAxisCount: 1,
            itemBuilder: (_, index) {
              return const UniversityCardShimmer();
            },
          );
        }

        if (controller.universityWithImages.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const StateScreen(
              image: TImages.emptySearch2,
              title: "University not found",
              subtitle: "Oppss. There is no university found.",
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                // Categories
                DGridLayout(
                  itemCount: controller.universityWithImages.length,
                  crossAxisCount: 1,
                  mainAxisExtent: 330,
                  itemBuilder: (_, index) {
                    final university = controller.universityWithImages[index];
                    return UniversityCard(
                      title: university.name,
                      subtitle: university.alias,
                      address: university.location,
                      distance: '1.5km',
                      time: '15 min',
                      koasCount: university.koasCount,
                      // Use getImageWithFallback for university images
                      image: UserController.instance.getImageWithFallback(
                        university.image,
                        'university',
                      ),
                      onTap: () => Get.to(
                        () => const PostWithSpecificUniversity(),
                        arguments: university,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
