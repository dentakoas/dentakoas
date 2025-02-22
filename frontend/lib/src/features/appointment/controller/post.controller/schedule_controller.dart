import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/post.preview/post_preview.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SchedulePostController extends GetxController {
  static SchedulePostController get instance => Get.find();

  var selectedIndex = 0.obs;
  var selectedDate = DateTime.now().obs;

  var selectedDateRange = <DateTime?>[].obs;

  final GlobalKey<FormState> schedulePostFormKey = GlobalKey<FormState>();

  final calendarRangeConfig = CalendarDatePicker2Config(
    calendarType: CalendarDatePicker2Type.range,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    selectedDayHighlightColor: TColors.primary,
    weekdayLabelTextStyle: const TextStyle(color: TColors.grey),
    controlsTextStyle: const TextStyle(color: TColors.primary),
  );

  void createPostSchedule() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.superToothLoading);

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        Logger().e('No internet connection');
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate the form
      if (!schedulePostFormKey.currentState!.validate()) {
        Logger().e('Form validation failed');
        TFullScreenLoader.stopLoading();
        return;
      }

      // Initialize the model for the schedule post
      // Logger().d('Initializing schedule post model');
      // final schedulePost = SchedulesModel(
      //   postId: postId,
      //   dateStart: dateStartValue,
      //   dateEnd: dateEndValue,
      // );

      // // Create the post schedule
      // final scheduleRepository = Get.put(SchedulesRepository());
      // final newPostSchedule =
      //     await scheduleRepository.createSchedule(schedulePost);

      // final currentScheduleId = newPostSchedule.id;
 
      // if (currentScheduleId == null) {
      //   TFullScreenLoader.stopLoading();
      //   TLoaders.errorSnackBar(
      //     title: 'Error',
      //     message: 'Failed to create post schedule',
      //   );
      //   return;
      // }

      // // Init timeslots controller to get all timeslots
      // final timeslotController = Get.put(PostTimeslotController());
      // final newTimeslots =
      //     timeslotController.getAllTimeSlotsForApi(newPostSchedule.id!);

      // // Create batch timeslots
      // final timeslotRepository = Get.put(TimeslotRepository());
      // await timeslotRepository.createBatchTimeslots(
      //     newPostSchedule.id!, newTimeslots);
 
      // Stop loading
      TFullScreenLoader.stopLoading();

      // Success message
      // TLoaders.successSnackBar(
      //   title: 'Success',
      //   message: 'Post has been created',
      // );

      // Navigate to next screen
      Get.to(() => const PostPreviewScren());
    } catch (e) {
      // Stop loading
      TFullScreenLoader.stopLoading();

      // Error message
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create post schedule',
      );
    }
  }

  void updateSelectedDay(int index) {
    selectedIndex.value = index;
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  String formatSelectedDateRange() {
    return selectedDateRange.map((date) {
      if (date != null) {
        return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      return '';
    }).join(', ');
  }

  DateTime? get dateStartValue =>
      selectedDateRange.isNotEmpty ? selectedDateRange.first : null;
  DateTime? get dateEndValue =>
      selectedDateRange.length > 1 ? selectedDateRange.last : null;

}
