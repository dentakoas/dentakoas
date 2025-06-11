 

import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/post_library_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/general.information/create_general_information.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/card_post_user.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/my_posts_screen.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    final statusKoas = UserController.instance.user.value.koasProfile?.status;

    return Scaffold(
      appBar: DAppBar(
        title: const Text('Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconButton(
              icon: const Icon(Iconsax.add_circle),
              onPressed: () {
                if (statusKoas == 'Pending') {
                  TLoaders.warningSnackBar(
                    title: 'Pending Status',
                    message:
                        'Your profile verification is still pending. Please wait until your profile is approved by your fasilitator.',
                  );
                } else {
                  Get.to(() => const CreateGeneralInformation());
                }
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return DGridLayout(
            itemCount:
                controller.postUser.isNotEmpty ? controller.postUser.length : 3,
            mainAxisExtent: 400,
            crossAxisCount: 1,
            itemBuilder: (_, index) {
              return const ShimmerPostCard();
            },
          );
        }
        if (controller.postUser.isEmpty) {
          if (statusKoas == 'Pending') {
            return const StateScreen(
              image: TImages.emptyPost,
              title: 'Pending Status',
              subtitle:
                  'Your profile verification is still pending. Please wait until your profile is approved by your fasilitator.',
            );
          } else {
            return GestureDetector(
              onTap: () => Get.to(() => const CreateGeneralInformation()),
              child: const StateScreen(
                image: TImages.emptyPost,
                title: 'Empty Post',
                subtitle: 'You don\'t have any post yet. Click to create one.',
              ),
            );
          }
        }

        return GestureDetector(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  SectionHeading(
                    title: '',
                    showActionButton: true,
                    onPressed: () {
                      Get.to(() => const MyPostsScreen());
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  DGridLayout(
                    crossAxisCount: 1,
                    mainAxisExtent: 250,
                    itemCount: controller.postUser.length,
                    itemBuilder: (context, index) {
                      final post = controller.postUser[index];
                      return CardPostUser(
                        title: post.title,
                        desc: post.desc,
                        treatment: post.treatment.alias,
                        status: post.status.toString().split('.').last,
                        statusColor: post.status == "Pending"
                            ? Colors.orange
                            : post.status == "Open"
                                ? Colors.green
                                : Colors.red,
                        updatedAt: post.updateAt,
                        onTap: () => Get.to(() => const PostDetailScreen(),
                            arguments: post),
                        post: post,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
