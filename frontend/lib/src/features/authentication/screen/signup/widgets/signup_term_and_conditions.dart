import 'package:denta_koas/src/features/authentication/controller/signup/signup_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/constants/text_strings.dart';
import 'package:denta_koas/src/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermAndConditions extends StatelessWidget {
  const TermAndConditions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SignUpController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use a more stable approach with GestureDetector + Container instead of direct Checkbox
        GestureDetector(
          onTap: () {
            controller.provicyPolicy.value = !controller.provicyPolicy.value;
          },
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2), // Align with text
            child: Obx(
              () => Checkbox(
                value: controller.provicyPolicy.value,
                // Use a simple function reference instead of lambda
                onChanged: _onCheckboxChanged(controller),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: '${TTexts.iAgreeTo} ',
                    style: Theme.of(context).textTheme.bodySmall),
                TextSpan(
                    text: '${TTexts.privacyPolicy} ',
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: dark ? TColors.white : TColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: dark ? TColors.white : TColors.primary,
                        )),
                TextSpan(
                    text: '${TTexts.and2} ',
                    style: Theme.of(context).textTheme.bodySmall),
                TextSpan(
                    text: '${TTexts.termsOfUse} ',
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: dark ? TColors.white : TColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: dark ? TColors.white : TColors.primary,
                      ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
  
  // Extract checkbox handler to a separate method
  ValueChanged<bool?>? _onCheckboxChanged(SignUpController controller) {
    return (bool? value) {
      if (value != null) {
        controller.provicyPolicy.value = value;
      }
    };
  }
}