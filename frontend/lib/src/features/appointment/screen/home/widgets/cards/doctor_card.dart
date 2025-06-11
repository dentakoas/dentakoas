import 'package:denta_koas/src/commons/widgets/koas/rating/rating_bar_indicator.dart';
import 'package:denta_koas/src/commons/widgets/text/title_with_verified.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/koas_post/post_with_specific_koas.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/enums.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KoasCard extends StatelessWidget {
  final String name;
  final String university;
  final String distance;
  final double rating;
  final int totalReviews;
  final String image;
  final void Function()? onTap;
  final bool hideButton;

  const KoasCard({
    super.key,
    required this.name,
    required this.university,
    required this.distance,
    required this.rating,
    required this.totalReviews,
    required this.image,
    this.onTap,
    this.hideButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
            bottom: TSizes.spaceBtwItems), // Adjust spacing between cards
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TColors.textWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image Profile
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 100,
                    color:
                        Colors.grey[200], // Placeholder color for missing image
                    child: image.startsWith('http')
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                      image,
                      fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),

                // Doctor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Doctor Name
                      Row(children: [
                        Expanded(
                          child: Text(
                            name,
                            style:
                                Theme.of(context).textTheme.titleMedium!.apply(
                                      color: TColors.textPrimary,
                                    ),
                          ),
                          
                        ),
                        const Icon(Icons.location_on,
                            size: TSizes.iconSm, color: TColors.primary),
                        Text(
                          distance,
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                                color: TColors.textSecondary,
                              ),
                        ),
                      ]),
                      const SizedBox(height: 4),

                      // University and Distance
                      Row(
                        children: [
                          Expanded(
                            child: TitleWithVerified(
                              title: university,
                              textSizes: TextSizes.small,
                              showIcon: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Rating and Open Time
                      Row(
                        children: [
                          // Rating Section
                          Row(
                            children: [
                              DRatingBarIndicator(
                                rating: rating,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating',
                                style: const TextStyle(
                                  fontSize: TSizes.fontSizeSm,
                                  color: TColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Divider
                          Container(
                            width: 2,
                            height: TSizes.iconBase,
                            color: TColors.grey,
                          ),
                          const SizedBox(width: 6),

                          // Open Time
                          Text(
                            '$totalReviews Reviews',
                            style: const TextStyle(
                              fontSize: TSizes.fontSizeSm,
                              color: TColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Full-width Button
            if (!hideButton)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {
                    if (onTap != null) {
                      onTap!();
                    } else {
                      // Navigasi ke PostWithSpecificKoas dengan GetX
                      Get.to(() => const PostWithSpecificKoas(), arguments: {
                        'name': name,
                        'university': university,
                        'distance': distance,
                        'rating': rating,
                        'totalReviews': totalReviews,
                        'image': image,
                      });
                    }
                  },
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                        color: TColors.transparent, width: 1.5),
                    backgroundColor:
                        TColors.primary.withAlpha((0.2 * 255).toInt())),
                child: const Text(
                  'Make Appointment',
                  style: TextStyle(
                      fontSize: TSizes.fontSizeSm, color: TColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

