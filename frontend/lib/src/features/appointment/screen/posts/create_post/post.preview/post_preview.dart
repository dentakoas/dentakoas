import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/general_information_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/schedule_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/timeslot_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PostPreviewScren extends StatelessWidget {
  const PostPreviewScren({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
 
    return Scaffold(
      appBar: DAppBar(
        title: const Text('Post Preview'),
        onBack: () => Get.back(),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Information
            const SectionHeading(
              title: 'General Information',
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Title
            TextFormField(
              initialValue: GeneralInformationController.instance.title.text,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              readOnly: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Description
            TextFormField(
              maxLines: 5,
              initialValue:
                  GeneralInformationController.instance.description.text,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Description',
              ),
              readOnly: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Required Participant
            TextFormField(
              initialValue: GeneralInformationController
                  .instance.requiredParticipant.text,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.people),
                labelText: 'Required Participants',
              ),
              readOnly: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Category
            TextFormField(
              initialValue:
                  GeneralInformationController.instance.selectedTreatment.value,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.category),
                labelText: 'Treatment Category',
              ),
              readOnly: true,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Schedule
            const SectionHeading(
              title: 'Schedule',
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            Builder(
              builder: (context) {
                final selectedRange =
                    SchedulePostController.instance.selectedDateRange;
                final startDate =
                    selectedRange.isNotEmpty && selectedRange[0] != null
                        ? selectedRange[0]!.toLocal().toString().split(' ')[0]
                        : '';
                final endDate =
                    selectedRange.length > 1 && selectedRange[1] != null
                        ? selectedRange[1]!.toLocal().toString().split(' ')[0]
                        : '';
                final dateRange = startDate.isNotEmpty && endDate.isNotEmpty
                    ? '$startDate - $endDate'
                    : 'Select Date Range';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: dateRange,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.calendar_1),
                        labelText: 'Date Range',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Time Slots
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: PostTimeslotController.instance
                          .getTimeSlotsJson()['timeSlots']
                          .map<Widget>((entry) {
                        final period = entry['title'];
                        final slots =
                            entry['slots'] as List<Map<String, dynamic>>;

                        if (slots.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeading(
                                title: period, showActionButton: false),
                        const SizedBox(height: TSizes.spaceBtwItems),
                            ...slots.map<Widget>((slot) {
                              final startTime = slot['startTime'] ?? '';
                              final endTime = slot['endTime'] ?? '';
                              final maxParticipants =
                                  slot['maxParticipants'] ?? 0;

                          return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(
                                    bottom: TSizes.spaceBtwItems / 2),
                                decoration: BoxDecoration(
                                  color: TColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: TColors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$startTime - $endTime',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Max: $maxParticipants',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                          );
                        }),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                  ],
                );
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Patient Requirements
            const SectionHeading(
                title: 'Patient Requirements', showActionButton: false),
            const SizedBox(height: TSizes.spaceBtwItems),

            ...InputController.instance.getAllValues().map(
                  (req) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TColors.grey),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.checklist,
                            size: 20,
                            color: TColors.textPrimary,
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems / 2),
                          Expanded(
                            child: Text(
                              req,
                              style: const TextStyle(
                                fontSize: 16,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Images preview section
            const SectionHeading(
              title: 'Images',
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(() {
              final controller = GeneralInformationController.instance;
              if (controller.selectedImages.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.grey),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.gallery, color: TColors.textSecondary),
                      SizedBox(width: TSizes.spaceBtwItems / 2),
                      Text(
                        'No images uploaded',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: TSizes.spaceBtwItems,
                  mainAxisSpacing: TSizes.spaceBtwItems,
                  childAspectRatio: 1,
                ),
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.grey),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          controller.selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                        if (index < controller.uploadedUrls.length)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Text(
                              controller.fileNames[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: TSizes.spaceBtwSections),

            const SectionHeading(title: 'Status post', showActionButton: false),
            DDropdownMenu(
              prefixIcon: Iconsax.info_circle,
              hintText: 'Select Status',
              selectedItem: controller.selectedStatus.value,
              items: const ['Open', 'Pending'],
              onChanged: (value) {
                controller.selectedStatus.value = value!;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwSections * 2),

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
                  onPressed: () => controller.createPost(),
                  child: const Text('Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
