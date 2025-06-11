import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/schedule_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/cards/appointment_card.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/my_appointment/my_appointment.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/features/personalization/screen/setting/my.appointments/my_appointments.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeUpcomingScheduleSection extends StatelessWidget {
  const HomeUpcomingScheduleSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentsController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      child: Column(
        // Heading
        children: [
          Obx(() {
            if (controller.confirmedAppointments.isNotEmpty) {
              return SectionHeading(
                title: 'Upcoming Schedule',
                showActionButton: true,
                onPressed: () {
                  Get.to(() => const MyOngoingAppointmentsScreen());
                },
              );
            }
            if (controller.ongoingAppointments.isNotEmpty) {
              return SectionHeading(
                title: 'Ongoing Schedule',
                showActionButton: true,
                onPressed: () {
                  Get.to(() => const MyOngoingAppointmentsScreen());
                },
              );
            }
            
            return const SizedBox();
          } 
          ),
          

          // Popular Appointments
          Obx(() {
            if (controller.isLoading.value) {
              return DGridLayout(
                itemCount: 1,
                crossAxisCount: 1,
                mainAxisExtent: 200,
                itemBuilder: (_, index) {
                    return const ScheduleCardShimmer();
                },
              );
            }
              if (controller.confirmedAppointments.isNotEmpty) {
                return DGridLayout(
                  itemCount: 1,
                  crossAxisCount: 1,
                  mainAxisExtent: 165,
                  itemBuilder: (_, index) {
                    final appointment = controller.confirmedAppointments[index];
                    final role = UserController.instance.user.value.role;
                    return AppointmentCards(
                      key: ValueKey(appointment.id),
                      imgUrl: role == Role.Koas.name
                          ? appointment.pasien!.user!.image ?? TImages.user
                          : appointment.koas!.user!.image ?? TImages.user,
                      name: role == Role.Koas.name
                          ? appointment.pasien?.user?.fullName ?? ''
                          : appointment.koas?.user?.fullName ?? '',
                      category:
                          appointment.schedule?.post.treatment.alias ?? '',
                      date: controller.formatAppointmentDate(appointment.date),
                      timestamp:
                          controller.getAppointmentTimestampRange(appointment),
                      onTap: () => Get.to(
                        () => const MyAppointmentScreen(),
                        arguments: appointment,
                      ),
                    );
                  },
                );
              }
              if (controller.ongoingAppointments.isNotEmpty) {
                return DGridLayout(
                itemCount: 1,
                crossAxisCount: 1,
                mainAxisExtent: 165,
                itemBuilder: (_, index) {
                    final appointment = controller.ongoingAppointments[index];
                  final role = UserController.instance.user.value.role;
                  return AppointmentCards(
                    key: ValueKey(appointment.id),
                    imgUrl: role == Role.Koas.name
                        ? appointment.pasien!.user!.image ?? TImages.user
                        : appointment.koas!.user!.image ?? TImages.user,
                    name: role == Role.Koas.name
                        ? appointment.pasien?.user?.fullName ?? ''
                        : appointment.koas?.user?.fullName ?? '',
                    category: appointment.schedule?.post.treatment.alias ?? '',
                    date: controller.formatAppointmentDate(appointment.date),
                    timestamp:
                        controller.getAppointmentTimestampRange(appointment),
                  );
                },
              );
              }
              return const SizedBox();
            },
          )
          // const UpcomingScheduleShimmer(),
        ],
      ),
    );
  }
}
