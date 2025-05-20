import 'package:denta_koas/navigation_menu.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/authentication/screen/signin/signin.dart';
import 'package:denta_koas/src/features/authentication/screen/signup/profile-setup.dart';
import 'package:denta_koas/src/features/authentication/screen/signup/role_option.dart';
import 'package:denta_koas/src/features/authentication/screen/signup/verify_email.dart';
import 'package:denta_koas/src/features/onboarding/screen/onboarding/onboarding.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/api_urls.dart';
import 'package:denta_koas/src/utils/dio.client/dio_client.dart';
import 'package:denta_koas/src/utils/exceptions/exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/firebase_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/format_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variable
  final storage = GetStorage();
  final _auth = FirebaseAuth.instance;

  // Get Auth user 
  User? get authUser => _auth.currentUser;


  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
    // storage.remove('TEMP_ROLE');
  }

screenRedirect() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      
      // Check if UserRepository is registered, if not register it
      if (!Get.isRegistered<UserRepository>()) {
        Get.put(UserRepository());
      }
      final userRepository = Get.find<UserRepository>();

      // Check if UserController is registered, if not register it
      if (!Get.isRegistered<UserController>()) {
        Get.put(UserController());
      }
      final userController = Get.find<UserController>();

      try {
        final userDetail = await userRepository.getUserProfile(uid);
        final userMap = userDetail.toJson();

        final users = filterProfileByRole(userMap);
        final hasNullField = userController.hasEmptyFields(users);

        Logger().i(['User Profile: $users']);
        Logger().i(['Has Null Field: $hasNullField']);

        final isOauth =
            userDetail.password!.isEmpty || userDetail.password == null;

        if (user.emailVerified) {
          if (userDetail.role == null ||
              userDetail.role == '' ||
              isOauth && userDetail.role == null ||
              userDetail.role == '') {
            Get.offAll(() => const ChooseRolePage());
          } else if (userDetail.role != null && hasNullField) {
            storage.write("TEMP_ROLE", userDetail.role);
            Get.offAll(() => const ProfileSetupScreen());
          } else if (userDetail.role != null && !hasNullField) {
            Get.offAll(() => const NavigationMenu());
          }
        } else {
          Get.offAll(() => const VerifyEmailScreen());
        }
      } catch (e) {
        Logger().e("Error during screen redirect: $e");
        // Handle error gracefully
        storage.writeIfNull('isFirstTime', true);
        Get.offAll(() => const SigninScreen());
      }
    } else {
      // local storage
      storage.writeIfNull('isFirstTime', true);
      // check if user is already logged in
      storage.read('isFirstTime') != true
          ? Get.offAll(() => const SigninScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }


  // ----------------- Check if user is exist by email -----------------
  Future<bool> checkEmailForResetPassword(String email) async {
    try {
      // Panggil API untuk memeriksa email
      final response = await DioClient().get(
        Endpoints.isEmailExist(email),
      );

      // Validasi respons
      if (response.statusCode == 200 && response.data != null) {
        final isEmailExist = response.data['isEmailExist'];
        if (isEmailExist is bool) {
          return isEmailExist;
        } else {
          throw const FormatException('Invalid response format from server.');
        }
      } else {
        throw Exception(
            'Unexpected response from server: ${response.statusCode}');
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error Firebase Auth
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      // Tangani error Firebase lainnya
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      // Tangani custom exception
      throw TExceptions(e.message);
    } on FormatException catch (e) {
      // Tangani kesalahan format respons
      throw TFormatException(e.message);
    } on PlatformException catch (e) {
      // Tangani error platform
      throw TPlatformException(e.code).message;
    } catch (e) {
      // Tangani error tak dikenal
      throw 'Something went wrong. Please try again later.';
    }
  }



  // ----------------- Get CSRF -----------------
  Future<String> tokenCsrf() async {
    try {
      final response = await DioClient().get(Endpoints.csrf);
      return response.data['csrfToken'];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw 'Failed to fetch CSRF token';
    }
  }

  // ----------------- Email and Password Sign In -----------------

  // [Email Authentication] - SIGN IN
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
   
      await DioClient().post(
        Endpoints.signinWithCredentials,
        data: {
          'email': email,
          'password': password,
           
        },
      );

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [SESSION] - CHECK SESSION
  Future<Map<String, dynamic>?> getSession() async {
    try {
      final user = await DioClient().get(Endpoints.session);
      return user.data;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email Authentication] - SIGN IN
  Future<UserCredential> signInWithEmailPasswordFirebase({
    required String email,
    required String password,
  }) async {
    try {
      // Trigger the authentication flow firebase
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // await DioClient().post(
      //   Endpoints.signinWithCredentials,
      //   data: {
      //     'email': email,
      //     'password': password,
      //   },
      // );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email Verification] - EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      // final email = _auth.currentUser!.email!;
      // await DioClient().post(
      //   Endpoints.sendVerificationEmail,
      //   data: {
      //     'email': email,
      //   },
      // );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email Reset Password ] - RESET PASSWORD
  Future<void> sendOtpResetPassword(email) async {
    try {
      // await _auth.sendPasswordResetEmail(email: email);
      await DioClient().post(
        Endpoints.sendEmailResetPassword,
        data: {
          'email': email,
        },
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // Compare OTP Reset Password
  Future<void> compareOtpResetPassword(otp) async {
    try {
      await DioClient().post(
        Endpoints.compareOtpResetPassword,
        data: {
          'otp': otp,
        },
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email Reset Password] - RESET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  Future<String> changePassword(
      String currentPassword, String newPassword, String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Reauthenticate the user.
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user?.reauthenticateWithCredential(credential);

      Logger().i(['User: $user']);
      Logger().i(['User ID: ${user!.uid}']);
      Logger().i(['Email: ${user.email}']);
      Logger().i(['New Password: $newPassword']);

      // If reauthentication is successful, change the password.
      await user.updatePassword(newPassword);

      // Password changed successfully.
      return 'Password changed successfully.';
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email Verification] - CREATE NEW VERIFICATION USER EMAIL
  Future<void> verifyEmail(email) async {
    try {
      await DioClient().patch(
        Endpoints.verifyEmail,
        data: {
          'email': email,
        },
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // [Email AUTH] - SIGN UP
  Future<UserCredential> signUpWithCredential(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // ----------------- Social Sign In -----------------
  // [GoogleAuthentication] - GOOGLE

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credentials);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // ----------------- Logout -----------------
  // [Sign Out] - SIGN OUT
  Future<void> signOut() async {
    try {
      // await DioClient().post(Endpoints.signout);
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const SigninScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // ----------------- ReAuthenticate -----------------

  Future<void> reAuthenticateWithEmailAndPassword(
      String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  // ----------------- Delete Account -----------------
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeAuthUserRecord(
        _auth.currentUser!.uid,
      );

      await UserRepository.instance.deleteAccountInDb();

      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }
}
