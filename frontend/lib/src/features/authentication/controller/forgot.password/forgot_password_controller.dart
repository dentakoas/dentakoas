import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/features/authentication/screen/password_configurations/reset_password.dart';
import 'package:denta_koas/src/features/authentication/screen/password_configurations/verification_code.dart';
import 'package:denta_koas/src/features/authentication/screen/password_configurations/verification_email_reset_password.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class ForgotPasswordController extends GetxController {
  static ForgotPasswordController get instance => Get.find();

  // Variable
  final localStorage = GetStorage();

  final String otp = '';
  final hidePassword = true.obs;

  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  
  sendPasswordResetEmail() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
        'Sending password reset email....',
        TImages.loadingHealth,
      );

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      if (!forgotPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final isEmailExist = await AuthenticationRepository.instance
          .sendPasswordResetEmail(email.text.trim());

      // / Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Email sent',
        message: 'A verification Email has been sent to ${email.text}',
      );

      // Redirect
      Get.to(() => const EmailResetPasswordScreen());
    } catch (e) {
      // Stop loading
      TFullScreenLoader.stopLoading();
      Logger().e(e);

      TLoaders.errorSnackBar(
        title: 'Oh snap',
        message: "Something went wrong. Please try again later",
      );
    }
  }

  // Resend password reset email
  resendPasswordResetEmail(String email) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
        'Sending password reset email....',
        TImages.loadingHealth,
      );

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Send password reset email
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Email sent',
        message: 'A verification Email has been sent to $email',
      );
    } catch (e) {
      // Stop loading
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
        title: 'Oh snap',
        message: "Something went wrong. Please try again later",
      );
    }
  }
  

  // Send email to reset password
  sendOtpResetPassword() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
        'Sending password reset email....',
        TImages.loadingHealth,
      );

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      if (!forgotPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final isEmailExist = await AuthenticationRepository.instance
          .checkEmailForResetPassword(email.text.trim());

      // Send password reset email
      if (isEmailExist == true) {
        await AuthenticationRepository.instance
          .sendOtpResetPassword(email.text.trim());
      }

      localStorage.write('FORGOT_PASSWORD_EMAIL', email.text.trim());

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Email sent',
        message: 'A verification OTP has been sent to ${email.text}',
      );

      // Redirect
      Get.to(() => const VerificationCodeScreen());
    } catch (e) {
      // Stop loading
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
        title: 'Oh snap',
        message: "Something went wrong. Please try again later",
      );
    }
  }

  // Resend password reset email
  resendOtpResetPassword() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
        'Sending password reset email....',
        TImages.loadingHealth,
      );

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Send password reset email
      await AuthenticationRepository.instance
          .sendOtpResetPassword(email.text.trim());

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Email sent',
        message: 'A verification OTP has been sent to ${email.text}',
      );
    } catch (e) {
      // Stop loading
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
        title: 'Oh snap',
        message: "Something went wrong. Please try again later",
      );
    }
  }

  // Compare verification OTP
  compareOtpResetPassword(otp) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
        'Verifying OTP....',
        TImages.loadingHealth,
      );

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Compare OTP
      await AuthenticationRepository.instance.compareOtpResetPassword(otp);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'OTP verified',
        message: 'You have successfully verified the OTP',
      );

      // Redirect
      Get.off(() => const ResetPasswordScreen());
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Oh snap',
        message: "Something went wrong. Please try again later",
      );
    }
  }

  
  // Set timer for auto redirect
}
