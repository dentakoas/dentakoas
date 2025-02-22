import 'package:carousel_slider/carousel_slider.dart';
import 'package:denta_koas/src/commons/widgets/containers/circular_container.dart';
import 'package:denta_koas/src/commons/widgets/images/rounded_image_container.dart';
import 'package:denta_koas/src/features/appointment/controller/home_contrller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({
    super.key,
    required this.banners,
    this.indicatorWidth = 20.0,
    this.indicatorHeight = 4.0,
    this.viewportFraction = 1.05,
  });

  final List<String> banners;

  final double indicatorWidth;
  final double indicatorHeight;
  final double viewportFraction;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeContrller());

    return Column(
      children: [
        // Banner Image
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: viewportFraction,
            autoPlay: true,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: banners.map((url) => RoundedImage(imageUrl: url)).toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Center(
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++)
                  CircularContainer(
                    width: indicatorWidth,
                    height: indicatorHeight,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: controller.carouselCurrentIndex.value == i
                        ? TColors.primary
                        : TColors.grey,
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}
