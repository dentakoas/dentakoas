import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/general_information_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dynamic_input.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/validators/validation.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
class CreateGeneralInformation extends StatelessWidget {
  const CreateGeneralInformation({super.key, this.postId});

  final String? postId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralInformationController());
    return Scaffold(
      appBar: DAppBar(
        title: const Text('Create Post'),
        onBack: () => Get.back(),
        showBackArrow: true,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.generalInformationFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  title: 'General Information',
                  showActionButton: false,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Title
                TextFormField(
                  controller: controller.title,
                  validator: (value) =>
                      TValidator.validateEmptyText('Title', value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.title),
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Description
                TextFormField(
                  controller: controller.description,
                  validator: (value) =>
                      TValidator.validateEmptyText('Description', value),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Max participant
                TextFormField(
                  controller: controller.requiredParticipant,
                  validator: (value) =>
                      TValidator.validateEmptyText('Max Participant', value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.group),
                    labelText: 'Required Participant',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Category
                Obx(() {
                  return DDropdownMenu(
                    hintText: 'Select Treatment',
                    prefixIcon: Iconsax.category,
                    validator: (value) =>
                        TValidator.validateEmptyText("Treatment", value),
                    items: controller.treatmentsMap.values.toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSelectedTreatment(value);
                      }
                    },
                  );
                }),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                const DynamicInputForm(),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // File Upload
                const ImageUploadWidget(),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Submit Button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => controller.createGeneralInformation(),
                      child: const Text('Next'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageUploadWidget extends StatelessWidget {
  const ImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralInformationController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Image',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: TColors.textPrimary),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 4),
        const Text(
          'Upload up to 4 images. Maximum file size is 2MB per image. Consider uploading images that are related to the post (dental, medical, etc.)',
          style: TextStyle(
            color: TColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections / 2),
        Obx(() => Column(
              children: controller.selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.previewImage(
                                context, controller.selectedImages[index]),
                            child: Row(
                              children: [
                                // Show loading indicator during analysis
                                if (controller.analyzingIndex.value == index)
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          TColors.primary),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    controller.fileNames[index],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: TSizes.fontSizeMd,
                                      fontWeight: FontWeight.w600,
                                      color: controller.analyzingIndex.value ==
                                              index
                                          ? TColors.primary
                                          : TColors.darkGrey,
                                    ),
                                  ),
                                ),
                                if (index < controller.uploadedUrls.length &&
                                    controller.analyzingIndex.value != index)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 16)
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: TColors.error),
                          onPressed: controller.analyzingIndex.value == index
                              ? null
                              : () => controller.removeImage(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(() {
          if (controller.selectedImages.length < 4) {
            return GestureDetector(
              onTap: controller.isUploading.value ||
                      controller.analyzingIndex.value != -1
                  ? null
                  : controller.pickImage,
              child: DottedBorder(
                color: controller.isUploading.value ||
                        controller.analyzingIndex.value != -1
                    ? TColors.grey
                    : TColors.primary,
                strokeWidth: 2,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: controller.isUploading.value
                      ? const CircularProgressIndicator()
                      : controller.analyzingIndex.value != -1
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      TColors.primary),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Analyzing image...',
                                  style: TextStyle(
                                    color: TColors.primary,
                                    fontSize: TSizes.fontSizeSm,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,
                                    size: 40, color: TColors.primary),
                                SizedBox(width: 8),
                              ],
                            ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
