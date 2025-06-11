import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/partnert/partner_showcase.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/card_showcase_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/post_library_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/explore.controller/explore_post_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/posts.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class TabPost extends StatelessWidget {
  const TabPost({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExplorePostController());
    
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Partners showcase
                  Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const CardShowcaseShimmer();
                      }
                      if (controller.lastChangePost.isEmpty) {
                        return const CardShowcase(
                          title: 'Last change Posts is empty',
                          subtitle:
                              'Unfortunately, there are no last change posts',
                        );
                      }
                      return CardShowcase(
                        title: 'Last Chance',
                        subtitle: 'Find the best koas in your area',
                        images: controller.lastChangePost
                            .take(3)
                            .map((post) => post.user.image ?? TImages.user)
                            .toList(),
                        onTap: () => Get.to(
                            () => const AllPostScreen(filter: 'Last Change')),
                      );
                    },
                  ),
                  Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const CardShowcaseShimmer();
                      }
                      if (controller.newestPosts.isEmpty) {
                        return const CardShowcase(
                          title: 'Newest Posts is empty',
                          subtitle: 'Unfortunately, there are no newest posts',
                        );
                      }
                      return CardShowcase(
                        title: 'Newest Posts',
                        subtitle: 'Find the newest koas in your area',
                        images: controller.newestPosts
                            .take(3)
                            .map((post) => post.user.image ?? TImages.user)
                            .toList(),
                        onTap: () =>
                            Get.to(() => const AllPostScreen(filter: 'newest')),
                      );
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Posts
                  SectionHeading(
                    title: 'You might interest',
                    onPressed: () => Get.to(() => const AllPostScreen()),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return DGridLayout(
                        itemCount: 2,
                        mainAxisExtent: 240,
                        crossAxisCount: 1,
                        itemBuilder: (_, index) {
                          return const ShimmerPostCard();
                        },
                      );
                    }
                    if (controller.featuredPosts.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const StateScreen(
                          image: TImages.emptySearch2,
                          title: "Post not found",
                          subtitle:
                              "Oppss. There is no post with this category",
                        ),
                      );
                    }
                    return DGridLayout(
                      itemCount: controller.featuredPosts.length < 2 ? 1 : 2,
                      crossAxisCount: 1,
                      mainAxisExtent: 680,
                      itemBuilder: (_, index) {
                        final post = controller.featuredPosts[index];
                        return PostCard(
                          postId: post.id,
                          name: post.user.fullName,
                          university: post.user.koasProfile!.university!,
                          image: post.user.image ?? TImages.user,
                          postImages: post.postImages,
                          timePosted: timeago.format(post.updateAt),
                          title: post.title,
                          description: post.desc,
                          category: post.treatment.alias,
                          participantCount: post.totalCurrentParticipants,
                          requiredParticipant: post.requiredParticipant,
                          dateStart: post.schedule.isNotEmpty
                              ? DateFormat('dd')
                                  .format(post.schedule[0].dateStart)
                              : 'N/A',
                          dateEnd: post.schedule.isNotEmpty
                              ? DateFormat('dd MMM yyyy')
                                  .format(post.schedule[0].dateEnd)
                              : 'N/A',
                          likesCount: post.likeCount ?? 0,
                          onTap: () => Get.to(
                            () => const PostDetailScreen(),
                            arguments: post,
                          ),
                          onPressed: () => Get.to(
                            () => const PostDetailScreen(),
                            arguments: post,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
