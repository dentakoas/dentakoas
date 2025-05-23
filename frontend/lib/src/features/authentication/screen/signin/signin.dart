import 'package:denta_koas/src/commons/styles/spacing_styles.dart';
import 'package:denta_koas/src/commons/widgets/signin_signup/form_divider.dart';
import 'package:denta_koas/src/commons/widgets/signin_signup/social_buttons.dart';
import 'package:denta_koas/src/features/authentication/screen/signin/widgets/signin_footer.dart';
import 'package:denta_koas/src/features/authentication/screen/signin/widgets/signin_form.dart';
import 'package:denta_koas/src/features/authentication/screen/signin/widgets/signin_header.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: DSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          children: [
            // Logo, Tittle & Sub-Title
            const SignInHeader(),

            // Form
            const SignInForm(),

            // Divider
            FormDivider(dividerText: TTexts.orSignInWith.capitalize!),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Social Buttons
            const SocialButtons(),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Footer
            const SignInFooter()
          ],
        ),
      ),
    );
  }
}


