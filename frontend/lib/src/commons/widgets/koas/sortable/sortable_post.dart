import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_koas.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class SortablePostList extends StatelessWidget {
  final List<Post> posts;

  final double mainAxisExtent;
  final bool showSearchBar;
  final Function(Post)? onPostTap;
  final Function(Post)? onPostPressed;

  const SortablePostList({
    super.key,
    required this.posts,
    this.mainAxisExtent = 680,
    this.showSearchBar = true,
    this.onPostTap,
    this.onPostPressed,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchPostController());

    return SortableField(
      crossAxisCount: 1,
      mainAxisExtent: mainAxisExtent,
      showSearchBar: showSearchBar,
      itemBuilder: (_, index) {
        final post = searchController.filteredPosts[index];
        return PostCard(
              postId: post.id,
              name: post.user.fullName,
              image: post.user.image ?? TImages.userProfileImage2,
              postImages: post.postImages,
              university: post.user.koasProfile?.university ?? '',
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
                  ? DateFormat('dd MMM yyyy').format(post.schedule[0].dateEnd)
                  : 'N/A',
              likesCount: post.likeCount ?? 0,
              onTap: onPostTap != null ? () => onPostTap!(post) : null,
              onPressed:
                  onPostPressed != null ? () => onPostPressed!(post) : null,
        );
      },
    );
  }
}
