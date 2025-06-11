import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/schedule_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/my_appointment/my_appointment.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/schedule_card.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabUpcomingAppointments extends StatelessWidget {
  const TabUpcomingAppointments({
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
                    itemCount: controller.confirmedAppointments.length,
                    mainAxisExtent: 230,
                    crossAxisCount: 1,
                    itemBuilder: (_, index) {
                      return const ScheduleCardShimmer();
                    },
                  );
                }
                if (controller.confirmedAppointments.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const StateScreen(
                      image: TImages.emptyCalendar,
                      title: "Empty Upcoming Appointments",
                      subtitle:
                          "Oppss. You don't have any upcoming appointments yet.",
                    ),
                  );
                }
                {
                  return DGridLayout(
                    itemCount: controller.confirmedAppointments.length,
                    crossAxisCount: 1,
                    mainAxisExtent: 230,
                    itemBuilder: (_, index) {
                      final appointment =
                          controller.confirmedAppointments[index];
                      final role = UserController.instance.user.value.role;
                      final canStart = controller.canStartSession(appointment);
                      final isKoas = role == Role.Koas.name;
                      final isPasien = role == Role.Pasien.name;
                      return ScheduleCard(
                        imgUrl: isKoas
                            ? appointment.pasien!.user!.image ?? TImages.user
                            : appointment.koas!.user!.image ?? TImages.user,
                        name: isKoas
                            ? appointment.pasien?.user?.fullName ?? ''
                            : appointment.koas?.user?.fullName ?? '',
                        category: appointment.schedule!.post.treatment.alias,
                        date:
                            controller.formatAppointmentDate(appointment.date),
                        timestamp: controller
                            .getAppointmentTimestampRange(appointment),
                        showPrimaryBtn: isPasien,
                        primaryBtnText: 'Details',
                        onPrimaryBtnPressed: isPasien
                            ? () => Get.to(() => const MyAppointmentScreen(),
                                arguments: appointment)
                            : null,
                        showSecondaryBtn: isKoas,
                        secondaryBtnText: canStart ? 'Start Session' : 'Cancel',
                        onSecondaryBtnPressed: isKoas
                            ? (canStart
                                ? () {
                                    controller
                                        .startAppointmentSessionConfirmation(
                                      appointment.id!,
                                      appointment.pasien!.user!.id!,
                                      appointment.koas!.user!.id!,
                                      appointment.koas!.id!,
                                      appointment.scheduleId!,
                                      appointment.timeslotId!,
                                    );
                                  }
                                : () {
                                    controller.cancelAppointmentConfirmation(
                                      appointment.id!,
                                      appointment.pasien!.user!.id!,
                                      appointment.koas!.user!.id!,
                                      appointment.koas!.id!,
                                      appointment.schedule!.id,
                                      appointment.schedule!.timeslot.first.id,
                                    );
                                  })
                            : null,
                        onTap: () => Get.to(() => const MyAppointmentScreen(),
                            arguments: appointment),
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
