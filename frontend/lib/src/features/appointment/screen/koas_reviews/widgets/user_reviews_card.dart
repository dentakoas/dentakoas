import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/commons/widgets/koas/rating/rating_bar_indicator.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

// Widget untuk menampilkan satu review
class UserReviewsCard extends StatelessWidget {
  const UserReviewsCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String image;
  final String name;
  final double rating;
  final String comment;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircularImage(
                  padding: 0,
                  image: image,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(name, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Review
        Row(
          children: [
            DRatingBarIndicator(rating: rating),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Align(
          alignment: Alignment.centerLeft,
          child: ReadMoreText(
            comment,
            trimLines: 2,
            trimMode: TrimMode.Line,
            trimExpandedText: ' Show less ',
            trimCollapsedText: ' Show more ',
            moreStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
            lessStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
      ],
    );
  }
}
