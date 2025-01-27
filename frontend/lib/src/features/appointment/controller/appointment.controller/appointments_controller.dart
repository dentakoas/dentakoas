import 'dart:io';

import 'package:denta_koas/navigation_menu.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/cores/data/repositories/appointments.repository/appointments_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/notifications.repository/notification_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/appointment/data/model/appointments_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/notifications_model.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsController extends GetxController {
  static AppointmentsController get instance => Get.find();

  RxList<AppointmentsModel> appointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> appointmentsByUser = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> allAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> canceledAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> rejectedAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> pendingAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> confirmedAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> ongoingAppointments = <AppointmentsModel>[].obs;
  RxList<AppointmentsModel> completedAppointments = <AppointmentsModel>[].obs;


  RxBool isLoading = false.obs;

  final appointmentRepository = Get.put(AppointmentsRepository());

  @override
  void onInit() {
    fetchAppointments();
    super.onInit();
  }

  fetchAppointments() async {
    try {
      isLoading(true);
      final appointmentsData =
          await appointmentRepository.getAppointments();
      appointments.assignAll(appointmentsData);

      final appointmentsByUserData =
          await appointmentRepository.getAppointmentByUser();

      // All appointments
      appointments.assignAll(appointmentsData);

      // All appointments by user
      appointmentsByUser.assignAll(appointmentsByUserData);

      // All canceled appointments
      canceledAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Canceled)
            .toList(),
      );

      // All rejected appointments
      rejectedAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Rejected)
            .toList(),
      );

      // All pending appointments
      pendingAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Pending)
            .toList(),
      );

      // All upcoming appointments
      confirmedAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Confirmed)
            .toList(),
      );

      // All ongoing appointments
      ongoingAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Ongoing)
            .toList(),
      );

      // All completed appointments
      completedAppointments.assignAll(
        appointmentsByUserData
            .where((appointment) =>
                appointment.status == StatusAppointment.Completed)
            .toList(),
      );

    } catch (e) {
      Logger().e(['Failed to fetch appointments: $e']);
    } finally {
      isLoading(false);
    }
  }

  createAppointment(
    String koasId,
    String scheduleId,
    String timeslotId,
    String date,
  ) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final pasienDetail = await UserRepository.instance.getUserDetailById();
      final pasienId = pasienDetail.pasienProfile!.id;

      // Initiate the request
      final newAppointment = AppointmentsModel(
        pasienId: pasienId!,
        koasId: koasId,
        scheduleId: scheduleId,
        timeslotId: timeslotId,
        date: date,
      );

      // Save the appointment
      final appointmentRepository = Get.put(AppointmentsRepository());
      await appointmentRepository.createAppointment(newAppointment);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
          title: 'Appointment created successfully',
          message: 'Check your schedule for more details.');

      // Fetch appointments
      // fetchAppointments();

      // Close the dialog
      Get.offAll(
        () => StateScreen(
          key: UniqueKey(),
          image: TImages.successCreatePost,
          title: 'Your appointment has been created successfully!',
          subtitle:
              'You can view your appointment in the schedule menu. Thank you!',
          showButton: true,
          primaryButtonTitle: 'Go to Dashboard',
          onPressed: () => Get.off(() => const NavigationMenu()),
        ),
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e(['Failed to create appointment: $e']);
      TLoaders.errorSnackBar(
          title: 'Failed to create appointment',
          message: 'Something went wrong. Please try again later.');
    }
  }

  // Cancel the appointment
  cancelAppointment(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Initialize the update
      final updateAppointmentStatus = AppointmentsModel(
        pasienId: pasienId,
        koasId: koasId,
        scheduleId: scheduleId,
        timeslotId: timeslotId,
        status: StatusAppointment.Canceled,
      );

      final userRole = UserController.instance.user.value.role;
      late NotificationsModel newNotification;

      if (userRole == 'Pasien') {
        newNotification = NotificationsModel(
          senderId: UserController.instance.user.value.id,
          userId: koasId,
          koasId: koasId,
          title: 'Appointment Canceled',
          message:
              'Your appointment has been canceled by user. Please check your schedule for more details',
          status: StatusNotification.Read,
        );
      } else {
        newNotification = NotificationsModel(
          senderId: UserController.instance.user.value.id,
          userId: pasienId,
          koasId: koasId,
          title: 'Appointment Canceled',
          message:
              'Your appointment has been canceled by koas. Please check your schedule for more details',
          status: StatusNotification.Read,
        );
      }

      // send the request to update the appointment
      await AppointmentsRepository.instance
          .updateAppointment(appointmentId, updateAppointmentStatus);

      // send the notification
      await NotificationRepository.instance.createNotification(newNotification);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
          title: 'Appointment canceled successfully',
          message: 'Check your schedule for more details.');

      // Fetch appointments
      fetchAppointments();

      // Close the dialog
      Navigator.of(Get.overlayContext!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e(['Failed to cancel appointment: $e']);
      TLoaders.errorSnackBar(
          title: 'Failed to cancel appointment',
          message: 'Something went wrong. Please try again later.');
    }
  }

  // Reject the appointment
  rejectAppointment(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Initialize the update
      final updateAppointmentStatus = AppointmentsModel(
        pasienId: pasienId,
        koasId: koasId,
        scheduleId: scheduleId,
        timeslotId: timeslotId,
        status: StatusAppointment.Rejected,
      );

      final newNotification = NotificationsModel(
        senderId: UserController.instance.user.value.id,
        userId: pasienId,
        koasId: koasId,
        title: 'Appointment Rejected',
        message:
            'Your appointment has been rejected. Please check your schedule for more details',
        status: StatusNotification.Read,
      );

      // send the request to update the appointment
      await AppointmentsRepository.instance
          .updateAppointment(appointmentId, updateAppointmentStatus);

      // send the notification
      await NotificationRepository.instance.createNotification(newNotification);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
          title: 'Appointment rejected successfully',
          message: 'Check your schedule for more details.');

      // Fetch appointments
      fetchAppointments();

      // Close the dialog
      Navigator.of(Get.overlayContext!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e(['Failed to reject appointment: $e']);
      TLoaders.errorSnackBar(
          title: 'Failed to reject appointment',
          message: 'Something went wrong. Please try again later.');
    }
  }

  // Confirm the appointment
  confirmAppointment(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Initialize the update
      final updateAppointmentStatus = AppointmentsModel(
        pasienId: pasienId,
        koasId: koasId,
        scheduleId: scheduleId,
        timeslotId: timeslotId,
        status: StatusAppointment.Confirmed,
      );

      final newNotification = NotificationsModel(
        senderId: UserController.instance.user.value.id,
        userId: pasienId,
        koasId: koasId,
        title: 'Appointment Confirmed',
        message:
            'Your appointment has been confirmed. Please check your schedule for more details',
        status: StatusNotification.Read,
      );

      // send the request to update the appointment
      await AppointmentsRepository.instance
          .updateAppointment(appointmentId, updateAppointmentStatus);

      // send the notification
      await NotificationRepository.instance.createNotification(newNotification);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
          title: 'Appointment confirmed successfully',
          message: 'Check your schedule for more details.');

      // Fetch appointments
      fetchAppointments();

      // Close the dialog
      Navigator.of(Get.overlayContext!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e(['Failed to confirm appointment: $e']);
      TLoaders.errorSnackBar(
          title: 'Failed to confirm appointment',
          message: 'Something went wrong. Please try again later.');
    }
  }

  // Pop up the dialog to confirm the appointment
  void createAppointmentConfirmation(
    String koasId,
    String scheduleId,
    String timeslotId,
    String date,
  ) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.lg),
      title: 'Confirm Appointment',
      middleText: 'Are you sure want to choose this appointment?',
      confirm: ElevatedButton(
        onPressed: () =>
            createAppointment(koasId, scheduleId, timeslotId, date),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Yes'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('No'),
      ),
    );
  }

  // Pop up the dialog to cancel the appointment
  void cancelAppointmentConfirmation(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.lg),
      title: 'Cancel Appointment',
      middleText: 'Are you sure want to cancel this appointment?',
      confirm: ElevatedButton(
        onPressed: () =>
            cancelAppointment(
            appointmentId, pasienId, koasId, scheduleId, timeslotId),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Yes'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('No'),
      ),
    );
  }

  // Pop up the dialog to reject the appointment
  void rejectAppointmentConfirmation(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.lg),
      title: 'Reject Appointment',
      middleText: 'Are you sure want to reject this appointment?',
      confirm: ElevatedButton(
        onPressed: () =>
            rejectAppointment(
            appointmentId, pasienId, koasId, scheduleId, timeslotId),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.error,
          side: const BorderSide(color: TColors.error),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Yes'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('No'),
      ),
    );
  }

  // Pop up the dialog to confirm the appointment
  void confirmAppointmentConfirmation(
    String appointmentId,
    String pasienId,
    String koasId,
    scheduleId,
    timeslotId,
  ) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.lg),
      title: 'Confirm Appointment',
      middleText: 'Are you sure want to confirm this appointment?',
      confirm: ElevatedButton(
        onPressed: () =>
            confirmAppointment(
            appointmentId, pasienId, koasId, scheduleId, timeslotId),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Yes'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('No'),
      ),
    );
  }

  String formatAppointmentDate(String? dateTimeString) {
    if (dateTimeString == null) {
      return 'Unknown date';
    }
    // Mengonversi string ke DateTime
    DateTime dateTime = DateFormat("dd MMM yyyy").parse(dateTimeString);

    // Memformat DateTime ke string yang diinginkan
    return DateFormat('EEEE, dd MMMM').format(dateTime);
  }

  String formatAppointmentTimestamp(DateTime? dateTime,
      {bool showPeriod = true}) {
    if (dateTime == null) {
      return 'Unknown';
    }

    // Formatting the timestamp (e.g., "10:00 AM" or "10:00")
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return showPeriod ? '$hour:$minute $period' : '$hour:$minute';
  }

