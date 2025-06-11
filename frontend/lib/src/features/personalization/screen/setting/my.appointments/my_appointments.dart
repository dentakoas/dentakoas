import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/shimmer/schedule_card_shimmer.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/features/appointment/controller/appointment.controller/appointments_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/schedule_card.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyOngoingAppointmentsScreen extends StatelessWidget {
  const MyOngoingAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppointmentsController.instance;
    return Scaffold(
      appBar: const DAppBar(
        title: Text('My Appointments'),
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return DGridLayout(
              itemCount: 3,
              crossAxisCount: 1,
              mainAxisExtent: 200,
              itemBuilder: (_, index) => const ScheduleCardShimmer(),
            );
          }
          final sections = [
            {
              'title': 'Ongoing',
              'items': controller.ongoingAppointments,
            },
            {
              'title': 'Upcoming',
              'items': controller.confirmedAppointments,
            },
            {
              'title': 'Completed',
              'items': controller.completedAppointments,
            },
            {
              'title': 'Canceled',
              'items': controller.canceledAppointments,
            },
            {
              'title': 'Pending',
              'items': controller.pendingAppointments,
            },
            {
              'title': 'Rejected',
              'items': controller.rejectedAppointments,
            },
          ];
          final hasAny = sections.any((s) => (s['items'] as List).isNotEmpty);
          if (!hasAny) {
            return const StateScreen(
              image: TImages.emptyCalendar,
              title: 'No Appointments Found',
              subtitle: "You don't have any appointments yet.",
              isLottie: false,
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final section in sections)
                    if ((section['items'] as List).isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          section['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DGridLayout(
                        itemCount: (section['items'] as List).length,
                        crossAxisCount: 1,
                        mainAxisExtent: 160,
                        itemBuilder: (_, idx) {
                          final appointment = (section['items'] as List)[idx];
                          return ScheduleCard(
                            isNetworkImage: true,
                            imgUrl: appointment.koas?.user?.image ??
                                'https://images.pexels.com/photos/4167541/pexels-photo-4167541.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                            name: appointment.koas?.user?.fullName ?? 'N/A',
                            category:
                                appointment.schedule?.post.treatment.alias ??
                                    'N/A',
                            date: controller
                                .formatAppointmentDate(appointment.date),
                            timestamp: controller
                                .getAppointmentTimestampRange(appointment),
                          );
                        },
                      ),
                    ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
