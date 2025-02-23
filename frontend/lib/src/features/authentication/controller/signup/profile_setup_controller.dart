import 'dart:async';

import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/university.repository/universities_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/appointment/controller/university.controller/university_controller.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/fasilitator_profile.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/pasien_profile.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/text_strings.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class ProfileSetupController extends GetxController {
  static ProfileSetupController get instance => Get.find();
  // Get role from the role screen

  TextEditingController koasNumber = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController departement = TextEditingController();
  TextEditingController university = TextEditingController();
  TextEditingController whatsappLink = TextEditingController();
  TextEditingController bio = TextEditingController();


  final universitiesRepository = Get.put(UniversitiesRepository());
  final userRepository = Get.put(UserRepository());

  final universitiesData = <String>[].obs;
  final universityController = Get.put(UniversityController());

  final List<String> genders = [
    'Male',
    'Female',
  ];

  String selectedUniversity = '';
  String selectedGender = '';

  final localStorage = GetStorage();

  final GlobalKey<FormState> profileSetupFormKey = GlobalKey<FormState>();

  @override
  void onReady() {
    super.onReady();
    // universityController.fetchUniversities();
    getUniversities();
  }

  void setupProfile() async {
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
      if (!profileSetupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Get user id from firebase and inisialize the model
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final existingRole = await userRepository.getRoleById(userId);
      final existingTempRole = localStorage.read('TEMP_ROLE');

      if (existingRole == null) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to get user role, please try again',
        );
        return;
      }

      if (existingRole == 'Koas' || existingTempRole == 'Koas') {
        updateNewKoasProfile(userId);
      } else if (existingRole == 'Pasien' || existingTempRole == 'Pasien') {
        updateNewPasienProfile(userId);
      } else if (existingRole == 'Fasilitator' ||
          existingTempRole == 'Fasilitator') {
        updateNewFasilitatorProfile(userId);
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

      // Hapus temp role
      localStorage.remove('TEMP_ROLE');

      // refresh user data 
      await UserController.instance.fetchUserDetail();

      // Get.off(() => AuthenticationRepository.instance.screenRedirect());
      Get.off(() => StateScreen(
            image: TImages.successfullySignedUp,
            title: TTexts.yourAccountCreatedTitle,
            subtitle: TTexts.yourAccountCreatedSubTitle,
            showButton: true,
            isLottie: true,
            primaryButtonTitle: TTexts.tContinue,
            onPressed: () => AuthenticationRepository.instance.screenRedirect(),
          ));
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

  checkStatusProfile() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final currentUser = await userRepository.getUserDetailById();
    if (currentUser.koasProfile?.koasNumber != null) {
      Get.off(
        () => StateScreen(
          image: TImages.setupProfileSuccess,
          title: TTexts.yourAccountCreatedTitle,
          subtitle: TTexts.yourAccountCreatedSubTitle,
          showButton: true,
          isLottie: true,
          primaryButtonTitle: TTexts.tContinue,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
        ),
      );
    }
  }

  // Timer to automatically redirect on email verification
  setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final currentUser = await userRepository.getUserDetailById();
        if (currentUser.koasProfile?.koasNumber != null) {
          timer.cancel();
          Get.off(
            () => StateScreen(
              image: TImages.setupProfileSuccess,
              title: TTexts.yourAccountCreatedTitle,
              subtitle: TTexts.yourAccountCreatedSubTitle,
              showButton: true,
              isLottie: true,
              primaryButtonTitle: TTexts.tContinue,
              onPressed: () =>
                  AuthenticationRepository.instance.screenRedirect(),
            ),
          );
        }
      },
    );
  }

  // Update user profile
  void updateNewKoasProfile(String userId) async {
    final waPhone = TFormatter.formatWhatsAppNumber(
        UserController.instance.user.value.phone!);

    final updateUser = UserModel(
      koasProfile: KoasProfileModel(
        koasNumber: koasNumber.text.trim(),
        age: age.text.trim(),
        gender: selectedGender,
        departement: departement.text.trim(),
        university: selectedUniversity,
        bio: bio.text.trim(),
        whatsappLink: 'https://wa.me/$waPhone',
      ),
    );

    // Update the user profile
    await userRepository.updateKoasProfile(userId, updateUser);
  }

  void updateNewPasienProfile(String userId) async {
    final updateUser = UserModel(
      pasienProfile: PasienProfileModel(
        age: age.text,
        gender: selectedGender,
        bio: bio.text.trim(),
        userId: userId,
      ),
    );

    // Update the user profile
    await userRepository.updatePasienProfile(userId, updateUser);
  }

  void updateNewFasilitatorProfile(String userId) async {
    // Initialize the new user profile
    final newFasilitatorProfile = UserModel(
      fasilitatorProfile: FasilitatorProfileModel(
        university: selectedUniversity,
      ),
    );

    // Save the user profile
    await UserRepository.instance
        .updateFasilitatorProfile(userId, newFasilitatorProfile);
  }

  void getUniversities() async {
    try {
      // Ambil data universitas dari API
      final universities = await universitiesRepository.getUniversityNames();

      // Filter universities to include only "Universitas Negeri Jember"
      universitiesData.value = universities
          .where((university) => university == 'Universitas Negeri Jember')
          .toList();
    } catch (e) {
      // Tangani error
      Logger().e('Error while fetching universities: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'An error occurred while fetching universities',
      );
    }
  }




}
