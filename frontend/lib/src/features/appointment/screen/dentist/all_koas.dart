import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/koas/sortable/sortable_koas.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/koas_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/cards/doctor_card.dart';
import 'package:denta_koas/src/features/appointment/screen/koas/koas_details/koas_detail.dart';
import 'package:denta_koas/src/features/personalization/controller/koas_controller.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllKoasScreen extends StatelessWidget {
  const AllKoasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KoasController());
    return Scaffold(
      appBar: const DAppBar(
        title: Text('All Koas'),
        showBackArrow: true,
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.filter_list),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Obx(() {
            if (controller.isLoading.value) {
              return DGridLayout(
                itemCount:
                    controller.koas.isNotEmpty ? controller.koas.length : 3,
                mainAxisExtent: 205,
                crossAxisCount: 1,
                itemBuilder: (_, index) {
                  return const KoasCardShimmer();
                },
              );
            }
            if (controller.koas.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const StateScreen(
                  image: TImages.emptySearch2,
                  title: "Koas not found",
                  subtitle: "Oppss. There is no koas found.",
                ),
              );
            }
            return SortableField(
              showDropdownMenu: false,
              itemCount: controller.allKoas.length,
              crossAxisCount: 1,
              mainAxisExtent: 200,
              itemBuilder: (_, index) {
                final koas = controller.allKoas[index];
                return KoasCard(
                  name: koas.fullName,
                  university: koas.koasProfile!.university!,
                  distance: '2 km',
                  rating: koas.koasProfile!.stats!.averageRating,
                  totalReviews: koas.koasProfile!.stats!.totalReviews,
                  image: TImages.userProfileImage4,
                  onTap: () =>
                      Get.to(() => const KoasDetailScreen(), arguments: koas),
                );
              },
            );
          } 
          ),
        ),
      ),
    );
  }
}
