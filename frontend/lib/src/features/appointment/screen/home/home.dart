import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_post.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/header/home_appbar.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/home_banner_section.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/home_popular_koas.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/home_popular_section.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/home_upcoming_schedule_section.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchPostController());
    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: controller.isSearching.value
              ? SingleChildScrollView(
                  key: const ValueKey('searching'),
                  child: Column(children: [
                    const HomeAppBar(),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.defaultSpace / 2),
                      child: SortablePostList(
                        posts: controller.filteredPosts,
                      ),
                    ),
                  ]),
                )
              : const SingleChildScrollView(
                  key: ValueKey('notSearching'),
                  child: Column(
                    children: [
                      HomeAppBar(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      HomeBannerSection(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      HomeUpcomingScheduleSection(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      HomePopularCategoriesSection(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      HomePopularKoasSection(),
                    ],
                  ),
                ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     controller.isSearching.value = !controller.isSearching.value;
      //   },
      //   child: Icon(controller.isSearching.value ? Icons.list : Icons.search),
      // ),
    );
  }
}
