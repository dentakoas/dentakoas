import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/home_appbar_shimmer.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    final searchController = Get.put(SearchPostController());

    return Obx(() {
      if (userController.profileLoading.value) {
        return const HomeAppBarShimmer();
      } else {
        return DAppBar(
          avatar: userController.user.value.image != null
              ? CircularImage(
                  image: userController.user.value.image!,
                  padding: 0,
                  isNetworkImage: true,
                )
              : Image.asset(
                  TImages.user,
                  fit: BoxFit.cover,
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userController.updateGreetingMessage(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(color: TColors.black),
              ),
              Text(
                userController.user.value.fullName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(color: TColors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          showActions: true,
          // actions: [
          //   // 🔄 SWITCHER BUTTON
          //   IconButton(
          //     icon: Icon(
          //       searchController.isSearching.value
          //           ? Iconsax.close_circle
          //           : Iconsax.search_normal_14,
          //       color: TColors.black,
          //     ),
          //     onPressed: () {
          //       searchController.isSearching.toggle();
          //     },
          //   ),
          //   // 🔔 NOTIFICATION BUTTON
          //   NotificationCounterIcon(
          //     onPressed: () => Get.to(() => const NotificationScreen()),
          //   ),
          // ],
        );
      }
    });
  }
}
