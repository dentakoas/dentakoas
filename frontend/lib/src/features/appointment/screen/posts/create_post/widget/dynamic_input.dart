import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicInputForm extends StatelessWidget {
  const DynamicInputForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InputController());
    controller.initializeInputs(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Requirement',
          isSuffixIcon: true,
          suffixIcon: Icons.add,
          onPressed: controller.addInputRequirment,
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Obx(
          () => Column(
            children: List.generate(
              controller.patientRequirements.length,
              (index) => Column(
                children: [
                  TextFormField(
                    controller: controller.patientRequirements[index],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.checklist),
                      suffixIcon: index > 0
                          ? IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  controller.removeInputRequirement(index),
                            )
                          : null,
                      labelText: 'Requirement ${index + 1}',
                    ),
                    // Validator khusus untuk field pertama
                    validator: index == 0
                        ? (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First requirement must not be empty';
                            }
                            return null;
                          }
                        : null,
                    // Optional: style khusus untuk field pertama
                    style: index == 0
                        ? const TextStyle(fontWeight: FontWeight.w500)
                        : null,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
