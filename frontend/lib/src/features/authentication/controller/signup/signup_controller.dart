import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  // Variable
  final storage = GetStorage();

  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final provicyPolicy = false.obs;

  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();

  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Sign Up Function
  void signUp() async {
    Logger().i('SignUp process started');
    try {
      // Start loading
      Logger().i('Opening loading dialog');
      TFullScreenLoader.openLoadingDialog(
          'Processing your information....', TImages.loadingHealth);

      // Check connection
      Logger().i('Checking network connection');
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        Logger().w('No internet connection');
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      Logger().i('Validating form');
      if (!signupFormKey.currentState!.validate()) {
        Logger().w('Form validation failed');
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check if user agreed to the terms and conditions
      Logger().i('Checking privacy policy acceptance');
      if (!provicyPolicy.value) {
        Logger().w('Privacy policy not accepted');
        TFullScreenLoader.stopLoading();

        TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message:
              'In order to create account, you must have to read and accept the privacy policy & terms of use.',
        );
        return;
      }

      // Register user in the Firebase Authentication
      Logger().i('Registering user with Firebase Authentication');
      final userCredentials = await AuthenticationRepository.instance
          .signUpWithCredential(email.text.trim(), password.text.trim());

      // Get user role
      Logger().i('Reading user role from storage');
      final role = storage.read('TEMP_ROLE');

      // Initialize new auth user
      Logger().i('Initializing new auth user');
      final newAuthUser = UserModel(
        id: userCredentials.user!.uid,
        givenName: firstName.text.trim(),
        familyName: lastName.text.trim(),
        email: email.text.trim(),
        phone: phoneNumber.text.trim(),
        address: '',
        role: role.toString().trim(),
      );

      // Save user data in database
      Logger().i('Saving user data in database');
      final newUser = UserModel(
        id: userCredentials.user!.uid,
        givenName: firstName.text.trim(),
        familyName: lastName.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
        confirmPassword: confirmPassword.text.trim(),
        phone: phoneNumber.text.trim(),
        address: '',
        role: role.toString().trim(),
      );

      final userRepository = Get.put(UserRepository());

      // Save auth user to firestore
      // Logger().i('Saving auth user to Firestore');
      // await userRepository.saveAuthUser(newAuthUser);

      // Save user record to database
      Logger().i('Saving user record to database');
      await userRepository.saveUserRecord(newUser);

      Logger().i('User created successfully: ${newUser.toString()}');

      // Remove loading
      Logger().i('Stopping loading dialog');
      TFullScreenLoader.stopLoading();

      // Show success message
      Logger().i('Showing success message');
      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your account has been created! Verify email to continue.',
      );

      storage.write('CURRENT_USER_EMAIL', email.text.trim());

      // Move to verification screen
      Logger().i('Navigating to VerifyEmailScreen');
      // Get.to(() => VerifyEmailScreen(email: email.text.trim()));
      AuthenticationRepository.instance.screenRedirect();
      // Get.to(() => const ProfileSetupScreen());
    } catch (e) {
      // Remove loading
      Logger().e('Error occurred: $e');
      TFullScreenLoader.stopLoading();

      // Show some generic error to the user
      TLoaders.errorSnackBar(title: 'Oh snap', message: e.toString());
    }
  }
}
