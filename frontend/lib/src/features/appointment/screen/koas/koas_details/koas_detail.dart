import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/card_showcase_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/commons/widgets/text/title_with_verified.dart';
import 'package:denta_koas/src/features/appointment/controller/explore.controller/explore_post_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/university.controller/university_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/verification_koas_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/koas_reviews.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/widgets/user_reviews_card.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/koas_post/post_with_specific_koas.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/enums.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class KoasDetailScreen extends StatelessWidget {
  const KoasDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final universityController = Get.put(UniversityController());
    final UserModel koas = Get.arguments;

    final universityCoordinate =
        universityController.fetchUniversityCoordinates(
      koas.koasProfile?.university ?? '',
    );

    Logger().i(
        'University Coordinate: $universityController.lat.value, $universityController.lng.value');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DAppBar(
        showBackArrow: true,
        showActions: false,
        centerTitle: true,
        title: Text('Koas Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Koas profile
            KoasProfileSection(
              imageUrl: koas.image ?? TImages.user,
              name: koas.fullName,
              university: koas.koasProfile?.university ?? 'N/A',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Doctor stats
            DoctorStatsSection(
              totalPatients: koas.koasProfile?.stats?.patientCount ?? 0,
              experience: koas.koasProfile?.experience ?? 0,
              ratings: koas.koasProfile?.stats?.averageRating ?? 0,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Doctor description
            BioSection(
              bio: koas.koasProfile?.bio ?? 'N/A',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Address user
            AddressSection(
              address: koas.address ?? 'N/A',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Personal Information
            PersonalInformationSection(
              koasNumber: koas.koasProfile?.koasNumber ?? 'N/A',
              status: koas.koasProfile?.status ?? 'N/A',
              departement: koas.koasProfile?.departement ?? 'N/A',
              age: koas.koasProfile?.age?.toString() ?? 'N/A',
              gender: koas.koasProfile?.gender ?? 'N/A',
              phone: koas.phone ?? 'N/A',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Map section
            MapSection(
              koasUniversity: koas.koasProfile?.university ?? '',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // User Reviews
            UserReviewSection(
              reviews: koas.koasProfile?.review ?? [],
              averageRating: koas.koasProfile?.stats?.averageRating ?? 0,
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Footer Button
            FooterButton(
              koas: koas,
              userKoasId: koas.koasProfile?.id,
              koasId: koas.id,
              status: koas.koasProfile?.status ?? 'N/A',
              koasUniversity: koas.koasProfile?.university ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class KoasProfileSection extends StatelessWidget {
  const KoasProfileSection({
    super.key,
    this.isNetworkImage = false,
    required this.imageUrl,
    required this.name,
    required this.university,
  });

  final bool isNetworkImage;
  final String imageUrl, name, university;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl), // Replace with real image URL
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: TColors.textPrimary,
              ),
        ),
        TitleWithVerified(
          title: university,
          textSizes: TextSizes.base,
          textColor: TColors.textSecondary,
        ),
      ],
    );
  }
}

class DoctorStatsSection extends StatelessWidget {
  const DoctorStatsSection({
    super.key,
    required this.totalPatients,
    required this.experience,
    required this.ratings,
  });

  final int totalPatients;
  final int experience;
  final double ratings;

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'Patients',
        'value': totalPatients.toString(),
        'icon': Icons.groups,
        'color': Colors.blue
      },
      {
        'label': 'Experience',
        'value': '${experience.toString()} Years',
        'icon': Icons.workspace_premium,
        'color': Colors.pink
      },
      {
        'label': 'Ratings',
        'value': ratings.toString(),
        'icon': Icons.star_rate,
        'color': Colors.amber
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats.map((stat) {
          return Expanded(
            child: Card(
              color: TColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          (stat['color'] as Color).withOpacity(0.2),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      stat['value'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BioSection extends StatelessWidget {
  const BioSection({super.key, required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'About',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ReadMoreText(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
            ),
            textAlign: TextAlign.justify,
            trimLines: 5,
            trimMode: TrimMode.Line,
            trimExpandedText: ' Show less ',
            trimCollapsedText: ' Show more ',
            moreStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
            lessStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AddressSection extends StatelessWidget {
  const AddressSection({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Address',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ReadMoreText(
            address,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
            ),
            textAlign: TextAlign.justify,
            trimLines: 5,
            trimMode: TrimMode.Line,
            trimExpandedText: ' Show less ',
            trimCollapsedText: ' Show more ',
            moreStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
            lessStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalInformationSection extends StatelessWidget {
  const PersonalInformationSection({
    super.key,
    required this.koasNumber,
    required this.status,
    required this.departement,
    required this.gender,
    required this.age,
    required this.phone,
  });

  final String koasNumber;
  final String status;
  final String departement;
  final String gender;
  final String age;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final personalInfo = [
      {'label': 'NIM', 'value': koasNumber},
      {'label': 'Status', 'value': status},
      {'label': 'Departement', 'value': departement},
      {'label': 'Phone', 'value': phone},
      {'label': 'Gender', 'value': gender},
      {'label': 'Generation', 'value': age},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Personal Information',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ...personalInfo.map((info) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      info['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      info['value'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TColors.textPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MapSection extends GetView<UniversityController> {
  const MapSection({
    super.key,
    required this.koasUniversity,
  });

  final String koasUniversity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'University Location',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.lat.value == 0.0 &&
                        controller.lng.value == 0.0) {
                      return SizedBox(
                        height:
                            200, // Match the container height from MapSection
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    120, // Constrain the Lottie animation size
                                child: lottie.Lottie.asset(
                                  TImages.emptyAddress,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Location not available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: TColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            LatLng(controller.lat.value, controller.lng.value),
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          enableMultiFingerGestureRace: true,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                  controller.lat.value, controller.lng.value),
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_pin,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.fullscreen),
                            onPressed: () {
                              Get.to(() => const FullscreenMapView());
                            },
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              minWidth: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenMapView extends GetView<UniversityController> {
  const FullscreenMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DAppBar(
        title: Text('Location'),
        centerTitle: true,
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.lat.value == 0.0 && controller.lng.value == 0.0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400, // Constrain the Lottie animation size
                  child: lottie.Lottie.asset(
                    TImages.emptyAddress,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Location not available',
                  style: TextStyle(
                    fontSize: 16,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(controller.lat.value, controller.lng.value),
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(controller.lat.value, controller.lng.value),
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_pin, color: Colors.red),
                ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () {},
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

// Widget untuk menampilkan daftar review
class UserReviewSection extends StatelessWidget {
  const UserReviewSection(
      {super.key, required this.reviews, required this.averageRating});

  final List<ReviewModel> reviews;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: 'Rating & Review',
            onPressed: () => Get.to(
              () => const KoasReviewsScreen(),
              arguments: [reviews, averageRating],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Cek apakah ada review atau tidak
          if (reviews.isEmpty)
            Center(
              child: Text(
                "Belum ada review",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 2 ? 2 : reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return UserReviewsCard(
                  image: review.user?.image ?? TImages.user,
                  name: review.user?.fullName ?? 'Anonim',
                  rating: review.rating,
                  comment: review.comment ?? '',
                  date: TFormatter.formatDateToFullDayName(review.createdAt),
                );
              },
            ),
        ],
      ),
    );
  }
}

class KoasUpcomingEvent extends StatelessWidget {
  const KoasUpcomingEvent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExplorePostController.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
              title: 'You might interest',
              onPressed: () => Get.to(() => const PostWithSpecificKoas())),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (controller.isLoading.value) {
              return const CardShowcaseShimmer();
            }
            if (controller.openPosts.isEmpty) {
              return const Center(child: Text('No data'));
            }
            return DGridLayout(
              itemCount: controller.openPosts.length < 2 ? 1 : 2,
              crossAxisCount: 1,
              mainAxisExtent: 400,
              itemBuilder: (_, index) {
                final post = controller.openPosts[index];
                return PostCard(
                  postId: post.id,
                  name: post.user.fullName,
                  university: post.user.koasProfile!.university!,
                  image: TImages.userProfileImage4,
                  timePosted: timeago.format(post.updateAt),
                  title: post.title,
                  description: post.desc,
                  category: post.treatment.alias,
                  participantCount: post.totalCurrentParticipants,
                  requiredParticipant: post.requiredParticipant,
                  dateStart: post.schedule.isNotEmpty
                      ? DateFormat('dd').format(post.schedule[0].dateStart)
                      : 'N/A',
                  dateEnd: post.schedule.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(post.schedule[0].dateEnd)
                      : 'N/A',
                  likesCount: post.likeCount ?? 0,
                  onTap: () => Get.to(
                    () => const PostDetailScreen(),
                    arguments: post,
                  ),
                  onPressed: () => Get.to(
                    () => const PostDetailScreen(),
                    arguments: post,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class FooterButton extends StatelessWidget {
  const FooterButton({
    super.key,
    this.koas,
    this.userKoasId,
    this.koasId,
    required this.status,
    required this.koasUniversity,
  });

  final UserModel? koas;
  final String? userKoasId;
  final String? koasId;
  final String status;
  final String koasUniversity;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationKoasController());
    final userController = UserController.instance;
    final fasilitatorUniversity =
        userController.user.value.fasilitatorProfile?.university ?? '';

    // Show approve/reject buttons if:
    // 1. User is Fasilitator
    // 2. Status is pending
    // 3. Fasilitator and Koas have the same university
    final isSameUniversity = koasUniversity.isNotEmpty &&
        fasilitatorUniversity.isNotEmpty &&
        koasUniversity == fasilitatorUniversity;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () {
          if (userController.user.value.role == 'Fasilitator' &&
              status.toLowerCase() == 'pending' &&
              isSameUniversity) {
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.rejectConfirmation(userKoasId!, koasId!),
                    style: ElevatedButton.styleFrom(
                      overlayColor: TColors.primary.withOpacity(0.1),
                      side: BorderSide(color: Colors.blue.shade50),
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: TSizes.fontSizeMd,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.approveConfirmation(userKoasId!, koasId!),
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: TColors.primary),
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: TSizes.fontSizeMd,
                        fontWeight: FontWeight.bold,
                        color: TColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // For non-fasilitator users or non-matching conditions, show appropriate button
          if (userController.user.value.role != 'Fasilitator') {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    Get.to(() => const PostWithSpecificKoas(), arguments: koas),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          } else {
            // For fasilitator but not matching university or not pending
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
