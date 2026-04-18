import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../presentation/viewmodels/recommendation_viewmodel.dart';
import '../../../services/patient_profile_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    this.patientId,
    this.isPharmacienMode = false,
    this.patientDisplayName,
  });

  final String? patientId;
  final bool isPharmacienMode;
  final String? patientDisplayName;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final PatientProfileService _profileService = PatientProfileService();

  UserModel? _targetPatient;
  bool _isLoadingProfile = false;
  int? _selectedMedicationIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<RecommendationViewModel>().clear();
      await _loadPatientContext();
    });
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientContext() async {
    setState(() => _isLoadingProfile = true);

    final authVm = context.read<AuthViewModel>();
    if (!widget.isPharmacienMode) {
      _targetPatient = authVm.currentUser;
      if (_targetPatient?.id.isNotEmpty == true) {
        await context.read<RecommendationViewModel>().loadHistory(_targetPatient!.id);
      }
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
      return;
    }

    final patientId = widget.patientId;
    if (patientId != null && patientId.isNotEmpty) {
      final response = await _profileService.getPatientProfile(patientId);
      if (response.success && response.data != null) {
        _targetPatient = response.data;
        await context.read<RecommendationViewModel>().loadHistory(patientId);
      }
    }

    if (mounted) {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final recommendationVm = context.watch<RecommendationViewModel>();
    final recommendation = recommendationVm.currentRecommendation;
    final patient = _targetPatient ?? authVm.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      appBar: AppBar(
        title: Text(widget.isPharmacienMode ? 'Analyse patient' : 'Recommandation IA'),
        backgroundColor: widget.isPharmacienMode
            ? AppColors.primaryBlue
            : AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(patient),
            const SizedBox(height: 20),
            _buildSymptomsCard(recommendationVm),
            if (recommendationVm.errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildMessageCard(
                recommendationVm.errorMessage!,
                backgroundColor: const Color(0xFFFFF1F0),
                foregroundColor: AppColors.errorRed,
                icon: Icons.error_outline,
              ),
            ],
            if (_isLoadingProfile) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (recommendation != null) ...[
              const SizedBox(height: 20),
              _buildResultSummary(recommendation),
              const SizedBox(height: 16),
              ...List.generate(
                recommendation.recommendedMedications.length,
                (index) => _buildMedicationTile(
                  recommendation.recommendedMedications[index],
                  index,
                ),
              ),
              if (widget.isPharmacienMode) ...[
                const SizedBox(height: 20),
                _buildPharmacienActions(recommendation),
              ] else ...[
                const SizedBox(height: 20),
                _buildPatientStateCard(recommendation),
              ],
            ],
            if (recommendationVm.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Historique récent',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...recommendationVm.history.take(5).map(_buildHistoryItem),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHero(UserModel? patient) {
    final displayName = widget.patientDisplayName ??
        patient?.fullName ??
        (widget.isPharmacienMode ? 'Patient à sélectionner' : 'Patient');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isPharmacienMode
              ? const [AppColors.primaryBlue, Color(0xFF6786FF)]
              : const [AppColors.primaryGreen, Color(0xFF13C6AE)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isPharmacienMode
                ? 'Scanner ou sélectionner un patient, analyser ses symptômes puis valider un traitement final.'
                : 'Décrivez vos symptômes. Le résultat est stocké et pourra être validé par votre pharmacien.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          if (patient != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(patient.groupeSanguin ?? 'Groupe non renseigné'),
                _buildInfoChip('${_calculateAge(patient.dateNaissance)} ans'),
                if (patient.allergies.isNotEmpty) _buildInfoChip('${patient.allergies.length} allergies'),
                if (patient.enceinte == true) _buildInfoChip('Grossesse'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSymptomsCard(RecommendationViewModel recommendationVm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isPharmacienMode ? 'Symptômes observés' : 'Symptômes ressentis',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _symptomsController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Exemple: fièvre depuis 2 jours, mal de gorge, toux sèche, fatigue...',
              filled: true,
              fillColor: const Color(0xFFF8FBFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: recommendationVm.isLoading ? null : _submitAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isPharmacienMode
                    ? AppColors.primaryBlue
                    : AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: recommendationVm.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.psychology_alt_outlined, color: Colors.white),
              label: const Text(
                'Analyser les symptômes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary(RecommendationModel recommendation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maladie probable',
                      style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.primaryDisease,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(recommendation.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Confiance ${recommendation.confidenceLabel ?? 'N/A'}'
            '${recommendation.topScore != null ? ' • ${(recommendation.topScore! * 100).toStringAsFixed(0)}%' : ''}',
            style: const TextStyle(color: AppColors.grey),
          ),
          if ((recommendation.patientAdvice ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMessageCard(
              recommendation.patientAdvice!,
              backgroundColor: const Color(0xFFEFFAF7),
              foregroundColor: AppColors.primaryGreen,
              icon: Icons.tips_and_updates_outlined,
            ),
          ],
          if (recommendation.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...recommendation.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMessageCard(
                  warning,
                  backgroundColor: const Color(0xFFFFF7E8),
                  foregroundColor: const Color(0xFFB7791F),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ),
          ],
          if (recommendation.pharmacistAlerts.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...recommendation.pharmacistAlerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMessageCard(
                  alert,
                  backgroundColor: const Color(0xFFFFF1F0),
                  foregroundColor: AppColors.errorRed,
                  icon: Icons.health_and_safety_outlined,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.toUpperCase();
    final Color color = switch (normalized) {
      'VALIDATED' => AppColors.primaryGreen,
      'REJECTED' => AppColors.errorRed,
      'MODIFIED' => AppColors.primaryBlue,
      _ => const Color(0xFFB7791F),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        normalized,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMedicationTile(RecommendationMedication medication, int index) {
    final isSelected = _selectedMedicationIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryGreen
              : Colors.grey.withOpacity(0.15),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.isPharmacienMode
            ? () => setState(() => _selectedMedicationIndex = index)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medication.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.isPharmacienMode)
                    Radio<int>(
                      value: index,
                      groupValue: _selectedMedicationIndex,
                      onChanged: (value) => setState(() => _selectedMedicationIndex = value),
                    ),
                ],
              ),
              if ((medication.dci ?? '').isNotEmpty)
                Text(
                  medication.dci!,
                  style: const TextStyle(color: AppColors.grey),
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if ((medication.dosage ?? '').isNotEmpty) _buildFactChip('Dosage', medication.dosage!),
                  if ((medication.frequency ?? '').isNotEmpty) _buildFactChip('Posologie', medication.frequency!),
                  if (medication.priceTnd != null) _buildFactChip('Prix', '${medication.priceTnd!.toStringAsFixed(2)} TND'),
                  if (medication.finalScore != null) _buildFactChip('Score', '${(medication.finalScore! * 100).toStringAsFixed(0)}%'),
                ],
              ),
              if ((medication.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(medication.description!),
              ],
              if (medication.contraindications.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Contre-indications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...medication.contraindications.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $item'),
                  ),
                ),
              ],
              if (medication.sideEffects.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Effets secondaires',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...medication.sideEffects.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $item'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPharmacienActions(RecommendationModel recommendation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Décision pharmacien',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sélectionnez le médicament final à retenir. Cette sélection sera transmise à la planification du traitement.',
            style: TextStyle(color: AppColors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Note clinique, posologie ou justification de validation',
              filled: true,
              fillColor: const Color(0xFFF8FBFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _process('REJECT'),
                  child: const Text('Rejeter'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _process('MODIFY'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: const Text('Modifier'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _process('VALIDATE', navigateToTreatment: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
              label: const Text(
                'Valider et planifier le traitement',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_selectedMedicationIndex == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Sélectionnez un médicament final pour la validation métier.',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientStateCard(RecommendationModel recommendation) {
    final isValidated = recommendation.status.toUpperCase() == 'VALIDATED' ||
        recommendation.status.toUpperCase() == 'MODIFIED';

    return _buildMessageCard(
      isValidated
          ? 'Votre pharmacien a validé cette recommandation. Les médicaments ci-dessus représentent la version finale retenue.'
          : 'Cette recommandation est une pré-analyse IA. Elle est stockée et doit être validée par votre pharmacien avant toute dispensation.',
      backgroundColor: isValidated
          ? const Color(0xFFEFFAF7)
          : const Color(0xFFFFF7E8),
      foregroundColor: isValidated
          ? AppColors.primaryGreen
          : const Color(0xFFB7791F),
      icon: isValidated ? Icons.verified_outlined : Icons.pending_actions_outlined,
    );
  }

  Widget _buildHistoryItem(RecommendationModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.primaryDisease,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.symptoms,
            style: const TextStyle(color: AppColors.grey),
          ),
          if (item.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              item.createdAt!.toLocal().toString(),
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard(
    String message, {
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnalyze() async {
    final symptoms = _symptomsController.text.trim();
    final patient = _targetPatient ?? context.read<AuthViewModel>().currentUser;

    if (symptoms.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Décris un peu mieux les symptômes.')),
      );
      return;
    }

    if (widget.isPharmacienMode && (widget.patientId == null || patient == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scannez ou sélectionnez un patient avant l’analyse.')),
      );
      return;
    }

    await context.read<RecommendationViewModel>().analyze(
          symptoms: symptoms,
          patientId: widget.patientId ?? patient?.id,
          patientProfile: _buildRecommendationProfile(patient),
        );

    if (mounted) {
      setState(() => _selectedMedicationIndex = null);
    }
  }

  Future<void> _process(String action, {bool navigateToTreatment = false}) async {
    final recommendation = context.read<RecommendationViewModel>().currentRecommendation;
    if (recommendation == null) {
      return;
    }

    final selectedMedication = _selectedMedicationIndex != null
        ? recommendation.recommendedMedications[_selectedMedicationIndex!]
        : null;

    if (action != 'REJECT' && selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un médicament final.')),
      );
      return;
    }

    final success = await context.read<RecommendationViewModel>().processRecommendation(
          action: action,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          modifiedMedications: selectedMedication == null
              ? null
              : [
                  {
                    'name': selectedMedication.name,
                    'dci': selectedMedication.dci,
                    'dosage': selectedMedication.dosage,
                    'frequency': selectedMedication.frequency,
                    'price_tnd': selectedMedication.priceTnd,
                    'contraindications': selectedMedication.contraindications,
                    'side_effects': selectedMedication.sideEffects,
                    'final_score': selectedMedication.finalScore,
                  },
                ],
        );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action impossible pour le moment')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          navigateToTreatment
              ? 'Validation enregistrée, ouverture de la planification'
              : 'Recommandation enregistrée',
        ),
      ),
    );

    if (navigateToTreatment && selectedMedication != null && _targetPatient != null) {
      AppRoutes.navigateToAddMedicine(
        context,
        patientId: _targetPatient!.id,
        patientName: _targetPatient!.fullName,
        patientAge: _calculateAge(_targetPatient!.dateNaissance),
        patientSex: _targetPatient!.enceinte == true ? 'Female' : 'N/A',
        allergies: _targetPatient!.allergies.join(', '),
        isPregnant: _targetPatient!.enceinte ?? false,
        initialMedicationName: selectedMedication.name,
        initialDosage: selectedMedication.dosage ?? selectedMedication.frequency,
        initialType: selectedMedication.dci,
        recommendationNote: _noteController.text.trim().isEmpty
            ? selectedMedication.contraindications.join(' ; ')
            : _noteController.text.trim(),
      );
    }
  }

  Map<String, dynamic>? _buildRecommendationProfile(UserModel? patient) {
    if (patient == null) {
      return null;
    }
    return {
      'allergies': patient.allergies,
      'conditions': patient.maladiesChroniques,
      'maladiesChroniques': patient.maladiesChroniques,
      'pregnant': patient.enceinte ?? false,
      'age': _calculateAge(patient.dateNaissance),
      'groupeSanguin': patient.groupeSanguin,
    };
  }

  int _calculateAge(DateTime? dateNaissance) {
    if (dateNaissance == null) {
      return 0;
    }

    final now = DateTime.now();
    var age = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      age--;
    }
    return age;
  }
}
