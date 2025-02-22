import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/rating_bar_shimmer.dart';
import 'package:denta_koas/src/features/appointment/controller/reviews_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/appointments_model.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class KoasAddReviewScreen extends StatelessWidget {
  const KoasAddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewsController());
    final AppointmentsModel appointment = Get.arguments;
    final user = appointment.koas?.user;
    final userImage = user?.image ?? TImages.user;
    final userName = user?.fullName ?? 'N/A';
    final university = appointment.koas?.university ?? 'N/A';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DAppBar(
        title: Text('Add Review'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        CircularImage(image: userImage, padding: 0, radius: 50),
                        const SizedBox(height: 10),
                        Text(userName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(university,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified,
                                color: Colors.blue, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('How was your experience?',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Obx(() => controller.isLoading.value
                      ? const RatingBarShimmer()
                      : RatingBar(
                          initialRating: 0,
                          minRating: 0,
                          allowHalfRating: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                            full:
                                const Icon(Icons.star, color: TColors.primary),
                            half: const Icon(Icons.star_half,
                                color: TColors.primary),
                            empty: const Icon(Icons.star_border,
                                color: TColors.primary),
                          ),
                          onRatingUpdate: controller.updateRating,
                          // ignoreGestures: controller.userReview.isNotEmpty,
                        )),
                  const SizedBox(height: 20),
                  const Text('Your overall rating',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 30),
                  Form(
                    key: controller.reviewsFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add detailed review',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${controller.commentLength.value}/500',
                                    style: TextStyle(
                                        color:
                                            controller.commentLength.value > 500
                                                ? Colors.red
                                                : Colors.grey)),
                              ],
                            )),
                        const SizedBox(height: 10),
                        Obx(() => controller.isLoading.value
                            ? const CommentFieldShimmer()
                            : TextFormField(
                                controller: controller.comment,
                                validator: (value) =>
                                    TValidator.validateUserInput(
                                        "Comment", value, 500),
                                maxLines: 5,
                                enabled: controller.userReview.isEmpty,
                                decoration: InputDecoration(
                                  hintText: 'Enter here',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.userReview.isEmpty
                        ? () => controller.addReviewConfirmation(
                            appointment.schedule!.post.id, user!.id!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.userReview.isEmpty
                          ? Colors.blue
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: controller.userReview.isEmpty
                                ? Colors.blue
                                : Colors.grey),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Submit Review',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
