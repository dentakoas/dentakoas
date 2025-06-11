import 'package:denta_koas/src/commons/widgets/appbar/tabbar.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_cancel_schedule.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_completed_schedule.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_ongoing_schedule.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_pending_shcedule.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_rejected_appointments.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/tab_upcoming_schedules.dart';
import 'package:denta_koas/src/features/appointment/screen/verification_koas.dart/tab_approved_koas.dart';
import 'package:denta_koas/src/features/appointment/screen/verification_koas.dart/tab_pending.dart';
import 'package:denta_koas/src/features/appointment/screen/verification_koas.dart/tab_reject_koas.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  final int? initialTabIndex;
  const AppointmentsScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    final appBarHeight = TDeviceUtils.getAppBarHeight();
    final role = UserController.instance.user.value.role;

    final isFasilitator = role == 'Fasilitator';

    return DefaultTabController(
      length: isFasilitator ? 3 : 6,
      initialIndex: initialTabIndex ?? (isFasilitator ? 1 : 2),
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: appBarHeight), // Menambahkan jarak ke bawah
            TabBarApp(
              splashFactory: NoSplash.splashFactory,
              splashBorderRadius: BorderRadius.circular(30.0),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30.0),
              ),
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: isFasilitator
                  ? [
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Rejected Koas'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Pending Koas'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Approved Koas'),
                        ),
                      ),
                    ]
                  : [
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Cancel Appointments'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Rejected Appointments'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Pending Appointments'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: TSizes.spaceBtwItems),
                          child: const Text('Upcoming Appointments'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                        horizontal: TSizes.spaceBtwItems),
                          child: const Text('Ongoing Appointments'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                        horizontal: TSizes.spaceBtwItems),
                          child: const Text('Completed Appointments'),
                        ),
                      ),
                    ],
            ),
            Expanded(
              child: TabBarView(
                children: isFasilitator
                    ? [
                        const TabRejectedKoas(),
                        const TabPendingKoas(),
                        const TabApprovedKoas(),
                      ]
                    : [
                        const TabCancelAppointments(),
                        const TabRejectedAppointments(),
                        const TabPendingAppointments(),
                        const TabUpcomingAppointments(),
                        const TabOngoingAppointments(),
                        const TabCompletedAppointments(),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
