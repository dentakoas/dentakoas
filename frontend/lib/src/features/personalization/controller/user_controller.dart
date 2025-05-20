import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/authentication/screen/signup/signup.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/features/personalization/screen/profile/widgets/reauth_login_form.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;

  final userRepository = Get.put(UserRepository());

  final greetingMsg = ''.obs;
  RxBool trailingLocation = false.obs;

  final storage = GetStorage();

  final email = TextEditingController();
  final password = TextEditingController();

  // 
  final ImagePicker _picker = ImagePicker();
  var cloudinary = Cloudinary.signedConfig(
    apiKey: '338626958888276',
    apiSecret: '8SxMxVmbz4tinfex31MJtaj7x6A',
    cloudName: 'dxw9ywgfq',
  );
  final Rx<String> profileImageUrl = ''.obs;

  final GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  final hidePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDetail();
    updateProfileImageUrl(); // Add this to load existing image
  }

String updateGreetingMessage() {
    final hour = DateTime.now().hour;
  
    if (hour >= 5 && hour < 12) {
      greetingMsg.value = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      greetingMsg.value = 'Good Afternoon';
    } else {
      greetingMsg.value = 'Good Evening';
    }
  
    return greetingMsg.value;
  }
  Future<void> fetchAuthUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetailById();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> fetchUserDetail() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.getUserDetailById();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  // Save user who sign in with Google
  Future<void> saveUserWithGoogle(UserCredential userCredentials) async {
    try {
     
    } catch (e) {
      Logger().e(['Error saving user with Google: $e']);
      throw e.toString();
    }
  }

  // update user data
  Future<void> resetPasswordUser(String id, UserModel user) async {
    try {

      // 

      final updatedUser = UserModel(
        password: user.password,
      );

      // Save user data
      await userRepository.updateUserRecord(id, updatedUser);
    } catch (e) {
      if (kDebugMode) {
        Logger().w(e);
      }
    }
  }

  bool hasEmptyFields2(Map<String, dynamic> data) {
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip null checks for certain fields that can be optional
      if (['bio', 'image'].contains(key)) continue;

      // Cek kondisi untuk berbagai tipe data
      if (value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty) ||
          (value is Map && value.isEmpty)) {
        Logger().i('Empty field found at key: $key, value: $value');
        return true; // Ada field kosong
      }

      // Jika nilai adalah Map, cek secara rekursif
      if (value is Map<String, dynamic>) {
        final hasEmptyInNested = hasEmptyFields2(value);
        if (hasEmptyInNested) return true;
      }
    }

    return false; // Tidak ada field kosong
}

bool hasEmptyFields(Map<String, dynamic> data) {
    String role = data['role'] ?? '';
    List<String> keysToCheck = [];
  
    switch (role) {
      case 'Koas':
        keysToCheck = ['koasProfile'];
        break;
      case 'Pasien':
        keysToCheck = ['pasienProfile'];
        break;
      case 'Fasilitator':
        keysToCheck = ['fasilitatorProfile'];
        break;
      default:
        return true; // No valid role means profile is incomplete
    }

    // Check if the relevant profile key exists and is not null
    for (var key in keysToCheck) {
      if (!data.containsKey(key) || data[key] == null) {
        Logger().i('Profile key missing: $key');
        return true;
      }
    
      // If the profile exists, check if it has required fields
      if (data[key] is Map<String, dynamic>) {
        final profileData = data[key] as Map<String, dynamic>;
      
        // Define required fields for each role type
        List<String> requiredFields = [];
        switch (key) {
          case 'koasProfile':
            requiredFields = [
              'koasNumber',
              'university',
              'departement',
              'gender'
            ];
            break;
          case 'pasienProfile':
            requiredFields = ['gender'];
            break;
          case 'fasilitatorProfile':
            requiredFields = ['university'];
            break;
        }
      
        // Check if required fields exist and are not empty
        for (var field in requiredFields) {
          if (!profileData.containsKey(field) ||
              profileData[field] == null ||
              (profileData[field] is String &&
                  profileData[field].trim().isEmpty)) {
            Logger().i('Required field missing in $key: $field');
            return true;
          }
        }
      } else {
        // Profile isn't a map, so it's not properly structured
        Logger().i('Profile $key is not a proper Map');
        return true;
    }
  }

    return false; // No empty required fields found
}

