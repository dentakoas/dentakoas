import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileInformationController extends GetxController {
  static UpdateProfileInformationController get instance => Get.find();

  final givenName = TextEditingController();
  final familyName = TextEditingController();
  final username = TextEditingController();
  final phone = TextEditingController();

  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  GlobalKey<FormState> updateProfileInformationFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    initializedProfileInformation();
  }

  Future<void> initializedProfileInformation() async {
    givenName.text = userController.user.value.givenName!;
    familyName.text = userController.user.value.familyName!;
    username.text = userController.user.value.name!;
    phone.text = userController.user.value.phone!;
  }

  Future<void> updateProfileInformation() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your information....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();

      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      if (!updateProfileInformationFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final updateProfileInformation = UserModel(
        givenName: givenName.text.trim(),
        familyName: familyName.text.trim(),
        name: username.text.trim(),
        phone: phone.text.trim(),
      );

      // Update user record in the database
      await userRepository.updateUserRecord(
        AuthenticationRepository.instance.authUser!.uid,
        updateProfileInformation,
      );

      // Update gender in firestore
      // Map<String, dynamic> updateProfileInformationFirestore = {
      //   'givenName': givenName.text.trim(),
      //   'familyName': familyName.text.trim(),
      //   'name': username.text.trim(),
      //   'phone': phone.text.trim(),
      // };

      // await userRepository
      //     .updateSinglefieldAuthUser(updateProfileInformationFirestore);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Profile Information Updated',
        message: 'Your profile information have been updated successfully',
      );

      // Refresh the user profile
      final updatedUser = await UserRepository.instance.getUserDetailById();
      UserController.instance.user.value = updatedUser;

      // Redirect to profile screen
      await Future.delayed(const Duration(seconds: 1));
      Get.back(
        closeOverlays: true,
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error Updating Names',
        message: e.toString(),
      );
    }
  }
}
