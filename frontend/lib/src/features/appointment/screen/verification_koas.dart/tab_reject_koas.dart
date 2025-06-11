import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/schedule_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/verification_koas_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/koas/koas_details/koas_detail.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/schedule_card.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabRejectedKoas extends StatelessWidget {
  const TabRejectedKoas({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationKoasController());

    final universityFasilitator =
        UserController.instance.user.value.profile.university;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return DGridLayout(
                    itemCount: controller.rejectedKoas.length,
                    mainAxisExtent: 230,
                    crossAxisCount: 1,
                    itemBuilder: (_, index) {
                      return const ScheduleCardShimmer();
                    },
                  );
                }
                if (controller.rejectedKoas.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const StateScreen(
                      image: TImages.emptyPost,
                      title: "Empty Rejected Koas",
                      subtitle: "Oppss. You don't have any rejected koas yet.",
                    ),
                  );
                }
                {
                  return DGridLayout(
                    itemCount: controller.rejectedKoas.length,
                    crossAxisCount: 1,
                    mainAxisExtent: 230,
                    itemBuilder: (_, index) {
                      final koas = controller.rejectedKoas[index];
                      return ScheduleCard(
                        imgUrl: koas.image ?? TImages.user,
                        name: koas.name!,
                        category: koas.koasProfile!.university!,
                        date: TFormatter.formatDateToFullDayName(koas.updateAt),
                        timestamp:
                            TFormatter.formatTimeToLocal(koas.updateAt),
                        primaryBtnText: 'Details',
                        showPrimaryBtn: true,
                        onPrimaryBtnPressed: () {},
                        onSecondaryBtnPressed: () {},
                        onTap: () => Get.to(() => const KoasDetailScreen(),
                            arguments: koas),
                      );
                    },
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
