import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../../core/constants/app_colors.dart';
=======
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/prise_planifiee.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../services/treatment_provider.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

class MedicationDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;

  const MedicationDetailsScreen({required this.selectedDate, super.key});

  @override
<<<<<<< HEAD
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

=======
  State<MedicationDetailsScreen> createState() => _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
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
    final prises = provider.allPrises.where(_matchesSelectedDate).toList()
      ..sort((a, b) => (a.heurePrevueDateTime ?? DateTime(2100))
          .compareTo(b.heurePrevueDateTime ?? DateTime(2100)));

    final morning = prises.where((prise) => _periodFor(prise) == 'Matin').toList();
    final afternoon =
        prises.where((prise) => _periodFor(prise) == 'Après-midi').toList();
    final evening = prises.where((prise) => _periodFor(prise) == 'Soir').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Prises du ${_formatDate(widget.selectedDate)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: provider.isLoading && provider.allPrises.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final patientId = context.read<AuthViewModel>().currentUser?.id;
                if (patientId != null && patientId.isNotEmpty) {
                  await context.read<TreatmentProvider>().loadAllPrises(patientId);
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.error != null && provider.allPrises.isEmpty)
                    _buildMessageCard(
                      provider.error!,
                      AppColors.errorRed.withOpacity(0.08),
                      AppColors.errorRed,
                    ),
                  if (prises.isEmpty)
                    _buildEmptyState()
                  else ...[
                    if (morning.isNotEmpty) _buildTimeSection('Matin', morning, '🌅'),
                    if (afternoon.isNotEmpty)
                      _buildTimeSection('Après-midi', afternoon, '☀️'),
                    if (evening.isNotEmpty) _buildTimeSection('Soir', evening, '🌙'),
                  ],
                ],
              ),
            ),
    );
  }

  bool _matchesSelectedDate(PrisePlanifiee prise) {
    final dt = prise.heurePrevueDateTime;
    if (dt == null) {
      return false;
    }
    return dt.year == widget.selectedDate.year &&
        dt.month == widget.selectedDate.month &&
        dt.day == widget.selectedDate.day;
  }

  String _periodFor(PrisePlanifiee prise) {
    final hour = prise.heurePrevueDateTime?.hour ?? 0;
    if (hour < 12) return 'Matin';
    if (hour < 18) return 'Après-midi';
    return 'Soir';
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTimeSection(String title, List<PrisePlanifiee> prises, String emoji) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
<<<<<<< HEAD
              Text(
                getIcon(medications[0]['time']),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                timeOfDay,
=======
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                title,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
<<<<<<< HEAD
        ...medications.map((med) {
          return _buildMedicationCard(med);
        }),
        const SizedBox(height: 8),
=======
        ...prises.map(_buildMedicationCard),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildMedicationCard(Map<String, dynamic> medication) {
=======
  Widget _buildMedicationCard(PrisePlanifiee prise) {
    final statusColor = prise.isConfirmed
        ? AppColors.primaryGreen
        : prise.isMissed
            ? AppColors.errorRed
            : AppColors.primaryBlue;

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
<<<<<<< HEAD
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
=======
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
<<<<<<< HEAD
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
<<<<<<< HEAD
                      medication['name'],
=======
                      prise.medicamentNom,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
<<<<<<< HEAD
                      '${medication['dosage']} • ${medication['category']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
=======
                      _formatTime(prise.heurePrevueDateTime),
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                    ),
                  ],
                ),
              ),
              Container(
<<<<<<< HEAD
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
=======
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prise.statut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
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
=======
          if ((prise.dosage ?? '').isNotEmpty || (prise.type).isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              [
                if ((prise.dosage ?? '').isNotEmpty) prise.dosage!,
                if (prise.type.isNotEmpty && prise.type != 'Inconnu') prise.type,
              ].join(' • '),
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ],
          if ((prise.instruction ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              prise.instruction!,
              style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Heure non disponible';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_month_outlined, size: 42, color: AppColors.grey),
          SizedBox(height: 12),
          Text(
            'Aucune prise planifiée',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Les prises planifiées pour cette date apparaîtront ici automatiquement.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message, Color background, Color foreground) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        ],
      ),
    );
  }
}
