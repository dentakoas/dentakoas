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
    required this.koasId, // This is actually the user ID of the koas
    required this.koasProfileId, // This is the koasProfile ID
    required this.scheduleId,
    required this.timeslotId,
  });

  final String name;
  final String koasId; // User ID of the koas
  final String koasProfileId; // Profile ID of the koas
  final String scheduleId;
  final String timeslotId;

  @override
  Widget build(BuildContext context) {
    // Debug logging with more clarity
    Logger().d("BottomBookAppointment parameters:");
    Logger().d("Name: $name");
    Logger().d("Koas User ID (koasId): $koasId");
    Logger().d("Koas Profile ID (koasProfileId): $koasProfileId");
    Logger().d("Schedule ID: $scheduleId");
    Logger().d("Timeslot ID: $timeslotId");

    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(PostController());
    final appointmentController = Get.put(AppointmentsController());
    
    return Obx(() {
      print('DEBUG BottomBookAppointment:');
      print('ROLE: \\${UserController.instance.user.value.role}');
      print('selectedDate: \\${controller.selectedDate.value}');
      print('selectedTime: \\${controller.selectedTime.value}');
      // If user is not a patient, don't show the booking UI
      if (UserController.instance.user.value.role != 'Pasien') {
        return const SizedBox.shrink();
      }
      
      // Only show when date and time are selected
      if (controller.selectedDate.value.isEmpty ||
          controller.selectedTime.value.isEmpty) {
        // Show a message to select date and time
        return Container(
          height: 80,
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          decoration: BoxDecoration(
            color: dark ? TColors.darkerGrey : TColors.lightGrey,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(TSizes.cardRadiusLg),
              topRight: Radius.circular(TSizes.cardRadiusLg),
            ),
          ),
          child: Center(
            child: Text(
              'Please select date and time to book appointment',
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? TColors.white : TColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // Return the booking UI
      return Container(
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
            // Doctor name row
            Row(
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium!.apply(
                        color: dark ? TColors.white : TColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Date, time and booking button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatDateForUi(controller.selectedDate.value)} | ${controller.selectedTime.value}',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                        color: dark ? TColors.white : TColors.textPrimary,
                      ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Log the parameters being passed for debugging
                    Logger().i('Creating appointment with params:');
                    Logger().i('koasUserId: $koasId'); // User ID of the koas
                    Logger().i(
                        'koasProfileId: $koasProfileId'); // Profile ID of the koas
                    Logger().i('scheduleId: $scheduleId');
                    Logger().i('timeslotId: $timeslotId');
                    Logger().i('date: ${controller.selectedDate.value}');

                    // Fix: Ensure we're passing the RIGHT IDs in the RIGHT ORDER
                    // This should pass the koasProfileId as the koasId parameter in the API
                    appointmentController.createAppointmentConfirmation(
                      koasProfileId, // CHANGED: This should be the koasId for the API
                      koasId, // CHANGED: This is the user ID of the koas
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
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    ),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatDateForUi(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${_weekdayShort(date)}, ${_monthShort(date)} ${date.year.toString().substring(2)}';
    } catch (_) {
      return isoDate;
    }
  }

  String _weekdayShort(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _monthShort(DateTime date) {
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
    return months[date.month - 1];
  }
}
