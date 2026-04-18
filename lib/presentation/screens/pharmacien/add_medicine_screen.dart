import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';
import 'package:pharma_app/presentation/widgets/common/app_buttons.dart';
import 'package:pharma_app/presentation/widgets/common/app_card.dart';
import 'package:pharma_app/presentation/widgets/common/app_text_field.dart';
import 'package:pharma_app/presentation/widgets/common/icon_circle.dart';
import 'package:pharma_app/presentation/widgets/dialogs/time_alarm_picker_dialog.dart';
import 'package:pharma_app/presentation/widgets/medical/profile_pill.dart';
import 'package:pharma_app/presentation/widgets/medical/segmented_meal_selector.dart';
import 'package:pharma_app/presentation/screens/pharmacien/pharmacien_dashboard.dart';
import 'package:pharma_app/services/storage_service.dart';
import 'package:pharma_app/services/treatment_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final String allergies;
  final bool isPregnant;
  final String? initialMedicationName;
  final String? initialDosage;
  final String? initialType;
  final int? initialDurationDays;
  final String? recommendationNote;

  const AddMedicineScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.allergies,
    required this.isPregnant,
    this.initialMedicationName,
    this.initialDosage,
    this.initialType,
    this.initialDurationDays,
    this.recommendationNote,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late final TextEditingController _medicineNameController;
  late final TextEditingController _typeController;
  late final TextEditingController _doseController;
  late final TextEditingController _durationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _motifController;

  String _selectedMealType = 'Before Meals';
  int _timesPerDay = 1;
  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _scheduledTimes = const ['08:00'];
  late List<String> _availableDosages;

  final List<String> _medicineTypes = const [
    'Capsule',
    'Comprime',
    'Sirop',
    'Injection',
    'Poudre',
  ];

  @override
  void initState() {
    super.initState();
    final initialDuration = widget.initialDurationDays ?? 7;
    _startDate = DateTime.now();
    _endDate = _startDate.add(Duration(days: initialDuration - 1));
    _availableDosages = _extractDosageOptions(widget.initialDosage);

    _medicineNameController = TextEditingController(
      text: widget.initialMedicationName ?? '',
    );
    _typeController = TextEditingController(text: widget.initialType ?? '');
    _doseController = TextEditingController(
      text: _availableDosages.isNotEmpty
          ? _availableDosages.first
          : (widget.initialDosage ?? ''),
    );
    _durationController = TextEditingController(text: initialDuration.toString());
    _startDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_startDate),
    );
    _endDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_endDate),
    );
    _motifController = TextEditingController(
      text: widget.recommendationNote?.trim().isNotEmpty == true
          ? widget.recommendationNote!.trim()
          : 'Prescription medicale',
    );

    _rebuildScheduledTimes();
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _typeController.dispose();
    _doseController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  List<String> _extractDosageOptions(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    final normalized = raw
        .replaceAll(' ou ', '|')
        .replaceAll(' OR ', '|')
        .replaceAll(' / ', '|')
        .replaceAll('/', '|')
        .replaceAll(';', '|')
        .replaceAll(',', '|');

    return normalized
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  void _showMedicineTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        color: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Type du medicament', style: AppTextStyles.cardTitle),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _medicineTypes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_medicineTypes[index], style: AppTextStyles.fieldValue),
                    onTap: () {
                      setState(() {
                        _typeController.text = _medicineTypes[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDosageBottomSheet() {
    if (_availableDosages.length <= 1) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        color: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Choisir le dosage', style: AppTextStyles.cardTitle),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _availableDosages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final dosage = _availableDosages[index];
                  return ListTile(
                    title: Text(dosage, style: AppTextStyles.fieldValue),
                    trailing: dosage == _doseController.text
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _doseController.text = dosage;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _startDate = selectedDate;
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
      _syncDateControllers();
    });
  }

  Future<void> _pickEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _endDate = selectedDate;
      _syncDateControllers();
    });
  }

  void _syncDateControllers() {
    _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
    _durationController.text = (_endDate.difference(_startDate).inDays + 1).toString();
  }

  void _incrementTimes() {
    setState(() {
      _timesPerDay++;
      _rebuildScheduledTimes();
    });
  }

  void _decrementTimes() {
    if (_timesPerDay <= 1) {
      return;
    }
    setState(() {
      _timesPerDay--;
      _rebuildScheduledTimes();
    });
  }

  void _rebuildScheduledTimes() {
    final defaults = _defaultHeuresPrise(_timesPerDay);
    _scheduledTimes = List<String>.generate(
      _timesPerDay,
      (index) => index < _scheduledTimes.length ? _scheduledTimes[index] : defaults[index],
    );
  }

  Future<void> _pickScheduledTime(int index) async {
    final selectedTime = await showTimePickerDialog(
      context,
      initialTime: _formatDisplayTime(_scheduledTimes[index]),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _scheduledTimes[index] = _normalizeTo24h(selectedTime);
    });
  }

  Future<void> _saveTreatment() async {
    if (_medicineNameController.text.trim().isEmpty ||
        _typeController.text.trim().isEmpty ||
        _doseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les informations obligatoires du traitement'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final storage = StorageService();
    final token = await storage.getAccessToken();
    final pharmacienId = storage.getUserId();

    if (token == null || pharmacienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expiree - reconnectez-vous'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final body = <String, dynamic>{
      'patientUserId': widget.patientId,
      'acteurId': pharmacienId,
      'acteurRole': 'PHARMACIEN',
      'dateDebut': DateFormat('yyyy-MM-dd').format(_startDate),
      'dateFin': DateFormat('yyyy-MM-dd').format(_endDate),
      'motif': _motifController.text.trim().isEmpty
          ? 'Prescription medicale'
          : _motifController.text.trim(),
      'lignes': [
        {
          'medicamentNom': _medicineNameController.text.trim(),
          'principeActif': _medicineNameController.text.trim(),
          'dosage': _doseController.text.trim(),
          'type': _typeController.text.trim(),
          'dureeJours': _endDate.difference(_startDate).inDays + 1,
          'heuresPrise': _scheduledTimes,
          'instructions': _mealInstruction(_selectedMealType),
        },
      ],
    };

    final provider = context.read<TreatmentProvider>();
    final result = await provider.creerTraitement(body, token);

    if (!mounted) {
      return;
    }

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traitement planifie avec succes'),
          backgroundColor: Colors.green,
        ),
      );
      await _showReceiptSheet();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Erreur lors de la planification du traitement'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  Future<void> _showReceiptSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Recu de planification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Le traitement est enregistre et sera visible dans le suivi patient.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              _buildReceiptRow('Patient', widget.patientName),
              _buildReceiptRow('Medicament', _medicineNameController.text.trim()),
              _buildReceiptRow('Dosage', _doseController.text.trim()),
              _buildReceiptRow('Date debut', _startDateController.text),
              _buildReceiptRow('Date fin', _endDateController.text),
              _buildReceiptRow('Prises / jour', _timesPerDay.toString()),
              _buildReceiptRow('Heures', _scheduledTimes.join(' - ')),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Fermer',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const PharmacienDashboard(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _defaultHeuresPrise(int timesPerDay) {
    switch (timesPerDay) {
      case 1:
        return ['08:00'];
      case 2:
        return ['08:00', '20:00'];
      case 3:
        return ['08:00', '14:00', '20:00'];
      case 4:
        return ['08:00', '12:00', '16:00', '20:00'];
      default:
        final interval = 24 ~/ timesPerDay;
        return List.generate(timesPerDay, (index) {
          final hour = (8 + index * interval) % 24;
          return '${hour.toString().padLeft(2, '0')}:00';
        });
    }
  }

  String _mealInstruction(String mealType) {
    switch (mealType) {
      case 'After Meals':
        return 'Prendre apres les repas';
      case 'With Meals':
        return 'Prendre pendant les repas';
      default:
        return 'Prendre avant les repas';
    }
  }

  String _formatDisplayTime(String time24h) {
    final parts = time24h.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _normalizeTo24h(String formatted) {
    final parts = formatted.split(' ');
    if (parts.length != 2) {
      return formatted;
    }
    final time = parts[0].split(':');
    if (time.length != 2) {
      return formatted;
    }

    int hour = int.tryParse(time[0]) ?? 8;
    final minute = int.tryParse(time[1]) ?? 0;
    final isPm = parts[1].toUpperCase() == 'PM';

    if (isPm && hour != 12) {
      hour += 12;
    } else if (!isPm && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Planifier un traitement', style: AppTextStyles.pageTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROFIL PATIENT', style: AppTextStyles.sectionLabel),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProfilePill(
                      icon: Icons.person,
                      label: widget.patientName,
                      value: 'Patient',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfilePill(
                      icon: Icons.cake,
                      label: '${widget.patientAge} ans',
                      value: 'Age',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfilePill(
                      icon: widget.patientSex == 'Male' ? Icons.male : Icons.female,
                      label: widget.patientSex.toUpperCase(),
                      value: 'Sexe',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  children: [
                    IconCircle(icon: Icons.warning_amber_rounded, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Allergies: ${widget.allergies.isEmpty ? 'Aucune' : widget.allergies}',
                        style: AppTextStyles.fieldValue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('DETAILS DU TRAITEMENT', style: AppTextStyles.sectionLabel),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Nom du medicament',
                hintText: 'Ex: Amoxicilline',
                controller: _medicineNameController,
                trailingIcon: Icons.local_pharmacy_outlined,
              ),
              AppTextField(
                label: 'Type',
                hintText: 'Selectionner le type',
                controller: _typeController,
                trailingIcon: Icons.arrow_drop_down,
                readOnly: true,
                onTraillingIconTap: _showMedicineTypeBottomSheet,
                onTap: _showMedicineTypeBottomSheet,
              ),
              AppTextField(
                label: 'Dosage final',
                hintText: _availableDosages.length > 1 ? 'Choisir le dosage' : '500mg',
                controller: _doseController,
                trailingIcon: Icons.straighten,
                readOnly: _availableDosages.length > 1,
                onTap: _availableDosages.length > 1 ? _showDosageBottomSheet : null,
                onTraillingIconTap: _availableDosages.length > 1 ? _showDosageBottomSheet : null,
              ),
              if (_availableDosages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Plusieurs dosages sont proposes. Selectionnez le dosage retenu.',
                    style: AppTextStyles.fieldLabel,
                  ),
                ),
              AppTextField(
                label: 'Motif',
                hintText: 'Prescription medicale',
                controller: _motifController,
                trailingIcon: Icons.description_outlined,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre de prises par jour', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _decrementTimes,
                              child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Center(
                                child: Text(_timesPerDay.toString(), style: AppTextStyles.fieldValue),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _incrementTimes,
                              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.schedule, color: AppColors.textLabel, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SegmentedMealSelector(
                initialValue: _selectedMealType,
                onChanged: (value) => setState(() => _selectedMealType = value),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Date de debut',
                      hintText: 'YYYY-MM-DD',
                      controller: _startDateController,
                      trailingIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Date de fin',
                      hintText: 'YYYY-MM-DD',
                      controller: _endDateController,
                      trailingIcon: Icons.event_available,
                      readOnly: true,
                      onTap: _pickEndDate,
                    ),
                  ),
                ],
              ),
              AppTextField(
                label: 'Duree totale',
                hintText: '7',
                controller: _durationController,
                trailingIcon: Icons.timelapse_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              Text('Heures exactes des rappels', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              ...List.generate(_scheduledTimes.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => _pickScheduledTime(index),
                    child: Row(
                      children: [
                        IconCircle(icon: Icons.alarm, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prise ${index + 1}', style: AppTextStyles.fieldValue),
                              Text(
                                _formatDisplayTime(_scheduledTimes[index]),
                                style: AppTextStyles.fieldLabel,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              Consumer<TreatmentProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    label: 'Enregistrer le traitement',
                    isLoading: provider.isLoading,
                    onPressed: _saveTreatment,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
