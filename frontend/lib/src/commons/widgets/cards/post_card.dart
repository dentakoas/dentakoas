import 'package:denta_koas/src/commons/widgets/cards/widget/post/footer.dart';
import 'package:denta_koas/src/commons/widgets/cards/widget/post/header.dart';
import 'package:denta_koas/src/commons/widgets/cards/widget/post/stat.dart';
import 'package:denta_koas/src/commons/widgets/cards/widget/post/title.dart';
import 'package:denta_koas/src/commons/widgets/images/rounded_image_container.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostCard extends StatelessWidget {
 
  final String postId;
  final String name,
      image,
      university,
      title,
      description,
      category,
      timePosted,
      dateStart,
      dateEnd;
  final List<String>? postImages;
  final int requiredParticipant, participantCount, likesCount;
  final bool isNetworkImage;
  final void Function()? onPressed;
  final void Function()? onTap;

  const PostCard({
    super.key,
    required this.postId,
    required this.name,
    required this.image,
    required this.university,
    required this.title,
    this.postImages,
    required this.description,
    required this.category,
    required this.timePosted,
    required this.participantCount,
    required this.requiredParticipant,
    this.likesCount = 0,
    this.isNetworkImage = false,
    required this.dateStart,
    required this.dateEnd,
    this.onPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(
                postId: postId,
                name: name,
                image: image,
                university: university,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (postImages != null) ...[
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: postImages!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.dialog(
                            Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundedImage(
                                    padding: const EdgeInsets.all(0),
                                    borderRadius: 6,
                                    imageUrl: postImages![index],
                                    isNetworkImage: true,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: RoundedImage(
                          padding: const EdgeInsets.all(0),
                          borderRadius: 6,
                          imageUrl: postImages![index],
                          isNetworkImage: true,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],
              TitleSection(
                  timePosted: timePosted,
                  title: title,
                  description: description),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              StatsSection(
                participantCount: participantCount,
                requiredParticipant: requiredParticipant,
                category: category,
                likesCount: likesCount,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              FooterSection(
                  dateStart: dateStart,
                  dateEnd: dateEnd,
                  likesCount: likesCount,
                  onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}

