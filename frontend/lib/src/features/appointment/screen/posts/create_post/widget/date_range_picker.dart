import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/schedule_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class DateRangePicker extends StatelessWidget {
  const DateRangePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SchedulePostController());

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Obx(() {
        final selectedRange = controller.selectedDateRange;
        final startDate = selectedRange.isNotEmpty && selectedRange[0] != null
            ? DateFormat('MMM dd, yyyy').format(selectedRange[0]!)
            : 'Start Date';
        final endDate = selectedRange.length > 1 && selectedRange[1] != null
            ? DateFormat('MMM dd, yyyy').format(selectedRange[1]!)
            : 'End Date';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.white, TColors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showDateRangePicker(context, controller),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: TColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                startDate,
                                style: const TextStyle(
                                  color: TColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                endDate,
                                style: const TextStyle(
                                  color: TColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: TColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (controller.selectedDateRange.isEmpty ||
                controller.selectedDateRange[0] == null ||
                (controller.selectedDateRange.length > 1 &&
                    controller.selectedDateRange[1] == null))
              const Text(
                'Please select a date range',
                style: TextStyle(color: TColors.error, fontSize: 12),
              ),
          ],
        );
      }),
    );
  }

  void _showDateRangePicker(
      BuildContext context, SchedulePostController controller) async {
    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: TColors.primary,
      weekdayLabelTextStyle: const TextStyle(
        color: TColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: const TextStyle(
        color: TColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: const TextStyle(
        color: TColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      selectedDayTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      yearTextStyle: const TextStyle(
        color: TColors.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      selectedYearTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      dayBorderRadius: BorderRadius.circular(24),
      selectableDayPredicate: (day) => !day.isBefore(DateTime.now()),
    );

    final selectedDates = await showModalBottomSheet<List<DateTime?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
        children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: CalendarDatePicker2(
                  config: config,
                  value: controller.selectedDateRange,
                  onValueChanged: (dates) {
                    controller.selectedDateRange.value = dates;
                  },
                ),
              ),
              SizedBox(
                height: 150,
                child: Lottie.asset(TImages.characterExplore),
              ),
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace / 2),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedDates != null) {
      controller.selectedDateRange.value = selectedDates;
    }
  }
}



