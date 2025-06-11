import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarHorizontal extends StatelessWidget {
  const CalendarHorizontal({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.put(CalendarController());
    final postController = Get.put(PostController());
    final today = DateTime.now();
    final ScrollController scrollController = ScrollController();

    // Inisialisasi selectedIndex berdasarkan today
    calendarController.initializeSelectedIndex(startDate, today);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedIndex = calendarController.selectedIndex.value;
      final totalDays = endDate.difference(startDate).inDays + 1;
      final isNearEndDate = selectedIndex >= totalDays - 5;
      final scrollPosition = isNearEndDate
          ? selectedIndex * 60.0
          : selectedIndex * 88.0; // 80 + margin horizontal
      scrollController.jumpTo(scrollPosition);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading Section
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: today.isAfter(startDate) ? today : startDate,
              firstDate: startDate,
              lastDate: endDate,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: TColors.primary, // Header background color
                      onPrimary: Colors.white, // Header text color
                      onSurface: TColors.textPrimary, // Body text color
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (selectedDate != null) {
              calendarController.updateSelectedDay(
                selectedDate.difference(startDate).inDays,
              );

              postController.selectedDate.value =
                  selectedDate.toUtc().toIso8601String();
            }
          },
          child: Obx(() {
            final selectedIndex = calendarController.selectedIndex.value;
            final selectedDate = startDate.add(Duration(days: selectedIndex));
            return Row(children: [
              SectionHeading(
                title: DateFormat('MMM, yyyy').format(selectedDate),
                showActionButton: false,
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.chevron_down,
                size: TSizes.iconSm,
                color: TColors.textPrimary,
              ),
            ]);
          }),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Calendar
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController, // Tambahkan ScrollController
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final totalDays = endDate.difference(startDate).inDays + 1;
                  return Row(
                    children: List.generate(
                      totalDays,
                      (index) {
                        final currentDate =
                            startDate.add(Duration(days: index));
                        final isSelected =
                            index == calendarController.selectedIndex.value;
                        final isPastDate = currentDate
                            .isBefore(today.subtract(const Duration(days: 1)));

                        return GestureDetector(
                          onTap: isPastDate
                              ? null
                              : () {
                                  calendarController.updateSelectedDay(index);
                                  postController.selectedDate.value =
                                      currentDate.toUtc().toIso8601String();
                                },
                          child: Container(
                            width: 80,
                            height: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TColors.primary
                                  : TColors.transparent,
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusMd),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentDate.day < 10
                                      ? '0${currentDate.day}'
                                      : currentDate.day.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .apply(
                                        color: isSelected
                                            ? TColors.textWhite
                                            : isPastDate
                                                ? TColors.grey
                                                : TColors.darkGrey,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEE')
                                      .format(currentDate)
                                      .toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .apply(
                                        color: isSelected
                                            ? TColors.textWhite
                                            : isPastDate
                                                ? TColors.grey
                                                : TColors.darkGrey,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ],
    );
  }
}