setStatusColor() {
    if (user.value.koasProfile?.status == 'Pending') {
      return TColors.warning;
    } else if (user.value.koasProfile?.status == 'Approved') {
      return TColors.success;
    } else if (user.value.koasProfile?.status == 'Rejected') {
      return TColors.error;
    } else {
      return TColors.primary;
    }
  }

  void reAuthenticate() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Re-authenticating....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Re-authenticate
      await AuthenticationRepository.instance
          .reAuthenticateWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      await AuthenticationRepository.instance.deleteAccount();

      // Close loading
      TFullScreenLoader.stopLoading();

      // Show success message
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account?',
      confirm: ElevatedButton(
        onPressed: () => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Proccesing....', TImages.loadingHealth);

      final auth = AuthenticationRepository.instance;
      final provider =
          auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider == 'google.com') {
        await auth.signInWithGoogle();
        await auth.deleteAccount();
        TFullScreenLoader.stopLoading();
        Get.offAll(() => const SignupScreen());
      } else if (provider == 'password') {
        TFullScreenLoader.stopLoading();
        Get.to(() => const ReauthLoginForm());
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  // Function to pick image from gallery
  // Future<void> pickAndUploadImage() async {
  //   try {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //     if (image == null) return;

  //     // Start loading
  //     TFullScreenLoader.openLoadingDialog(
  //         'Uploading image...', TImages.loadingHealth);

  //     // Upload image to Supabase
  //     final File imageFile = File(image.path);
  //     final String fileExt = path.extension(image.path); // Get file extension
  //     final String fileName =
  //         '${user.value.id}$fileExt'; // Use user ID as filename

  //     // Upload to Supabase storage
  //     final String storagePath =
  //         await uploadImageToSupabase(imageFile, fileName);

  //     // Update user profile with new image URL
  //     await updateUserProfileImage(storagePath);

  //     // Fetch the new image
  //     await fetchProfileImage();

  //     TFullScreenLoader.stopLoading();
  //     TLoaders.successSnackBar(
  //       title: 'Success',
  //       message: 'Profile picture updated successfully',
  //     );
  //   } catch (e) {
  //     TFullScreenLoader.stopLoading();
  //     TLoaders.errorSnackBar(
  //       title: 'Error',
  //       message: e.toString(),
  //     );
  //   }
  // }

  // // Upload image to Supabase storage
  // Future<String> uploadImageToSupabase(File imageFile, String fileName) async {
  //   try {
  //     await _supabase.storage
  //         .from('avatars') // Your bucket name
  //         .upload(fileName, imageFile);

  //     return fileName;
  //   } catch (e) {
  //     throw 'Failed to upload image: $e';
  //   }
  // }

  // // Update user profile with new image URL
  // Future<void> updateUserProfileImage(String storagePath) async {
  //   try {
  //     await userRepository.updateUserRecord(
  //         user.value.id!, UserModel(image: storagePath));
  //   } catch (e) {
  //     throw 'Failed to update profile image: $e';
  //   }
  // }

  // // Fetch profile image from Supabase
  // Future<void> fetchProfileImage() async {
  //   try {
  //     if (user.value.image != null) {
  //       final String imageUrl =
  //           _supabase.storage.from('avatars').getPublicUrl(user.value.image!);
  //       profileImageUrl.value = imageUrl;
  //     }
  //   } catch (e) {
  //     Logger().e('Error fetching profile image: $e');
  //   }
  // }

  // Function to pick and upload image
  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image quality
      );

      if (image == null) return;

      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Uploading image...', TImages.loadingHealth);

      // Upload to Cloudinary
      final response = await uploadImageToCloudinary(File(image.path));

      // Update user profile with new image URL
      await updateUserProfileImage(response.secureUrl!);

      // Update UI
      profileImageUrl.value = response.secureUrl!;

      // Optional: Delete old image from Cloudinary
      // await deleteOldImage(user.value.image!);

      // refresh database
      await fetchUserDetail();

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Profile picture updated successfully',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  // Upload image to Cloudinary
  Future<CloudinaryResponse> uploadImageToCloudinary(File imageFile) async {
    try {
      // Upload to cloudinary with transformation
      return await cloudinary.upload(
          file: imageFile.path,
          folder: 'private', // Cloudinary folder
          fileBytes: imageFile.readAsBytesSync(),
          resourceType: CloudinaryResourceType.image,
          progressCallback: (count, total) {
            Logger().i('Progress: $count / $total');
          });
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // Update user profile with new image URL in MySQL database
  Future<void> updateUserProfileImage(String imageUrl) async {
    try {
      final updateUser = UserModel(
        image: imageUrl,
      );

      Logger().i('Updating profile image: $imageUrl');

      await userRepository.updateUserRecord(
          AuthenticationRepository.instance.authUser!.uid, updateUser);
    } catch (e) {
      throw 'Failed to update profile image: $e';
    }
  }

  // Update profile image URL in UI
  void updateProfileImageUrl() {
    if (user.value.image != null) {
      profileImageUrl.value = user.value.image!;
    }
  }

  // Optional: Delete old image from Cloudinary
  Future<void> deleteOldImage(String imageUrl) async {
    try {
      // Extract public ID from URL
      final Uri uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final publicId = pathSegments[pathSegments.length - 1].split('.')[0];

      // Implement deletion logic here using Cloudinary API
      // Note: This requires server-side implementation for security
      final response = await cloudinary.destroy(
        'public_id',
        url: imageUrl,
        resourceType: CloudinaryResourceType.image,
        invalidate: false,
      );
    } catch (e) {
      Logger().e('Error deleting old image: $e');
    }
  }



}
