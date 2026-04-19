import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../core/constants/app_colors.dart';
=======
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/treatment_provider.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

class WeekCalendarWidget extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const WeekCalendarWidget({required this.onDaySelected, super.key});

  @override
  State<WeekCalendarWidget> createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    _weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    final prises = context.watch<TreatmentProvider>().allPrises;

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_weekDays.length, (index) {
          final date = _weekDays[index];
          final isToday = _isToday(date);
          final isSelected = _isSelected(date);
<<<<<<< HEAD
=======
          final hasPrises = prises.any((prise) {
            final dt = prise.heurePrevueDateTime;
            return dt != null &&
                dt.year == date.year &&
                dt.month == date.month &&
                dt.day == date.day;
          });
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDaySelected(date);
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? AppColors.primaryBlue
                      : isToday
                      ? AppColors.primaryGreen.withAlpha((0.2 * 255).toInt())
                      : AppColors.lightGrey,
                  border: isToday
                      ? Border.all(color: AppColors.primaryGreen, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.white : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Indicateur de médicaments
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
<<<<<<< HEAD
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryGreen,
=======
                        color: hasPrises
                            ? (isSelected ? AppColors.white : AppColors.primaryGreen)
                            : Colors.transparent,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
