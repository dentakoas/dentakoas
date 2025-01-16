import 'package:denta_koas/src/commons/widgets/shimmer/treatment_shimmer.dart';
import 'package:denta_koas/src/features/appointment/controller/treatment_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TreatmentController());
    final bool isScrollable = controller.featuredTreatments.length > 5;
    return Obx(() {
      if (controller.isLoading.value) {
          return TreatmentShimmer(
              itemCount: controller.featuredTreatments.length);
      }
      if (controller.treatments.isEmpty) {
          return const Center(
            child: Text(
              'No treatment found',
              style: TextStyle(color: TColors.textPrimary),
            ),
          );
        }
        return TreatmentShimmer(
            itemCount: controller.featuredTreatments.length);
        // return SizedBox(
        //     height: 80,
        //     child: ListView.builder(
        //       shrinkWrap: true,
        //       itemCount: 6,
        //       scrollDirection: Axis.horizontal,
        //       itemBuilder: (context, index) {
        //         final treatment = controller.featuredTreatments[index];
        //         return VerticalImageText(
        //           image: TImages.appleLogo,
        //           title: treatment.alias!,
        //           textColor: TColors.textPrimary,
        //           onTap: () {},
        //           backgroundColor: TColors.primary.withAlpha((0.1 * 255).toInt()),
        //         );
        //       },
        //     ),
        //   );
      },
    );
  }
}
