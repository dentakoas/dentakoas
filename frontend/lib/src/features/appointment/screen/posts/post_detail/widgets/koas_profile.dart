import 'package:denta_koas/src/commons/widgets/images/rounded_image_container.dart';
import 'package:denta_koas/src/commons/widgets/text/title_with_verified.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class KoasProfileCard extends StatelessWidget {
  const KoasProfileCard({
    super.key,
    required this.name,
    required this.university,
    required this.koasNumber,
    required this.image,
  });

  final String name;
  final String university;
  final String koasNumber;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile image with fallback
        RoundedImage(
          width: 80,
          height: 80,
          imageUrl: image,
          isNetworkImage: image.startsWith('http'),
          borderRadius: 40,
          fit: BoxFit.cover,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // university and Distance
              Row(
                children: [
                  Expanded(
                    child: TitleWithVerified(
                      title: university,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Rating
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    koasNumber,
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: TColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ],
    );
  }
}
