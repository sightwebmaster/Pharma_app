import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;

  const MedicationDetailsScreen({required this.selectedDate, super.key});

  @override
  State<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  // Données mockées provisoires
  final Map<String, List<Map<String, dynamic>>> _medicationsByTime = {
    'Morning': [
      {
        'name': 'Amlodipine',
        'dosage': '5mg',
        'time': '08:00',
        'taken': true,
        'category': 'Cardiovascular',
        'instructions': 'Before meals',
      },
      {
        'name': 'Metformin',
        'dosage': '500mg',
        'time': '08:00',
        'taken': true,
        'category': 'Diabetes',
        'instructions': 'With meals',
      },
    ],
    'Afternoon': [
      {
        'name': 'Lisinopril',
        'dosage': '10mg',
        'time': '12:00',
        'taken': false,
        'category': 'Cardiovascular',
        'instructions': 'Anytime',
      },
    ],
    'Evening': [
      {
        'name': 'Atorvastatin',
        'dosage': '20mg',
        'time': '20:00',
        'taken': false,
        'category': 'Cholesterol',
        'instructions': 'Before bed',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dateFormatter = _formatDate(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Medications for $dateFormatter',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            children: _medicationsByTime.entries.map((entry) {
              return _buildTimeSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildTimeSection(
    String timeOfDay,
    List<Map<String, dynamic>> medications,
  ) {
    String getIcon(String time) {
      if (time.contains('08')) return '🌅';
      if (time.contains('12')) return '☀️';
      return '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Text(
                getIcon(medications[0]['time']),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                timeOfDay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        ...medications.map((med) {
          return _buildMedicationCard(med);
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: medication['taken']
            ? AppColors.primaryGreen.withOpacity(0.1)
            : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: medication['taken']
              ? AppColors.primaryGreen
              : AppColors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication['dosage']} • ${medication['category']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: medication['taken']
                      ? AppColors.primaryGreen
                      : AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  medication['taken'] ? Icons.check : Icons.close,
                  color: medication['taken'] ? AppColors.white : AppColors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.grey),
              const SizedBox(width: 6),
              Text(
                medication['time'],
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(width: 16),
              Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  medication['instructions'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          if (!medication['taken'])
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Mark as taken
                    setState(() {
                      medication['taken'] = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Mark as Taken',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
