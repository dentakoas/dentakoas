import 'package:denta_koas/navigation_menu.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/cores/data/repositories/reviews.repository/reviews_repository.dart';
import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ReviewsController extends GetxController {
  static ReviewsController get instance => Get.find();

  final isLoading = false.obs;
  RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  RxList<ReviewModel> review = <ReviewModel>[].obs;
  RxList<ReviewModel> userReview = <ReviewModel>[].obs;

  final reviewsRepository = Get.put(ReviewsRepository());

  final comment = TextEditingController();
  final rating = 0.0.obs;

  final commentLength = 0.obs;

  final GlobalKey<FormState> reviewsFormKey = GlobalKey<FormState>();

  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
    comment.addListener(() => commentLength.value = comment.text.length);

    // if (Get.arguments?.schedule.post.reviews != null || Get.arguments?.schedule.post.reviews!.isNotEmpty) {
    //   initializeReview(Get.arguments.schedule!.post.id);
    // }
  }

  @override
  void onClose() {
    comment.dispose();
    super.onClose();
  }

  Future<void> initializeReview(String postId) async {
    try {
      isLoading.value = true;
      final fetchedReviews = await reviewsRepository.getReviews();
      reviews.assignAll(fetchedReviews);

      final existingReview = await reviewsRepository.checkExistingReview(
        postId,
        UserController.instance.user.value.id!,
      );

      userReview.assignAll([existingReview]);
      rating.value = existingReview.rating ?? 0.0;
      comment.text = existingReview.comment ?? "";
      commentLength.value = comment.text.length;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      Logger().e('Error initializing review: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviews() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final fetchedReviews = await reviewsRepository.getReviews();
      if (fetchedReviews.isNotEmpty) {
        reviews.assignAll(fetchedReviews);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }

  Future<void> fetchReviewById(String id) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final fetchedReview = await reviewsRepository.getReviewById(id);
      review.assignAll([fetchedReview]);
    } catch (e) {
      // TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to fetch review data.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReview(String postId, String koasId) async {
    try {
      Logger().i('Starting addReview process');
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.superToothLoading);

      if (!await NetworkManager.instance.isConnected()) {
        Logger().w('No internet connection');
        TFullScreenLoader.stopLoading();
        return;
      }

      if (rating.value == 0.0) {
        Logger().w('Rating is zero');
        TLoaders.errorSnackBar(title: 'Error', message: 'Please give a rating');
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reviewsFormKey.currentState!.validate()) {
        Logger().w('Form validation failed');
        TFullScreenLoader.stopLoading();
        return;
      }

      final newReview = ReviewModel(
        postId: postId,
        pasienId: UserController.instance.user.value.id!,
        koasId: koasId,
        rating: rating.value,
        comment: comment.text.trim(),
      );

      Logger().i('Adding review: $newReview');
      await reviewsRepository.addReview(newReview);

      Logger().i('Review added successfully');

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your review has been submitted successfully',
      );
      
      // Refresh data
      await fetchReviews();
      await UserController.instance.fetchUserDetail();

      Logger().i('Navigating to success screen');
      Get.to(() => StateScreen(
            image: TImages.successAddReview,
            isLottie: true,
            title: "Thanks for your review",
            subtitle: "Your review has been submitted successfully",
            showButton: true,
            primaryButtonTitle: 'Back to Home',
            onPressed: () => Get.offAll(() => const NavigationMenu()),
          ));
    } catch (e) {
      Logger().e('Error adding review: $e');
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void updateRating(double newRating) {
    rating.value = newRating;
  }

  void addReviewConfirmation(String postId, String koasId) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Review Koas',
      middleText: 'Are you sure you want to submit this review?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          addReview(postId, koasId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Yes'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('No'),
      ),
    );
  }
}
