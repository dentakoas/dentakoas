import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/containers/primary_header_container.dart';
import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/commons/widgets/list_tiles/setting_menu_tile.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/profile.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/address/my_address.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/change.account/change_account.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/my.appointments/my_appointments.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/notification.setting/notification_setting.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/privacy.account/privacy_account.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  DAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                            color: TColors.textWhite,
                          ),
                          
                    ),
                    showActions: false,
                  ),

                  // User Profile Card
                  DProfileMenu(
                    onPressed: () => Get.to(() => const ProfileScreen()),
                  ),
    
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Account settings
                  const SectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                  SettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Address',
                    subtitle: 'Set your default address',
                    onTap: () => Get.to(() => const MyAddressScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.calendar_1,
                    title: 'My Appointments',
                    subtitle: 'View your appointments',
                    onTap: () =>
                        Get.to(() => const MyOngoingAppointmentsScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Set any kind of notifications',
                    onTap: () =>
                        Get.to(() => const NotificationSettingScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.security_card,
                    title: 'Account Privacy',
                    subtitle: 'Control your privacy settings',
                    onTap: () => Get.to(() => const PrivacyAccountScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.user_remove,
                    title: 'Change Account',
                    subtitle: 'Change your account ',
                    onTap: () => Get.to(() => const ChangeAccountScreen()),
                  ),

                  // App settings
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                  const SectionHeading(
                    title: 'App Settings',
                    showActionButton: false,
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),
                  SettingMenuTile(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subtitle: 'Set recomendations based on your location',
                    trailing: Obx(
                      () => Switch(
                        value: controller.trailingLocation.value,
                        onChanged: (value) {
                          controller.trailingLocation.value = value;
                          if (value) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: TColors.lightContainer,
                                  title: const Text(
                                    'Geolocation Enabled',
                                    style:
                                        TextStyle(color: TColors.textPrimary),
                                  ),
                                  content: const Text(
                                    'Geolocation has been enabled. You will receive posts recommendation based on your location.',
                                    style:
                                        TextStyle(color: TColors.textPrimary),
                                    textAlign: TextAlign.start,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        overlayColor:
                                            TColors.primary.withOpacity(0.1),
                                      ),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                            color: TColors.textPrimary),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        activeColor: TColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // Logout button
                  SettingMenuTile(
                    icon: Iconsax.logout,
                    title: 'Logout',
                    subtitle: 'Logout from your account',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: TColors.lightContainer,
                            title: const Text('Confirm Logout'),
                            content: const Text(
                              'Are you sure want to logout?',
                              style: TextStyle(color: TColors.textPrimary),
                            ),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  overlayColor:
                                      TColors.primary.withOpacity(0.1),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: TColors.textPrimary,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  overlayColor: TColors.error.withOpacity(0.1),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: TColors.error),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  AuthenticationRepository.instance.signOut();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DProfileMenu extends StatelessWidget {
  const DProfileMenu({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Obx(() {
      if (controller.profileLoading.value) {
        return const SizedBox();
      } else {
        return ListTile(
          leading: Obx(() => CircularImage(
                image: controller.user.value.image ?? TImages.user,
                isNetworkImage:
                    controller.user.value.image != null ? true : false,
                backgroundColor: Colors.transparent,
                padding: 0,
              )),
          title: Text(
            controller.user.value.fullName,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: TColors.textWhite),
          ),
          subtitle: Text(
            controller.user.value.email!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: TColors.textWhite),
          ),
          trailing: IconButton(
            onPressed: onPressed,
            icon: const Icon(Iconsax.edit),
            color: TColors.white,
          ),
        );
      }
    });
  }
}
