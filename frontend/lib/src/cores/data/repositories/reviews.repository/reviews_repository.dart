import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/utils/constants/api_urls.dart';
import 'package:denta_koas/src/utils/dio.client/dio_client.dart';
import 'package:denta_koas/src/utils/exceptions/exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/format_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/platform_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ReviewsRepository extends GetxController {
  static ReviewsRepository get instance => Get.find();

  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await DioClient().get(Endpoints.reviews);

      if (response.statusCode == 200) {
        return ReviewModel.reviewsFromJson(response.data);
      }
    } catch (e) {
      throw e.toString();
    }
    throw 'Failed to fetch treatment types.';
  }

  Future<ReviewModel> checkExistingReview(
      String postId, String pasienId) async {
    try {
      final response = await DioClient().get(
        Endpoints.reviews,
        queryParameters: {
          'postId': postId,
          'pasienId': pasienId,
        },
      );

      // Cek apakah ada data dan reviews array tidak kosong
      if (response.data != null &&
          response.data['reviews'] != null &&
          response.data['reviews'] is List &&
          response.data['reviews'].isNotEmpty) {
        // Karena data dalam bentuk array, ambil review pertama
        // yang sesuai dengan postId dan pasienId
        final reviewData = response.data['reviews'][0];
        return ReviewModel.fromJson(reviewData);
      } else {
        return ReviewModel.empty();
      }
    } catch (e) {
      Logger().e(['Error checking review status: $e']);
      throw 'Failed to check review status';
    }
  }

  Future<ReviewModel> getReviewById(String id) async {
    try {
      final response = await DioClient().get(Endpoints.review(id));

      if (response.statusCode == 200) {
        return ReviewModel.fromJson(response.data);
      }
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
    throw 'Failed to fetch review data.';
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      final response =
          await DioClient().post(Endpoints.reviews, data: review.toJson());

      if (response.statusCode != 201) {
        throw 'Failed to save user data.';
      }
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      e.toString();
    }
  }
}
