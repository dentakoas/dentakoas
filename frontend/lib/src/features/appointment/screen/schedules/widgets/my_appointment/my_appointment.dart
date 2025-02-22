import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/images/circular_image.dart';
import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/appointments_model.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppointmentScreen extends StatelessWidget {
  const MyAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppointmentsController.instance;
    final AppointmentsModel appointment = Get.arguments;
    final role = UserController.instance.user.value.role;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DAppBar(
        title: Text('My Appointment'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Doctor Information
              Row(
                children: [
                  CircularImage(
                      image: role == Role.Koas.name
                          ? appointment.pasien!.user!.image ?? TImages.user
                          : appointment.koas!.user!.image ?? TImages.user,
                      padding: 0,
                      width: 80,
                      height: 80
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == Role.Koas.name
                            ? appointment.pasien!.user!.fullName
                            : appointment.koas!.user!.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        appointment.schedule!.post.treatment.alias,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            appointment.koas!.university!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Scheduled Appointment Section
              const Text(
                'Scheduled Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildDetailRow(
                  'Date', controller.formatAppointmentDate(appointment.date)),
              buildDetailRow(
                  'Time', controller.getAppointmentTimestampRange(appointment)),
              buildDetailRow(
                  'Status', appointment.status.toString().split('.').last),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                'Koas Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildDetailRow('Koas Number',
                  appointment.koas?.koasNumber.toString() ?? 'N/A'),
              buildDetailRow('Gender', appointment.koas?.gender ?? 'N/A'),
              buildDetailRow('Age', appointment.koas?.age.toString() ?? 'N/A'),
              buildDetailRow(
                  'Departement', appointment.koas?.departement ?? 'N/A'),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Patient Info Section
              const Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildDetailRow(
                  'Full Name', appointment.pasien?.user?.fullName ?? 'N/A'),
              buildDetailRow('Gender', appointment.pasien?.gender ?? 'N/A'),
              buildDetailRow(
                  'Age', appointment.pasien?.age.toString() ?? 'N/A'),
              buildDetailRow('Phone', appointment.pasien?.user?.phone ?? 'N/A'),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: appointment.status != StatusAppointment.Pending
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () => controller.openWhatsApp(
                    phone: appointment.koas!.user!.phone!,
                    message:
                        'Hello, ${appointment.koas!.user!.fullName}, this is ${appointment.pasien!.user!.fullName}. I have an appointment with you on ${controller.formatAppointmentDate(appointment.date)} at ${controller.getAppointmentTimestampRange(appointment)} for ${appointment.schedule!.post.treatment.alias}. My contact appointment ID is **${appointment.id}**. Thank you and cii u ong top😎🤘!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Chat On WhatsApp',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }

  // Helper widget to build detail rows
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
