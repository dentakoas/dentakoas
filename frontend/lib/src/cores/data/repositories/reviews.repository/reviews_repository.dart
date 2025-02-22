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
      print('Response Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return [ReviewModel.reviewFromJson(response.data)];
        } else if (response.data is Map<String, dynamic>) {
          return [ReviewModel.reviewFromJson(response.data)];
        } else {
          throw 'Invalid response format';
        }
      } else {
        throw 'Failed with status: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching reviews: $e';
    }
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

      // Cek apakah ada data dan Review array tidak kosong
      if (response.data != null &&
          response.data['Review'] != null &&
          response.data['Review'] is List &&
          response.data['Review'].isNotEmpty) {
        // Karena data dalam bentuk array, ambil review pertama
        // yang sesuai dengan postId dan pasienId
        final reviewData = response.data['Review'][0];
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
      throw 'Failed to save user data.';
    }
  }
}
