import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/widgets/bio/change_bio.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/widgets/personal.information/change_personal_information.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/widgets/profile.information/change_profile_information.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/widgets/profile_menu.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    
  
    return Scaffold(
      appBar: const DAppBar(
        showBackArrow: true,
        title: Text('Profile'),
        centerTitle: true,
        showActions: false,
      ),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            TSizes.defaultSpace,
          ),
          child: Column(
            children: [
              // Profile picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() => CircularImage(
                          image: controller.user.value.image ?? TImages.user,
                          isNetworkImage: controller.user.value.image != null
                              ? true
                              : false,
                          backgroundColor: Colors.transparent,
                          padding: 0,
                        )),
                    TextButton(
                      onPressed: () => controller.pickAndUploadImage(),
                      child: const Text('Change Profile Picture'),
                    )
                  ],
                ),
              ),

              // Profile details
              const SizedBox(
                height: TSizes.spaceBtwItems / 2,
              ),
              const Divider(),

              
              // bio
              if (controller.user.value.role != 'Fasilitator') ...[
                SectionHeading(
                title: 'Bio',
                showActionButton: true,
                buttonTitle: "Edit",
                onPressed: () => Get.to(() => const ChangeBioScreen()),
              ),

                const SizedBox(
                  height: TSizes.spaceBtwItems / 4,
                ),
                Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                // decoration: BoxDecoration(
                //   color: TColors.white,
                //   borderRadius: BorderRadius.circular(10),
                //   border: Border.all(color: TColors.textPrimary),
                // ),
                
                child: Obx(
                  () => Text(
                    controller.user.value.profile!.bio!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              ],
            
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              // Profile Information
              SectionHeading(
                title: 'Profile Information',
                showActionButton: true,
                onPressed: () => Get.to(() => const ChangeProfileInformation()),
                buttonTitle: "Edit",
              ),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              Obx(() {
                return Column(
                  children: [
                    ProfileMenu(
                      title: 'Name',
                      value: controller.user.value.fullName,
                      onTap: () =>
                          Get.to(() => const ChangeProfileInformation()),
                    ),
                    ProfileMenu(
                      title: 'Username',
                      value: controller.user.value.name!,
                      onTap: () =>
                          Get.to(() => const ChangePersonalInformation()),
                    ),
                    ProfileMenu(
                      title: 'Phone',
                      value: controller.user.value.phone!,
                      onTap: () =>
                          Get.to(() => const ChangePersonalInformation()),
                    ),
                    ProfileMenu(
                      title: 'Email',
                      value: controller.user.value.email!,
                      onTap: () {},
                    ),
                  ],
                );
              }),
              const SizedBox( 
                height: TSizes.spaceBtwItems,
              ),
              const Divider(),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              // Heading Personal Information
              SectionHeading(
                title: 'Personal Information',
                showActionButton: true,
                buttonTitle: "Edit",
                onPressed: () =>
                    Get.to(
                  () => const ChangePersonalInformation(),
                ),
                
                // Tambahkan logika untuk menampilkan Personal Information berdasarkan role
              ),

              if (controller.user.value.role == 'Koas') ...[
                Obx(
                  () {
                    return Column(
                      children: [
                        ProfileMenu(
                          title: 'Status Koas',
                          value: controller.user.value.koasProfile!.status
                              .toString(),
                          icon: Iconsax.info_circle,
                          color: controller.setStatusColor(),
                          showIcon: true,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'User ID',
                          value: controller.user.value.id!,
                          icon: Iconsax.copy,
                          onTap: () => THelperFunctions.copyToClipboard(
                              'User Id', controller.user.value.id!),
                        ),
                        ProfileMenu(
                          title: 'Koas Number',
                          value: controller.user.value.profile!.koasNumber!,
                          icon: Iconsax.copy,
                          onTap: () => THelperFunctions.copyToClipboard(
                              'Koas Number',
                              controller.user.value.profile!.koasNumber!),
                        ),
                        ProfileMenu(
                          title: 'University',
                          value: controller.user.value.profile!.university!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Department',
                          value: controller.user.value.profile!.departement!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Age',
                          value: controller.user.value.profile!.age!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Gender',
                          value: controller.user.value.profile!.gender!,
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ],

              if (controller.user.value.role == 'Pasien') ...[
                Obx(
                  () {
                    return Column(
                      children: [
                        ProfileMenu(
                          title: 'User ID',
                          value: controller.user.value.id!,
                          icon: Iconsax.copy,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Age',
                          value: controller.user.value.profile!.age!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Gender',
                          value: controller.user.value.profile!.gender!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Bio',
                          value: controller.user.value.profile!.bio!,
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                )
              ],

              if (controller.user.value.role == 'Fasilitator') ...[
                Obx(
                  () {
                    return Column(
                      children: [
                        ProfileMenu(
                          title: 'User ID',
                          value: controller.user.value.id!,
                          icon: Iconsax.copy,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'University',
                          value: controller.user.value.profile!.university!,
                          onTap: () {},
                        ),
                        ProfileMenu(
                          title: 'Join Date',
                          value: controller.user.value.profile!.createdAt
                              .toString(),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                )
              ],

              const Divider(),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TColors.error),
                  ),
                  child: const Text(
                    'Close Account',
                    style: TextStyle(color: TColors.error),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

