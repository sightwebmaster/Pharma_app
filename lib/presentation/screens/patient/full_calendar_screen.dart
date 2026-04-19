import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../../core/constants/app_colors.dart';
=======
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../services/treatment_provider.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({super.key});

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

<<<<<<< HEAD
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

=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
<<<<<<< HEAD
=======

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AuthViewModel>().currentUser?.id;
      if (patientId != null && patientId.isNotEmpty) {
        context.read<TreatmentProvider>().loadAllPrises(patientId);
      }
    });
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    final provider = context.watch<TreatmentProvider>();
    final dayCounts = _buildMedicationCountByDay(provider);
    final selectedCount = dayCounts[_dayKey(_selectedDate)] ?? 0;

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
<<<<<<< HEAD
          'Planning Calendar',
=======
          'Calendrier de prise',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
              _buildCalendarGrid(),
              const SizedBox(height: 32),
              _buildSelectedDateInfo(),
              const SizedBox(height: 16),
=======
              _buildCalendarGrid(dayCounts),
              const SizedBox(height: 24),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              _buildSelectedDateInfo(selectedCount),
              if ((provider.error ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ],
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
=======
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
=======
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
            });
          },
          icon: const Icon(Icons.chevron_right),
          color: AppColors.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildWeekdaysHeader() {
<<<<<<< HEAD
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
=======
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekdays
          .map(
            (day) => SizedBox(
<<<<<<< HEAD
              width: 50,
=======
              width: 44,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
<<<<<<< HEAD
                    fontSize: 14,
=======
                    fontSize: 13,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
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
=======
  Widget _buildCalendarGrid(Map<String, int> dayCounts) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;
    final dayWidgets = <Widget>[];

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 44, height: 66));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final count = dayCounts[_dayKey(date)] ?? 0;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
<<<<<<< HEAD
          child: _buildDayCard(day, isToday, isSelected, medicationCount),
=======
          child: _buildDayCard(
            day: day,
            isToday: _isToday(date),
            isSelected: _isSelected(date),
            medicationCount: count,
          ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        ),
      );
    }

<<<<<<< HEAD
    // Create rows of 7
    List<Widget> rows = [];
=======
    final rows = <Widget>[];
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
<<<<<<< HEAD
          children: dayWidgets
              .sublist(i, i + 7 > dayWidgets.length ? dayWidgets.length : i + 7)
              .toList(),
        ),
      );
      rows.add(const SizedBox(height: 12));
=======
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
      rows.add(const SizedBox(height: 10));
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    }

    return Column(children: rows);
  }

<<<<<<< HEAD
  Widget _buildDayCard(
    int day,
    bool isToday,
    bool isSelected,
    int medicationCount,
  ) {
    return Container(
      width: 50,
      height: 70,
=======
  Widget _buildDayCard({
    required int day,
    required bool isToday,
    required bool isSelected,
    required int medicationCount,
  }) {
    return Container(
      width: 44,
      height: 66,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue
            : isToday
<<<<<<< HEAD
            ? AppColors.primaryGreen.withOpacity(0.1)
            : AppColors.white,
=======
                ? AppColors.primaryGreen.withOpacity(0.1)
                : AppColors.white,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        border: Border.all(
          color: isToday
              ? AppColors.primaryGreen
              : isSelected
<<<<<<< HEAD
              ? AppColors.primaryBlue
              : AppColors.lightGrey,
=======
                  ? AppColors.primaryBlue
                  : AppColors.lightGrey,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
              fontSize: 16,
=======
              fontSize: 15,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (medicationCount > 0)
            Container(
<<<<<<< HEAD
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
=======
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
  Widget _buildSelectedDateInfo() {
    final medicationCount = _medicationCountByDay[_selectedDate.day] ?? 0;
    final dateStr =
        '${_getMonthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}';
=======
  Widget _buildSelectedDateInfo(int medicationCount) {
    final dateStr =
        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
=======
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.2),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Text(
            'Selected Date',
            style: const TextStyle(
=======
          const Text(
            'Date sélectionnée',
            style: TextStyle(
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
              Icon(Icons.medication, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Medications scheduled: $medicationCount',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
=======
              const Icon(Icons.medication, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medicationCount > 0
                      ? '$medicationCount prise(s) planifiée(s) ce jour'
                      : 'Aucune prise planifiée pour cette date',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
                'View Medications',
=======
                'Voir les prises de la journée',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
=======
  Map<String, int> _buildMedicationCountByDay(TreatmentProvider provider) {
    final counts = <String, int>{};
    for (final prise in provider.allPrises) {
      final when = prise.heurePrevueDateTime;
      if (when == null) {
        continue;
      }
      final key = _dayKey(when);
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
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
=======
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    ];
    return months[month - 1];
  }
}
