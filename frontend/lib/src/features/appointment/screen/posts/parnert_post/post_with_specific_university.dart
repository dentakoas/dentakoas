import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/cards/treatment_card.dart';
import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_koas.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWithSpecificUniversity extends StatelessWidget {
  const PostWithSpecificUniversity({super.key});

  @override
  Widget build(BuildContext context) {
    final university = Get.arguments;
    final controller = Get.put(PostController());
    return Scaffold(
      appBar: const DAppBar(
        title: Text('University Post'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TreatmentCard(
                title: university.name,
                showVerifiyIcon: true,
                subtitle: university.alias,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredPosts = controller.posts
                    .where((post) =>
                        post.user.koasProfile?.university == university.name)
                    .toList();
                if (filteredPosts.isEmpty) {
                  return const Center(child: Text('No data'));
                }
                return SortableField(
                  itemCount: filteredPosts.length,
                  crossAxisCount: 1,
                  mainAxisExtent: 400,
                  showDropdownMenu: false,
                  itemBuilder: (_, index) {
                    final post = filteredPosts[index];
                    return PostCard(
                      postId: post.id,
                      name: post.user.fullName,
                      image: post.user.image ?? TImages.user,
                      university: post.user.koasProfile?.university ?? 'N/A',
                      title: post.title,
                      description: post.desc,
                      category: post.treatment.alias,
                      timePosted: timeago.format(post.updateAt),
                      participantCount: post.totalCurrentParticipants,
                      requiredParticipant: post.requiredParticipant,
                      dateStart: _formatDate(post.schedule, true),
                      dateEnd: _formatDate(post.schedule, false),
                      likesCount: post.likeCount ?? 0,
                      onTap: () => Get.to(() => const PostDetailScreen(),
                          arguments: post),
                      onPressed: () => Get.to(() => const PostDetailScreen(),
                          arguments: post),
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(List<dynamic> schedule, bool isStart) {
    if (schedule.isEmpty || schedule[0] == null) return 'N/A';
    final date = isStart ? schedule[0].dateStart : schedule[0].dateEnd;
    if (date == null) return 'N/A';
    return isStart
        ? DateFormat('dd').format(date)
        : DateFormat('dd MMM yyyy').format(date);
  }
}

