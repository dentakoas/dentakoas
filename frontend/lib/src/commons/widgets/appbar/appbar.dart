import 'package:denta_koas/src/commons/widgets/notifications/notification_menu.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/notifications/notification.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? avatar;
  final Widget? title;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final VoidCallback? onBack;
  final bool showBackArrow;
  final bool centerTitle;
  final bool showActions;

  const DAppBar({
    super.key,
    this.avatar,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.centerTitle = false,
    this.onBack,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchPostController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: AppBar(
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                onPressed: onBack ?? () => Get.back(),
                icon: const Icon(Icons.chevron_left),
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(leadingIcon),
                  )
                : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,  
          children: [
            if (avatar != null) ...[
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                child: avatar,
              ),
              const SizedBox(width: 8), // Spasi antara avatar dan title
            ],
            if (title != null) title!, // Title jika ada
          ],
        ),
        actions: showActions
            ? [
                // 🔄 SWITCHER BUTTON
                Obx(() => IconButton(
                      icon: Icon(
                        searchController.isSearching.value
                            ? Iconsax.close_circle
                            : Iconsax.search_normal_14,
                        color: TColors.black,
                      ),
                      onPressed: () {
                        searchController.isSearching.toggle();
                      },
                    )),
                // 🔔 NOTIFICATION BUTTON
                NotificationCounterIcon(
                  onPressed: () => Get.to(() => const NotificationScreen()),
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
