import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/features/personalization/controller/update_personal_information_controller.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/constants/text_strings.dart';
import 'package:denta_koas/src/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

class ChangePersonalInformation extends StatelessWidget {
  const ChangePersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdatePersonalInformationController());

    final localStorage = GetStorage();

    return Scaffold(
      appBar: DAppBar(
        showBackArrow: true,
        leadingOnPressed: () => Get.back(),
        title: const Text('Update Your Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  // Text('Update Your Profile',
                  //     style: Theme.of(context).textTheme.headlineMedium),
                  // const SizedBox(height: TSizes.spaceBtwSections),

                  // Form
                  Form(
                    key: controller.updatePersonalInformationFormKey,
                    child: Column(
                      children: [
                        if (controller.role == 'Koas') ...[
                          // Koas-specific fields
                          TextFormField(
                            controller: controller.koasNumber,
                            validator: (value) => TValidator.validateEmptyText(
                                "NIM", value),
                            decoration: const InputDecoration(
                              labelText: 'NIM',
                              prefixIcon: Icon(Iconsax.personalcard),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                          TextFormField(
                            controller: controller.departement,
                            validator: (value) => TValidator.validateEmptyText(
                                "Departement", value),
                            decoration: const InputDecoration(
                              labelText: 'Departement',
                              prefixIcon: Icon(Iconsax.book),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                          Obx(
                            () => DDropdownMenu(
                              selectedItem: controller.selectedUniversity.value,
                              prefixIcon: Iconsax.building_4,
                              validator: (value) =>
                                  TValidator.validateEmptyText(
                                      "University", value),
                              items: controller.universitiesData,
                              onChanged: (value) =>
                                  controller.selectedUniversity.value = value!,
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                        ],
                        if (controller.role == 'Koas' ||
                            controller.role == 'Pasien') ...[
                          // Fields shared by Koas and Pasien
                          TextFormField(
                            controller: controller.age,
                            validator: (value) =>
                                TValidator.validateEmptyText(
                                "Generation", value),
                            decoration: const InputDecoration(
                              labelText: 'Generation',
                              prefixIcon: Icon(Iconsax.cake),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                          Obx(
                            () => DDropdownMenu(
                              prefixIcon: Iconsax.user,
                              selectedItem: controller.selectedGender.value,
                              validator: (value) =>
                                  TValidator.validateEmptyText("Gender", value),
                              items: controller.genders,
                              onChanged: (value) =>
                                  controller.selectedGender.value = value!,
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                        ],
                        if (controller.role == 'Koas') ...[
                          // Koas-specific field
                          TextFormField(
                            controller: controller.whatsappLink,
                            validator: (value) => TValidator.validateEmptyText(
                                "WhatsApp Link", value),
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Link',
                              prefixIcon: Icon(Icons.phone_android_outlined),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields),
                        ],
                        // if (controller.role == 'Koas' ||
                        //     controller.role == 'Pasien') ...[
                        //   TextFormField(
                        //     controller: controller.bio,
                        //     validator: (value) =>
                        //         TValidator.validateEmptyText("Bio", value),
                        //     decoration: const InputDecoration(
                        //       labelText: 'Please tell us about yourself',
                        //       alignLabelWithHint: true,
                        //     ),
                        //     maxLines: 5,
                        //   ),
                        //   const SizedBox(height: TSizes.spaceBtwInputFields),
                        // ],
                        if (controller.role == 'Fasilitator') ...[
                          // University field for Koas and Fasilitator
                          Obx(
                            () => DDropdownMenu(
                              hintText: 'Select University',
                              selectedItem: controller.selectedUniversity.value,
                              prefixIcon: Iconsax.building_4,
                              validator: (value) =>
                                  TValidator.validateEmptyText(
                                      "University", value),
                              items: controller.universitiesData,
                              onChanged: (value) =>
                                  controller.selectedUniversity.value = value!,
                            ),
                          ),

                          const SizedBox(height: TSizes.spaceBtwInputFields),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.updateProfileInformation(),
                      child: const Text(TTexts.submit),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
