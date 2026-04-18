import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../services/treatment_provider.dart';

class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({super.key});

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AuthViewModel>().currentUser?.id;
      if (patientId != null && patientId.isNotEmpty) {
        context.read<TreatmentProvider>().loadAllPrises(patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TreatmentProvider>();
    final dayCounts = _buildMedicationCountByDay(provider);
    final selectedCount = dayCounts[_dayKey(_selectedDate)] ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Calendrier de prise',
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
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
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
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right),
          color: AppColors.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildWeekdaysHeader() {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 44,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 13,
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

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: _buildDayCard(
            day: day,
            isToday: _isToday(date),
            isSelected: _isSelected(date),
            medicationCount: count,
          ),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
      rows.add(const SizedBox(height: 10));
    }

    return Column(children: rows);
  }

  Widget _buildDayCard({
    required int day,
    required bool isToday,
    required bool isSelected,
    required int medicationCount,
  }) {
    return Container(
      width: 44,
      height: 66,
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (medicationCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

  Widget _buildSelectedDateInfo(int medicationCount) {
    final dateStr =
        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date sélectionnée',
            style: TextStyle(
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
                'Voir les prises de la journée',
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
    ];
    return months[month - 1];
  }
}
