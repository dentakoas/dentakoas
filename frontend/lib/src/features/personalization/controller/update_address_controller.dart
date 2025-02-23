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
import 'package:logger/logger.dart';

class UpdateAddressController extends GetxController {
  static UpdateAddressController get instance => Get.find();

  final userRepository = Get.put(UserRepository());

  TextEditingController address = TextEditingController();

  final GlobalKey<FormState> updateAddressFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializedAddress();
  }

  Future<void> initializedAddress() async {
    if (UserController.instance.user.value.address != null) {
      address.text = UserController.instance.user.value.address!;
    } else {
      address.text = '';
    }
  }

  void updateUserAddress() async {
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
      if (!updateAddressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Get user id from firebase and inisialize the model
      final userId = AuthenticationRepository.instance.authUser!.uid;

      final updateUserAddress = UserModel(
        address: address.value.text.trim(),
      );

      // Save user data
      await userRepository.updateUserRecord(userId, updateUserAddress);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your profile has been successfully updated',
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
      // Stop Loading
      TFullScreenLoader.stopLoading();

      // Show error message
      TLoaders.errorSnackBar(
        title: 'Error',
        message: "Oppss, something went wrong!",
      );
    }
  }

  void deleteUserAddress() async {
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

      // Get user id from firebase and inisialize the model
      final userId = AuthenticationRepository.instance.authUser!.uid;

      final deleteUserAddress = UserModel(
        address: '',
      );

      // Save user data
      await userRepository.updateUserRecord(userId, deleteUserAddress);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your address has been successfully deleted',
      );

      // Refresh the user profile
      final updatedUser = await UserRepository.instance.getUserDetailById();
      UserController.instance.user.value = updatedUser;

      // Redirect to profile screen
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // Stop Loading
      TFullScreenLoader.stopLoading();
      Logger().e(e);
      // Show error message
      TLoaders.errorSnackBar(
        title: 'Error',
        message: "Oppss, something went wrong!",
      );
    }
  }
}
