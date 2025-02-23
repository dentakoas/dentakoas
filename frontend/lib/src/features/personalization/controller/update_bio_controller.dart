import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/pasien_profile.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateBioController extends GetxController {
  static UpdateBioController get instance => Get.find();
  // Get role from the role screen

  TextEditingController bio = TextEditingController();
  final role = UserController.instance.user.value.role;

  final GlobalKey<FormState> updateBioFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    initializedBio();
  }

  Future<void> initializedBio() async {
    final user = await UserRepository.instance.getUserDetailById();
    try {
      if (role == 'Koas') {
        bio.text = user.koasProfile!.bio!;
      } else if (role == 'Pasien') {
        bio.text = user.pasienProfile!.bio!;
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: "Something went wrong, please try again",
      );
    }
  }

  void updateBio() async {
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
      if (!updateBioFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Get user id from firebase and inisialize the model
      final userId = AuthenticationRepository.instance.authUser!.uid;

      if (role == null) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to get user role, please try again',
        );
        return;
      }

      if (role == 'Koas') {
        updateNewKoasProfile(userId);
      } else if (role == 'Pasien') {
        updateNewPasienProfile(userId);
      } else {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to get user role, please try again',
        );
        return;
      }

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
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(
        closeOverlays: true,
      );
    } catch (e) {
      // Stop Loading
      TFullScreenLoader.stopLoading();

      // Show error message
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  // Update user profile
  void updateNewKoasProfile(String userId) async {
    final updateUser = UserModel(
      koasProfile: KoasProfileModel(
        bio: bio.text.trim(),
      ),
    );

    // Update the user profile
    await UserRepository.instance.updateKoasProfile(userId, updateUser);
  }

  void updateNewPasienProfile(String userId) async {
    final updateUser = UserModel(
      pasienProfile: PasienProfileModel(
        bio: bio.text.trim(),
      ),
    );

    // Update the user profile
    await UserRepository.instance.updatePasienProfile(userId, updateUser);
  }
}
