import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BottomBookAppointment extends StatelessWidget {
  const BottomBookAppointment({
    super.key,
    required this.name,
    required this.koasId, // This should be the userId of the koas
    required this.koasProfileId, // This is the koasProfile id
    required this.scheduleId,
    required this.timeslotId,
  });

  final String name;
  final String koasId;
  final String koasProfileId;
  final String scheduleId;
  final String timeslotId;

  @override
  Widget build(BuildContext context) {
    // Debug logging to see if the widget is being built with all parameters
    print("DEBUG - BottomBookAppointment built with:");
    print("DEBUG - Name: $name");
    print("DEBUG - KoasId: $koasId");
    print("DEBUG - KoasProfileId: $koasProfileId");
    print("DEBUG - ScheduleId: $scheduleId");
    print("DEBUG - TimeslotId: $timeslotId");

    // Check if we have all required IDs before showing the actual booking button
    final hasValidIds = koasId.isNotEmpty &&
        koasProfileId.isNotEmpty &&
        scheduleId.isNotEmpty &&
        timeslotId.isNotEmpty;

    // Get current date for the appointment
    final DateTime now = DateTime.now();
    final String formattedDate =
        "${now.day} ${_getMonthName(now.month)} ${now.year}";

    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(PostController());
    final appointmentController = Get.put(AppointmentsController());
    return Obx(
      () {
        if (UserController.instance.user.value.role != 'Pasien') {
          return const SizedBox.shrink();
        }
        return controller.selectedDate.value != '' &&
                controller.selectedTime.value != ''
            ? Container(
                height: 130,
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                  vertical: TSizes.defaultSpace,
                ),
                decoration: BoxDecoration(
                  color: dark ? TColors.darkerGrey : TColors.lightGrey,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(TSizes.cardRadiusLg),
                    topRight: Radius.circular(TSizes.cardRadiusLg),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .apply(
                                    color: dark
                                        ? TColors.white
                                        : TColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.defaultSpace),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${controller.selectedDate.value} | ${controller.selectedTime.value}',
                              style:
                                  Theme.of(context).textTheme.labelLarge!.apply(
                                        color: dark
                                            ? TColors.white
                                            : TColors.textPrimary,
                                      ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Logger().i([
                              'Book Appointment: $koasId, $scheduleId, $timeslotId, $controller.selectedDate.value'
                            ]);
                            appointmentController.createAppointmentConfirmation(
                              koasId, // This is the userId of the koas - for notification
                              koasProfileId, // This is the ID of koasProfile record
                              scheduleId,
                              timeslotId,
                              controller.selectedDate.value,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusSm),
                            ),
                          ),
                          child: const Text('Book Appointment'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  // Helper method to convert month number to name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
