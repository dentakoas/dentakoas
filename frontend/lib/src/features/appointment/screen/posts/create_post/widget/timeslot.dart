import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/general_information_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/timeslot_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TimeSlotWidget extends StatelessWidget {
  const TimeSlotWidget({super.key, this.requiredParticipants});

  final int? requiredParticipants;

  @override
  Widget build(BuildContext context) {

    return const Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequiredParticipantSection(),
          SizedBox(height: TSizes.spaceBtwSections),
          DurationSection(),
          SizedBox(height: TSizes.spaceBtwSections),
          TimeSlotSelection()
        ],
      ),
    );
  }
}

class RequiredParticipantSection extends StatelessWidget {
  const RequiredParticipantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralInformationController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Required Participant',
          showActionButton: false,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.group),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          initialValue: controller.requiredParticipant.text,
          enabled: false,
        ),
      ],
    );
  }
}

class DurationSection extends StatelessWidget {

  const DurationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostTimeslotController());
    final durationItems = [
      '1 Jam',
      '2 Jam',
      '3 Jam',
      '4 Jam',
      '5 Jam',
      '6 Jam'
    ];
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Duration', showActionButton: false),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
          () => DDropdownMenu(
            selectedItem:
                "${controller.sessionDuration.value.inHours}  Jam",
            items: durationItems,
            onChanged: (value) {
              if (value != null) {
                controller
                    .updateSessionDuration(int.parse(value.split(' ')[0]));
              }
            },
            hintText: 'Select Session Duration...',
            prefixIcon: Iconsax.clock,
          ),
        ),
      ],
    );
  }
}

class TimeSlotSelection extends StatefulWidget {
  const TimeSlotSelection({super.key});

  @override
  State<TimeSlotSelection> createState() => _TimeSlotSelectionState();
}

class _TimeSlotSelectionState extends State<TimeSlotSelection> {
  final controller = Get.put(PostTimeslotController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Time Slots',
          isSuffixIcon: true,
          suffixIcon: Icons.more_vert,
          onPressed: () {},
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
          () {
            return Column(
              children: controller.timeSlots.entries.map(
                (entry) {
                  return _buildSection(context, entry.key, entry.value);
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> slots) {
    int totalMaxParticipants = controller.totalMaxParticipants;
    int requiredParticipants =
        int.parse(
        GeneralInformationController.instance.requiredParticipant.text);
    final totalAvailableTimeSlots =
        controller.totalAvailableTimeSlots;
    int totalSlots = controller.calculateTotalSlots();

    bool isAvailable = totalMaxParticipants < requiredParticipants &&
        totalSlots < requiredParticipants;

    // Logger().i({
    //   'totalSlots': totalSlots,
    //   'totalAvailableTimeSlots': totalAvailableTimeSlots,
    //   'requiredParticipants': requiredParticipants,
    //   'totalMaxParticipants': totalMaxParticipants,
    //   'isAvailable': isAvailable,
    //   'slots': slots,
    //   'title': title,
    // });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          triggerMode: isAvailable ? TooltipTriggerMode.tap : null,
          message: 'Max participants reached',
          child: SectionHeading(
            title: title,
            isSuffixIcon: true,
            suffixIcon: Icons.add,
            color: isAvailable ? TColors.textPrimary : TColors.grey,
            onPressed: isAvailable ? () => _showTimePicker(title) : () {},
          ),
        ),
        Column(
          children: slots.map((slot) {
            // Create a unique GlobalKey for each slot dynamically
            final tooltipKey = GlobalKey<TooltipState>();

            return Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '$slot (${DateTime.now().timeZoneName})',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: TColors.textPrimary,
                              fontWeightDelta: 2,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Tooltip(
                        key: tooltipKey,
                        message: 'Set Max Participants for Slot',
                        triggerMode: TooltipTriggerMode.manual,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.chevron_left),
                                iconSize: TSizes.iconBase,
                                onPressed: () {
                                  if (controller
                                          .maxParticipantsForSlot(title, slot) >
                                      1) {
                                    controller
                                        .decrementMaxParticipantsForSlot(
                                            title, slot);
                                  }
                                }),
                            Obx(() {
                              return Text(
                                controller
                                    .maxParticipantsForSlot(title, slot)
                                    .toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            }),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              iconSize: TSizes.iconBase,
                              onPressed: () {
                                if (totalMaxParticipants <
                                    requiredParticipants) {
                                  controller
                                      .incrementMaxParticipantsForSlot(
                                          title, slot);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: TSizes.iconSm,
                        onPressed: () => controller
                            .removeTimeSlot(title, slot),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _showTimePicker(String section) async {
    final TimeOfDay? pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return ModernTimePicker(
          section: section,
          onTimeSelected: (TimeOfDay time) {
            Navigator.of(context).pop(time);
          },
        );
      },
    );

    if (pickedTime != null) {
      // Handle the selected time
      controller.addTimeSlot(section, pickedTime);
      if (controller.tooltipShown == false) {
        await _showAndCloseTooltip();
        controller.tooltipShown = true;
      }
      // print('Selected time: ${pickedTime.format(context)}');
    }
  }

  Future _showAndCloseTooltip() async {
    await Future.delayed(const Duration(milliseconds: 10));
    final tooltipKey = GlobalKey<TooltipState>();
    final tooltip = tooltipKey.currentState;
    tooltip?.ensureTooltipVisible();
    await Future.delayed(const Duration(seconds: 4));
    tooltip?.deactivate();
  }
}




class ModernTimePicker extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;
  final String section;

  const ModernTimePicker({
    super.key,
    required this.onTimeSelected,
    required this.section,
  });

  @override
  _ModernTimePickerState createState() => _ModernTimePickerState();
}

class _ModernTimePickerState extends State<ModernTimePicker> {
  late TimeOfDay _selectedTime;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedTime = _getInitialTime(widget.section);
    _hourController =
        FixedExtentScrollController(initialItem: _selectedTime.hour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedTime.minute);
  }

  TimeOfDay _getInitialTime(String section) {
    switch (section) {
      case 'Pagi':
        return const TimeOfDay(hour: 6, minute: 0);
      case 'Siang':
        return const TimeOfDay(hour: 12, minute: 0);
      case 'Malam':
        return const TimeOfDay(hour: 17, minute: 0);
      default:
        return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TColors.primary.withOpacity(0.1),
              TColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Time for ${widget.section}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimePicker(context, true), // For hours
                  const SizedBox(width: 8),
                  _buildTimePicker(context, false), // For minutes
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: TColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: TColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        widget.onTimeSelected(_selectedTime);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, bool isHour) {
    return Container(
      height: 180,
      width: 80,
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListWheelScrollView.useDelegate(
        controller: isHour ? _hourController : _minuteController,
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: isHour ? 24 : 60,
          builder: (context, index) {
            return _buildTimeItem(context, index, isHour);
          },
        ),
        onSelectedItemChanged: (index) {
          setState(() {
            if (isHour) {
              _selectedTime =
                  TimeOfDay(hour: index, minute: _selectedTime.minute);
            } else {
              _selectedTime =
                  TimeOfDay(hour: _selectedTime.hour, minute: index);
            }
          });
        },
      ),
    );
  }

  Widget _buildTimeItem(BuildContext context, int index, bool isHour) {
    final isSelected =
        isHour ? index == _selectedTime.hour : index == _selectedTime.minute;

    return Center(
      child: Text(
        isHour ? '$index'.padLeft(2, '0') : '$index'.padLeft(2, '0'),
        style: TextStyle(
          fontSize: isSelected ? 24 : 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? TColors.primary : TColors.textSecondary,
        ),
      ),
    );
  }
}
