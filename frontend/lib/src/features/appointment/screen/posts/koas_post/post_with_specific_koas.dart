import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_koas.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/cards/doctor_card.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostWithSpecificKoas extends StatelessWidget {
  const PostWithSpecificKoas({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil UserModel koas dari arguments
    final koas = Get.arguments;
    final controller = Get.put(PostController());

    // Filter posts milik userId koas
    final posts =
        controller.posts.where((post) => post.user.id == koas.id).toList();
    final user = posts.isNotEmpty ? posts.first.user : koas;

    return Scaffold(
      appBar: const DAppBar(
        title: Text('Koas Post'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts =
            controller.posts.where((post) => post.user.id == koas.id).toList();
        if (posts.isEmpty) {
          return const Center(child: Text('No posts found for this Koas.'));
        }
        final user = posts.first.user;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                KoasCard(
                  name: user.fullName,
                  university: user.koasProfile?.university ?? '-',
                  distance: '-',
                  rating: user.koasProfile?.stats?.averageRating ?? 0,
                  totalReviews: user.koasProfile?.stats?.totalReviews ?? 0,
                  image: user.image ?? TImages.user,
                  hideButton: true,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                if (posts.isNotEmpty)
                  SortableField(
                    itemCount: posts.length,
                    crossAxisCount: 1,
                    mainAxisExtent: 330,
                    itemBuilder: (_, index) {
                      if (index >= posts.length) return const SizedBox.shrink();
                      final post = posts[index];
                      return PostCard(
                        postId: post.id,
                        name: user.fullName,
                        university: user.koasProfile?.university ?? '-',
                        image: user.image ?? TImages.user,
                        postImages: post.postImages,
                        timePosted: post.updateAt.toString(),
                        title: post.title,
                        description: post.desc,
                        category: post.treatment.alias,
                        participantCount: post.totalCurrentParticipants,
                        requiredParticipant: post.requiredParticipant,
                        dateStart: post.schedule.isNotEmpty
                            ? post.schedule[0].dateStart.toString()
                            : '-',
                        dateEnd: post.schedule.isNotEmpty
                            ? post.schedule[0].dateEnd.toString()
                            : '-',
                        likesCount: post.likeCount ?? 0,
                        onTap: () => Get.to(() => const PostDetailScreen(),
                            arguments: post),
                        onPressed: () => Get.to(() => const PostDetailScreen(),
                            arguments: post),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
