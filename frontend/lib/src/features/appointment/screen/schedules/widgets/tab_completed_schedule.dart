import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/schedule_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/add_review/add_review.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/my_appointment/my_appointment.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/schedule_card.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabCompletedAppointments extends StatelessWidget {
  const TabCompletedAppointments({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentsController());

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return DGridLayout(
                    itemCount: controller.completedAppointments.length,
                    mainAxisExtent: 230,
                    crossAxisCount: 1,
                    itemBuilder: (_, index) {
                      return const ScheduleCardShimmer();
                    },
                  );
                }
                if (controller.completedAppointments.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const StateScreen(
                      image: TImages.emptyCalendar,
                      title: "Empty Completed Appointments",
                      subtitle:
                          "Oppss. You don't have any completed appointments yet.",
                    ),
                  );
                }
                {
                  return DGridLayout(
                    itemCount: controller.completedAppointments.length,
                    crossAxisCount: 1,
                    mainAxisExtent: 230,
                    itemBuilder: (_, index) {
                      final appointment =
                          controller.completedAppointments[index];
                      final role = UserController.instance.user.value.role;
                      return ScheduleCard(
                        imgUrl: role == Role.Koas.name
                            ? appointment.pasien!.user!.image ?? TImages.user
                            : appointment.koas!.user!.image ?? TImages.user,
                        name: role == Role.Koas.name
                            ? appointment.pasien?.user?.fullName ?? ''
                            : appointment.koas?.user?.fullName ?? '',
                        category: appointment.schedule!.post.treatment.alias,
                        date:
                            controller.formatAppointmentDate(appointment.date),
                        timestamp: controller
                            .getAppointmentTimestampRange(appointment),
                        primaryBtnText: 'Details',
                        secondaryBtnText: 'Review',
                        showSecondaryBtn:
                            appointment.schedule!.post.reviews!.isEmpty
                                ? true
                                : false,
                        onPrimaryBtnPressed: () {
                          Get.to(
                            () => const MyAppointmentScreen(),
                            arguments: appointment,
                          );
                        },
                        onSecondaryBtnPressed: () {
                          Get.to(
                            () => const KoasAddReviewScreen(),
                            arguments: appointment,
                          );
                        },
                        onTap: () => Get.to(
                          () => const MyAppointmentScreen(),
                          arguments: appointment,
                        ),
                      );
                    },
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
