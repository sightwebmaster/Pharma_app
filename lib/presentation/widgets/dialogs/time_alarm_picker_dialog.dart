import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';
import 'package:pharma_app/presentation/widgets/common/app_buttons.dart';

/// TimeAlarmPickerDialog - Dialog pour sélectionner l'heure d'alarme
class TimeAlarmPickerDialog extends StatefulWidget {
<<<<<<< HEAD
  final Function(String) onSave; // Retourne "HH:mm AM/PM"
=======
  final ValueChanged<String> onSave; // Retourne "HH:mm AM/PM"
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  final String? initialTime;

  const TimeAlarmPickerDialog({
    Key? key,
    required this.onSave,
    this.initialTime,
  }) : super(key: key);

  @override
  State<TimeAlarmPickerDialog> createState() => _TimeAlarmPickerDialogState();
}

class _TimeAlarmPickerDialogState extends State<TimeAlarmPickerDialog> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedPeriodIndex;

  final List<String> _periods = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _parseInitialTime();
  }

  void _parseInitialTime() {
    // Format par défaut: "09:30 AM"
    int hour = 9;
    int minute = 30;
    int periodIndex = 0;

    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      final parts = widget.initialTime!.split(' ');
      if (parts.length == 2) {
        final timeParts = parts[0].split(':');
        if (timeParts.length == 2) {
          hour = int.tryParse(timeParts[0]) ?? 9;
          minute = int.tryParse(timeParts[1]) ?? 30;
          periodIndex = parts[1] == 'PM' ? 1 : 0;
        }
      }
    }

    _selectedHour = hour - 1; // Index pour le picker
    _selectedMinute = minute;
    _selectedPeriodIndex = periodIndex;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
    _periodController = FixedExtentScrollController(
      initialItem: _selectedPeriodIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            Text(
              'Set Time for Alarm',
              style: AppTextStyles.questionText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Pickers
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Heures (01-12)
                  _buildPickerColumn(
                    controller: _hourController,
                    itemCount: 12,
                    onSelectedItemChanged: (index) {
                      _selectedHour = index;
                    },
                    itemBuilder: (context, index) {
                      return Text(
                        _formatNumber(index + 1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  // Séparateur
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Minutes (00-59)
                  _buildPickerColumn(
                    controller: _minuteController,
                    itemCount: 60,
                    onSelectedItemChanged: (index) {
                      _selectedMinute = index;
                    },
                    itemBuilder: (context, index) {
                      return Text(
                        _formatNumber(index),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // AM/PM
                  _buildPickerColumn(
                    controller: _periodController,
                    itemCount: 2,
                    onSelectedItemChanged: (index) {
                      _selectedPeriodIndex = index;
                    },
                    itemBuilder: (context, index) {
                      return Text(
                        _periods[index],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bouttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Save',
                    onPressed: () {
                      final hour = _formatNumber(_selectedHour + 1);
                      final minute = _formatNumber(_selectedMinute);
                      final period = _periods[_selectedPeriodIndex];
                      final selectedTime = '$hour:$minute $period';
<<<<<<< HEAD
                      Navigator.pop(context);
                      widget.onSave(selectedTime);
=======
                      widget.onSave(selectedTime);
                      Navigator.pop(context);
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build picker colonne
  Widget _buildPickerColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required Function(int) onSelectedItemChanged,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Highlight band
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F7),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Picker
          ListWheelScrollView(
            controller: controller,
            itemExtent: 40,
            onSelectedItemChanged: onSelectedItemChanged,
            physics: const FixedExtentScrollPhysics(),
            children: List.generate(
              itemCount,
              (index) => Center(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  child: itemBuilder(context, index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format nombre (01, 02, etc.)
  String _formatNumber(int n) {
    return n.toString().padLeft(2, '0');
  }
}

/// Afficher le Time Picker Dialog
Future<String?> showTimePickerDialog(
  BuildContext context, {
  String? initialTime,
}) {
<<<<<<< HEAD
=======
  String? selectedTime;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  return showDialog<String>(
    context: context,
    builder: (context) => TimeAlarmPickerDialog(
      initialTime: initialTime,
      onSave: (time) {
<<<<<<< HEAD
        Navigator.pop(context, time);
      },
    ),
  );
=======
        selectedTime = time;
      },
    ),
  ).then((_) => selectedTime);
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
}
