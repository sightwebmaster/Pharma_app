import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({super.key});

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  // Mock data: number of medications per day
  final Map<int, int> _medicationCountByDay = {
    1: 2,
    2: 3,
    3: 2,
    4: 0,
    5: 4,
    6: 2,
    7: 3,
    8: 2,
    9: 1,
    10: 2,
    11: 0,
    12: 3,
    13: 2,
    14: 2,
    15: 4,
    16: 1,
    17: 2,
    18: 3,
    19: 2,
    20: 2,
    21: 0,
    22: 3,
    23: 2,
    24: 2,
    25: 2,
    26: 1,
    27: 3,
    28: 2,
    29: 2,
    30: 4,
    31: 2,
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Planning Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 24),
              _buildWeekdaysHeader(),
              const SizedBox(height: 12),
              _buildCalendarGrid(),
              const SizedBox(height: 32),
              _buildSelectedDateInfo(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
          color: AppColors.primaryBlue,
        ),
        Column(
          children: [
            Text(
              _getMonthName(_currentMonth.month),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              _currentMonth.year.toString(),
              style: const TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
          color: AppColors.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildWeekdaysHeader() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 50,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;

    // Monday = 1, Sunday = 7, so we need to adjust
    int firstWeekday = firstDayOfMonth.weekday;
    List<Widget> dayWidgets = [];

    // Add empty spaces for days before month starts
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 50, height: 70));
    }

    // Add day widgets
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday = _isToday(date);
      final isSelected = _isSelected(date);
      final medicationCount = _medicationCountByDay[day] ?? 0;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: _buildDayCard(day, isToday, isSelected, medicationCount),
        ),
      );
    }

    // Create rows of 7
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dayWidgets
              .sublist(i, i + 7 > dayWidgets.length ? dayWidgets.length : i + 7)
              .toList(),
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    return Column(children: rows);
  }

  Widget _buildDayCard(
    int day,
    bool isToday,
    bool isSelected,
    int medicationCount,
  ) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue
            : isToday
            ? AppColors.primaryGreen.withOpacity(0.1)
            : AppColors.white,
        border: Border.all(
          color: isToday
              ? AppColors.primaryGreen
              : isSelected
              ? AppColors.primaryBlue
              : AppColors.lightGrey,
          width: isToday || isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (medicationCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medicationCount.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primaryGreen : AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final medicationCount = _medicationCountByDay[_selectedDate.day] ?? 0;
    final dateStr =
        '${_getMonthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Date',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.medication, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Medications scheduled: $medicationCount',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/medication-details',
                  arguments: _selectedDate,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'View Medications',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
