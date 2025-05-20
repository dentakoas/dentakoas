import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/koas/rating/rating_bar_indicator.dart';
import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/widgets/overal_koas_rating.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/widgets/user_reviews_card.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KoasReviewsScreen extends StatelessWidget {
  const KoasReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Handle null or invalid arguments with safe defaults
    List<ReviewModel> reviews = [];
    double averageRating = 0.0;

    // Safely extract arguments with null checking
    try {
      final args = Get.arguments;

      if (args != null && args is List && args.isNotEmpty) {
        // Extract the first argument as reviews list
        if (args[0] != null && args[0] is List<ReviewModel>) {
          reviews = args[0] as List<ReviewModel>;
        } else if (args[0] != null && args[0] is List) {
          // Try to cast each item as ReviewModel if possible
          reviews = (args[0] as List).whereType<ReviewModel>().toList();
        }
        
        // Extract the second argument as average rating
        if (args.length > 1 && args[1] != null) {
          if (args[1] is double) {
            averageRating = args[1];
          } else if (args[1] is int) {
            averageRating = (args[1] as int).toDouble();
          } else if (args[1] is String) {
            averageRating = double.tryParse(args[1] as String) ?? 0.0;
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting arguments: $e');
      // Keep default values if an error occurs
    }

    return Scaffold(
      appBar: const DAppBar(
        title: Text('Reviews & Ratings'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rating and comments are verified and are based on patient feedback.',
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // Overall Rating Section
              const OverallKoasRating(),
              DRatingBarIndicator(
                rating: averageRating,
              ),
              Text(
                '${reviews.length} reviews',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // List Reviews
              if (reviews.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return UserReviewsCard(
                      image: review.user?.image ?? TImages.user,
                      name: review.user?.fullName ?? 'Anonim',
                      rating: review.rating,
                      comment: review.comment ?? '',
                      date:
                          TFormatter.formatDateToFullDayName(review.createdAt),
                    );
                  },
                )
              else
                const Center(
                  child: Text("Belum ada review"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
