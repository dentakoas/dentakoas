import 'package:denta_koas/src/features/appointment/screen/home/widgets/banners/home_banner_slider.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        children: [
          // BannerPromotionShimmer(),
          BannerSlider(
            banners: [
              TImages.promoBanner4,
              TImages.promoBanner5,
              TImages.promoBanner6,
            ],
          ),
        ],
      ),
    );
  }
}