// Mengambil rentang waktu dari appointment
  String getAppointmentTimestampRange(AppointmentsModel appointment) {
    if (appointment.schedule?.timeslot == null ||
        appointment.schedule!.timeslot.isEmpty) {
      return 'Unknown';
    }

    final startTime = DateFormat("HH:mm")
        .parse(appointment.schedule!.timeslot.first.startTime);
    final endTime =
        DateFormat("HH:mm").parse(appointment.schedule!.timeslot.first.endTime);

    return '${formatAppointmentTimestamp(startTime, showPeriod: false)} - ${formatAppointmentTimestamp(endTime)}';
  }

  void openWhatsApp({required String phone, required String message}) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check if the phone number is empty
      if (phone.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
            title: 'Failed to launch WhatsApp',
            message: 'The phone number is empty. Please try again later.');
        return;
      }

      // Sanitize the phone number
      phone = phone
          .replaceAll(' ', '')
          .replaceAll('-', '')
          .replaceAll('(', '')
          .replaceAll(')', '');
      if (!phone.startsWith('+')) {
        phone = '+62$phone'; // Adjust country code as needed
      }

      // Generate WhatsApp URL
      final whatsappURlAndroid =
          'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}';
      final whatsappURLIos =
          'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';

      // Launch URL
      if (Platform.isIOS) {
        // for iOS phone only
        if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
          await launchUrl(Uri.parse(
            whatsappURLIos,
          ));
        } else {
          TLoaders.errorSnackBar(
              title: 'Failed to launch WhatsApp',
              message: 'Whatsapp not installed');
        }
      } else {
        // android , web
        if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
          await launchUrl(Uri.parse(whatsappURlAndroid));
        } else {
          TLoaders.errorSnackBar(
              title: 'Failed to launch WhatsApp',
              message: 'Whatsapp not installed');
        }
      }

      // Stop loading
      TFullScreenLoader.stopLoading();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e('Failed to launch WhatsApp: $e');
      TLoaders.errorSnackBar(
          title: 'Failed to launch WhatsApp',
          message: 'Something went wrong. Please try again later.');
    }
  }
 

}
