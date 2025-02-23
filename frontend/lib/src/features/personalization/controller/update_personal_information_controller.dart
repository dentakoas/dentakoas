import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/university.repository/universities_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/fasilitator_profile.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/pasien_profile.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UpdatePersonalInformationController extends GetxController {
  static UpdatePersonalInformationController get instance => Get.find();
  // Get role from the role screen

  TextEditingController koasNumber = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController departement = TextEditingController();
  TextEditingController university = TextEditingController();
  TextEditingController whatsappLink = TextEditingController();

  final universitiesRepository = Get.put(UniversitiesRepository());

  final role = UserController.instance.user.value.role;

  final universitiesData = <String>[].obs;

  final List<String> genders = [
    'Male',
    'Female',
  ];

  RxString selectedUniversity = ''.obs;
  RxString selectedGender = ''.obs;

  final localStorage = GetStorage();

  final GlobalKey<FormState> updatePersonalInformationFormKey =
      GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    getUniversities();
    initializedPersonalInformation();
  }

  Future<void> initializedPersonalInformation() async {
    final user = await UserRepository.instance.getUserDetailById();

    try {
      if (role == 'Koas') {
        koasNumber.text = user.koasProfile!.koasNumber!;
        age.text = user.koasProfile!.age!;
        departement.text = user.koasProfile!.departement!;
        selectedUniversity.value = user.koasProfile!.university!;
        whatsappLink.text = user.koasProfile!.whatsappLink!;
        selectedGender.value = user.koasProfile!.gender!;
      } else if (role == 'Pasien') {
        age.text = user.pasienProfile!.age!;
      } else if (role == 'Fasilitator') {
        selectedUniversity.value = user.fasilitatorProfile!.university;
      } else {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to get user role, please try again',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: "Something went wrong, please try again",
      );
    }
  }

  void updateProfileInformation() async {
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
      if (!updatePersonalInformationFormKey.currentState!.validate()) {
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
      } else if (role == 'Fasilitator') {
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
        message: e.toString(),
      );
    }
  }

  // Update user profile
  void updateNewKoasProfile(String userId) async {
    final updateUser = UserModel(
      koasProfile: KoasProfileModel(
        koasNumber: koasNumber.text.trim(),
        age: age.text.trim(),
        gender: selectedGender.value,
        departement: departement.text.trim(),
        university: selectedUniversity.value,
        whatsappLink: whatsappLink.text.trim(),
      ),
    );

    // Update the user profile
    await UserRepository.instance.updateKoasProfile(userId, updateUser);

    // Refresh the user profile
    final updatedUser = await UserRepository.instance.getUserDetailById();
    UserController.instance.user.value = updatedUser;
  }

  void updateNewPasienProfile(String userId) async {
    final updateUser = UserModel(
      pasienProfile: PasienProfileModel(
        age: age.text,
        gender: selectedGender.value,
      ),
    );

    // Update the user profile
    await UserRepository.instance.updatePasienProfile(userId, updateUser);

    // Refresh the user profile
    final updatedUser = await UserRepository.instance.getUserDetailById();
    UserController.instance.user.value = updatedUser;
  }

  void updateNewFasilitatorProfile(String userId) async {
    // Initialize the new user profile
    final newFasilitatorProfile = UserModel(
      fasilitatorProfile: FasilitatorProfileModel(
        university: selectedUniversity.value,
      ),
    );

    // Save the user profile
    await UserRepository.instance
        .updateFasilitatorProfile(userId, newFasilitatorProfile);

    // Refresh the user profile
    final updatedUser = await UserRepository.instance.getUserDetailById();
    UserController.instance.user.value = updatedUser;
  }

  void getUniversities() async {
    try {
      // Ambil data universitas dari API
      final universities = await universitiesRepository.getUniversityNames();

      // Pastikan untuk memetakan hanya nama universitas
      universitiesData.value = universities;
    } catch (e) {
      // Tangani error
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'An error occurred while fetching universities',
      );
    }
  }
}
