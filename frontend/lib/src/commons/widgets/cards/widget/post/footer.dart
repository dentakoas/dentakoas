import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FooterSection extends StatelessWidget {
  final String dateStart, dateEnd;
  final int likesCount;
  final void Function()? onPressed;
  final bool showJoinButton;

  const FooterSection({
    super.key,
    required this.dateStart,
    required this.dateEnd,
    required this.likesCount,
    this.onPressed,
    this.showJoinButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
          const Icon(Iconsax.calendar_1, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$dateStart - $dateEnd',
              style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            // Row(
            //   children: [
            //     const Icon(Iconsax.like, color: Colors.grey),
            //     const SizedBox(width: 8),
            //     Text('$likesCount likes',
            //         style: Theme.of(context).textTheme.bodyMedium),
            //   ],
            // ),
          ],
        ),
        if (showJoinButton)
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: TColors.primary,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Join',
                    style: TextStyle(
                        fontSize: TSizes.fontSizeMd, color: TColors.white)),
                SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: TSizes.iconSm,
                  color: TColors.white,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
