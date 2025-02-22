import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_koas.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/post_library_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllPostScreen extends StatelessWidget {
  const AllPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    final searchController = Get.put(SearchPostController());
    return Scaffold(
      appBar: const DAppBar(
        title: Text('All Post'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace / 2),
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return DGridLayout(
                  itemCount:
                      searchController.filteredPosts.isNotEmpty
                      ? controller.posts.length
                      : 3,
                  mainAxisExtent: 240,
                  crossAxisCount: 1,
                  itemBuilder: (_, index) {
                    return const ShimmerPostCard();
                  },
                );
              }
              if (searchController.filteredPosts.isEmpty) {
                return SortableField(
                  crossAxisCount: 1,
                  mainAxisExtent: 400,
                  showSearchBar: true,
                  itemBuilder: (_, index) {
                    final post = searchController.filteredPosts[index];
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const StateScreen(
                        image: TImages.emptySearch2,
                        title: "Post not found",
                        subtitle: "Oppss. There is no post found.",
                      ),
                );
                  },
                );
              }
              return SortableField(
                crossAxisCount: 1,
                mainAxisExtent: 680,
                showSearchBar: true,
                itemBuilder: (_, index) { 
                  final post = searchController.filteredPosts[index];
                  return PostCard(
                    postId: post.id,
                    name: post.user.fullName,
                    image: post.user.image ?? TImages.userProfileImage2,
                    postImages: post.postImages,
                    university: post.user.koasProfile!.university!,
                    title: post.title,
                    description: post.desc,
                    category: post.treatment.alias,
                    timePosted: timeago.format(post.updateAt),
                    participantCount: post.totalCurrentParticipants,
                    requiredParticipant: post.requiredParticipant,
                    dateStart: post.schedule.isNotEmpty
                        ? DateFormat('dd').format(post.schedule[0].dateStart)
                        : 'N/A',
                    dateEnd: post.schedule.isNotEmpty
                        ? DateFormat('dd MMM yyyy')
                            .format(post.schedule[0].dateEnd)
                        : 'N/A',
                    likesCount: post.likeCount ?? 0,
                    onTap: () =>
                        Get.to(() => const PostDetailScreen(), arguments: post),
                    onPressed: () =>
                        Get.to(() => const PostDetailScreen(), arguments: post),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

