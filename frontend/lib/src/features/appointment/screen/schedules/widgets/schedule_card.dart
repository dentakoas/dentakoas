import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.imgUrl,
    required this.name,
    required this.category,
    required this.date,
    required this.timestamp,
    this.isNetworkImage = false,
    this.onTap,
    this.showArrow = false,
    this.showSecondaryBtn = false,
    this.backgroundColor = TColors.white,
    this.titleColor = TColors.textPrimary,
    this.subtittleColor = TColors.textSecondary,
    this.iconColor = TColors.textSecondary,
    this.dividerColor = TColors.textSecondary,
    this.showPrimaryBtn = true,
    this.primaryBtnColor = TColors.primary,
    this.secondaryBtnColor,
    this.padding = 0,
    this.primaryBtnText = 'Reschedule',
    this.secondaryBtnText = 'Add Review',
    this.onPrimaryBtnPressed,
    this.onSecondaryBtnPressed,
    this.isPrimaryBtnLoading = false,
    this.isSecondaryBtnLoading = false,
  });

  final String imgUrl;
  final bool isNetworkImage;
  final String name;
  final String category;
  final String date;
  final String timestamp;
  final String primaryBtnText;
  final String secondaryBtnText;
  final bool? showArrow;
  final bool? showSecondaryBtn;
  final bool? showPrimaryBtn;
  final Color? backgroundColor,
      titleColor,
      subtittleColor,
      iconColor,
      dividerColor,
      primaryBtnColor,
      secondaryBtnColor;
  final void Function()? onTap;
  final void Function()? onPrimaryBtnPressed;
  final void Function()? onSecondaryBtnPressed;
  final double padding;
  final bool isPrimaryBtnLoading;
  final bool isSecondaryBtnLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularImage(
                      padding: 0,
                      width: 60,
                      height: 60,
                      image: imgUrl,
                    ),
                    const SizedBox(
                      width: TSizes.spaceBtwInputFields,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: TSizes.fontSizeLg,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 4),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: TSizes.fontSizeSm,
                              color: subtittleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showArrow!)
                      const Icon(
                        FontAwesomeIcons.chevronRight,
                        color: TColors.textSecondary,
                        size: TSizes.iconLg,
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Divider(
                  color: dividerColor,
                  thickness: 0.1,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          color: iconColor,
                          size: TSizes.iconMd,
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          color: iconColor,
                          size: TSizes.iconMd,
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            color: subtittleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems + 4),
                if (showPrimaryBtn! || showSecondaryBtn!)
                  Row(
                    children: [
                      if (showSecondaryBtn!)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSecondaryBtnLoading
                                ? null
                                : onSecondaryBtnPressed,
                            style: ElevatedButton.styleFrom(
                              overlayColor: TColors.primary.withOpacity(0.1),
                              side: BorderSide(color: Colors.blue.shade50),
                              backgroundColor: Colors.blue.shade50,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: isSecondaryBtnLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    secondaryBtnText,
                                    style: const TextStyle(
                                      fontSize: TSizes.fontSizeMd,
                                      fontWeight: FontWeight.bold,
                                      color: TColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                      if (showPrimaryBtn! && showSecondaryBtn!)
                        const SizedBox(width: TSizes.spaceBtwItems),
                      if (showPrimaryBtn!)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isPrimaryBtnLoading
                                ? null
                                : onPrimaryBtnPressed,
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(color: TColors.primary),
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: isPrimaryBtnLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    primaryBtnText,
                                    style: const TextStyle(
                                      fontSize: TSizes.fontSizeMd,
                                      fontWeight: FontWeight.bold,
                                      color: TColors.white,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
