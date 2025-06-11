import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.postUser.isEmpty) {
          return const StateScreen(
            image: TImages.emptyCalendar,
            title: 'No Posts Found',
            subtitle: 'You have not created any posts yet.',
            isLottie: false,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.postUser.length,
          itemBuilder: (context, index) {
            final post = controller.postUser[index];
            return PostCard(
              postId: post.id,
              name: post.user.fullName,
              image: post.user.image ?? TImages.user,
              university: post.user.koasProfile?.university ?? '-',
              title: post.title,
              postImages: post.postImages,
              description: post.desc,
              category: post.treatment.alias,
              timePosted: post.createdAt != null
                  ? TFormatter.formatDate(post.createdAt)
                  : '-',
              participantCount: post.totalCurrentParticipants,
              requiredParticipant: post.requiredParticipant,
              likesCount: post.likes.length,
              isNetworkImage: true,
              dateStart: post.schedule.isNotEmpty
                  ? TFormatter.formatDate(post.schedule.first.dateStart)
                  : '-',
              dateEnd: post.schedule.isNotEmpty
                  ? TFormatter.formatDate(post.schedule.first.dateEnd)
                  : '-',
              showJoinButton:
                  UserController.instance.user.value.id != post.user.id,
              onTap: () {
                Get.to(() => const PostDetailScreen(), arguments: post);
              },
            );
          },
        );
      }),
    );
  }
}
