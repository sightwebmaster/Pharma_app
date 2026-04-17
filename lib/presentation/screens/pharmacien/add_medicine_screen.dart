import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';
import 'package:pharma_app/presentation/widgets/common/app_buttons.dart';
import 'package:pharma_app/presentation/widgets/common/app_card.dart';
import 'package:pharma_app/presentation/widgets/common/app_text_field.dart';
import 'package:pharma_app/presentation/widgets/common/icon_circle.dart';
import 'package:pharma_app/presentation/widgets/medical/profile_pill.dart';
import 'package:pharma_app/presentation/widgets/medical/segmented_meal_selector.dart';
import 'package:pharma_app/presentation/widgets/dialogs/time_alarm_picker_dialog.dart';
import 'package:pharma_app/services/treatment_provider.dart';
import 'package:pharma_app/services/storage_service.dart';

/// AddMedicineScreen - Écran de création d'un traitement (Pharmacien)
class AddMedicineScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final String allergies;
  final bool isPregnant;

  const AddMedicineScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.allergies,
    required this.isPregnant,
  }) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  // Controllers
  late TextEditingController _medicineNameController;
  late TextEditingController _typeController;
  late TextEditingController _timesPerDayController;
  late TextEditingController _doseController;
  late TextEditingController _amountController;
  late TextEditingController _reminderStartController;

  // État
  String _selectedMealType = 'Before Meals';
  bool _alarmEnabled = false;
  String _selectedAlarmTime = '09:30 AM';
  int _timesPerDay = 1;

  final List<String> _medicineTypes = [
    'Capsule',
    'Comprimé',
    'Sirop',
    'Injection',
    'Poudre',
  ];

  @override
  void initState() {
    super.initState();
    _medicineNameController = TextEditingController();
    _typeController = TextEditingController();
    _timesPerDayController = TextEditingController(text: '1');
    _doseController = TextEditingController();
    _amountController = TextEditingController();
    _reminderStartController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _typeController.dispose();
    _timesPerDayController.dispose();
    _doseController.dispose();
    _amountController.dispose();
    _reminderStartController.dispose();
    super.dispose();
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
              child: Text(
                'Select Medicine Type',
                style: AppTextStyles.cardTitle,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _medicineTypes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _medicineTypes[index],
                      style: AppTextStyles.fieldValue,
                    ),
                    onTap: () {
                      setState(() {
                        _typeController.text = _medicineTypes[index];
                      });
                      Navigator.pop(context);
                    },
                    selected: _typeController.text == _medicineTypes[index],
                    selectedTileColor: AppColors.primaryPale,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _reminderStartController.text = DateFormat(
          'MMM d, yyyy',
        ).format(selectedDate);
      });
    }
  }

  void _showTimeAlarmPicker() async {
    final selectedTime = await showTimePickerDialog(
      context,
      initialTime: _selectedAlarmTime,
    );

    if (selectedTime != null) {
      setState(() {
        _selectedAlarmTime = selectedTime;
      });
    }
  }

  void _incrementTimes() {
    setState(() {
      _timesPerDay++;
      _timesPerDayController.text = _timesPerDay.toString();
    });
  }

  void _decrementTimes() {
    if (_timesPerDay > 1) {
      setState(() {
        _timesPerDay--;
        _timesPerDayController.text = _timesPerDay.toString();
      });
    }
  }

  void _addMedicine() async {
    if (_medicineNameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _doseController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final storage = StorageService();
    final token = await storage.getAccessToken();
    final pharmacienId = await storage.getUserId();

    if (token == null || pharmacienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expiré — reconnectez-vous'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<String> heuresPrise = _calculateHeuresPrise(_timesPerDay);
    final DateTime dateDebut = DateTime.now();
    final int dureeJours = int.tryParse(_amountController.text) ?? 7;
    final DateTime dateFin = dateDebut.add(Duration(days: dureeJours));

        final Map<String, dynamic> body = {
      'patientUserId':    widget.patientId,
      'acteurId':         pharmacienId,     // Remplacé "pharmacienUserId"
      'acteurRole':       'PHARMACIEN',     // Ligne ajoutée !
      'dateDebut':        dateDebut.toIso8601String().split('T')[0],
      'dateFin':          dateFin.toIso8601String().split('T')[0],
      'motif':            'Prescription médicale',
      'lignes': [

        {
          'medicamentNom': _medicineNameController.text,
          'principeActif': _medicineNameController.text,
          'dosage': _doseController.text,
          'type': _typeController.text,
          'dureeJours': dureeJours,
          'heuresPrise': heuresPrise,
          'instructions': _getMealTypeInstructions(_selectedMealType),
        },
      ],
    };

    final treatmentProvider = context.read<TreatmentProvider>();
    final result = await treatmentProvider.creerTraitement(body, token);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traitement créé avec succès ✅'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            treatmentProvider.error ?? 'Erreur création traitement',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  List<String> _calculateHeuresPrise(int timesPerDay) {
    switch (timesPerDay) {
      case 1:
        return ['08:00'];
      case 2:
        return ['08:00', '20:00'];
      case 3:
        return ['08:00', '14:00', '20:00'];
      case 4:
        return ['08:00', '12:00', '16:00', '20:00'];
      case 5:
        return ['07:00', '10:00', '13:00', '17:00', '21:00'];
      default:
        final interval = 24 ~/ timesPerDay;
        return List.generate(timesPerDay, (i) {
          final hour = (8 + i * interval) % 24;
          return '\:00';
        });
    }
  }

  String _getMealTypeInstructions(String mealType) {
    switch (mealType) {
      case 'Before Meals':
        return 'Prendre avant les repas';
      case 'After Meals':
        return 'Prendre après les repas';
      case 'With Meals':
        return 'Prendre pendant les repas';
      default:
        return 'Prendre avant les repas';
    }
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
        title: Text('Add New Medicine', style: AppTextStyles.pageTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            color: AppColors.primary,
            iconSize: 28,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION: Patient Medical Profile
              Text(
                'PATIENT PROFILE'.toUpperCase(),
                style: AppTextStyles.sectionLabel,
              ),
              const SizedBox(height: 12),
              Text('Patient Medical Profile', style: AppTextStyles.cardTitle),
              const SizedBox(height: 12),

              // Profil Pills
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
                      label: '${widget.patientAge} YRS',
                      value: 'Age',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfilePill(
                      icon: widget.patientSex == 'Male'
                          ? Icons.male
                          : Icons.female,
                      label: widget.patientSex.toUpperCase(),
                      value: 'Sex',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Allergies & Pregnancy
              Row(
                children: [
                  Expanded(child: AllergyBadge(allergies: widget.allergies)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pregnant_woman,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PREGNANCY: ${widget.isPregnant ? 'YES' : 'NO'}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // SECTION: Medicine Details
              Text(
                'MEDICINE DETAILS'.toUpperCase(),
                style: AppTextStyles.sectionLabel,
              ),
              const SizedBox(height: 12),

              // Medicine Name
              AppTextField(
                label: 'Medicine Name',
                hintText: 'e.g., Amoxicillin',
                controller: _medicineNameController,
                trailingIcon: Icons.local_pharmacy_outlined,
              ),

              // Type Dropdown
              AppTextField(
                label: 'Type',
                hintText: 'Select type',
                controller: _typeController,
                trailingIcon: Icons.arrow_drop_down,
                readOnly: true,
                onTraillingIconTap: _showMedicineTypeBottomSheet,
                onTap: _showMedicineTypeBottomSheet,
              ),

              // Times per day with Stepper
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Times per day', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _decrementTimes,
                              child: const Icon(
                                Icons.remove,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _timesPerDay.toString(),
                                  style: AppTextStyles.fieldValue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _incrementTimes,
                              child: const Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time,
                              color: AppColors.textLabel,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Meal Selector
              SegmentedMealSelector(
                initialValue: _selectedMealType,
                onChanged: (value) {
                  setState(() {
                    _selectedMealType = value;
                  });
                },
              ),

              // Dose Field
              AppTextField(
                label: 'Dose',
                hintText: '500mg',
                controller: _doseController,
                trailingIcon: Icons.straighten,
              ),

              // Amount Field
              AppTextField(
                label: 'Amount',
                hintText: '1 Capsule',
                controller: _amountController,
                trailingIcon: Icons.medical_services_outlined,
              ),

              // Reminder Start
              AppTextField(
                label: 'Reminder Start',
                hintText: 'Select date',
                controller: _reminderStartController,
                trailingIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _showDatePicker,
              ),

              // Set Alarm
              AppCard(
                child: Row(
                  children: [
                    IconCircle(icon: Icons.alarm, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Set Alarm', style: AppTextStyles.fieldValue),
                          if (_alarmEnabled)
                            Text(
                              _selectedAlarmTime,
                              style: AppTextStyles.fieldLabel,
                            ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _alarmEnabled,
                        onChanged: (value) {
                          setState(() {
                            _alarmEnabled = value;
                          });
                        },
                        activeColor: AppColors.primary,
                        inactiveThumbColor: AppColors.switchOff,
                      ),
                    ),
                  ],
                ),
              ),

              if (_alarmEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: GestureDetector(
                    onTap: _showTimeAlarmPicker,
                    child: AppCard(
                      onTap: _showTimeAlarmPicker,
                      child: Center(
                        child: Text(
                          _selectedAlarmTime,
                          style: AppTextStyles.questionText.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 24),

              // Add Medicine Button
              Consumer<TreatmentProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    label: 'Add Medicine',
                    isLoading: provider.isLoading,
                    onPressed: _addMedicine,
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
/*
@Override
public TraitementResponse planifier(PlanifierTraitementCommand cmd) {
    log.info("Planification traitement — patient={} pharmacien={}",
            cmd.patientUserId(), cmd.acteurId());

    // ── Étape 1 : construire les LigneMedicament du domaine ──────
    // On appelle MedicationClient pour les contre-indications (Fail-Open)
    List<LigneMedicament> lignes = construireLignesDomaine(cmd.lignes());

    // ── Étape 2 : récupérer principes actifs existants (R4 externe) ──
    Set<String> principesActifsActifs =
            traitementRepository.findPrincipesActifsActifs(cmd.patientUserId());

    // ── Étape 3 : créer l'Aggregate Root — toutes les règles R1→R4 ici ──
    // Lève AccesDeniedDomainException (R1), ConflitTraitementException (R4)
    Traitement traitement = Traitement.creer(
            cmd.acteurId(),
            cmd.acteurRole(),
            cmd.patientUserId(),
            cmd.dateDebut(),
            cmd.dateFin(),
            cmd.motif(),
            lignes,
            principesActifsActifs
    );
    log.info(" traitement — ligne_traitement_medNom={} ligne_id={}",
            traitement.getLignes().get(0).getId(), traitement.getId());

    // ── Étape 4 : persister ──────────────────────────────────────
    Traitement saved = traitementRepository.save(traitement);

    // ── Étape 5 : dépiler et traiter les Domain Events ───────────
    traiterEvents(saved.pullDomainEvents());

    // ── Étape 6 : mapper vers DTO et retourner ───────────────────
    return mapper.toResponse(saved);
}
@Override
    public Traitement save(Traitement traitement) {

        // ── 1. Mapper Traitement → TraitementEntity ──────────────────
        TraitementEntity entity = mapper.toEntity(traitement);

        // ── 2. Construire les LigneMedicamentEntity ──────────────────
        // ✅ On construit une Map medicamentNom → LigneMedicamentEntity
        // medicamentNom est la seule clé fiable :
        //   - LigneMedicament est un Value Object SANS id
        //   - le ligneId dans genererToutesLesPrises() est un UUID local
        //     non stocké dans LigneMedicament
        //   - prise.getMedicamentNom() = même valeur que ligne.getMedicamentNom()
        Map<String, LigneMedicamentEntity> ligneParNom = new LinkedHashMap<>();
        List<LigneMedicamentEntity> lignesEntities = new ArrayList<>();

        for (LigneMedicament ligne : traitement.getLignes()) {
            log.info(" traitement — ligne_traitement_medNom1={} ligne_id1={}",
                    ligne.getMedicamentNom(), ligne.getId());
            LigneMedicamentEntity ligneEntity = mapper.ligneToEntity(ligne);
            ligneEntity.setTraitement(entity);



            lignesEntities.add(ligneEntity);

            // ✅ Clé = medicamentNom (toujours non-null grâce au requireNonNull domaine)
            ligneParNom.put(ligne.getMedicamentNom(), ligneEntity);
        }
        entity.setLignes(lignesEntities);

        // ── 3. Construire les PrisePlanifieeEntity ───────────────────
        List<PrisePlanifieeEntity> prisesEntities = new ArrayList<>();

        for (PrisePlanifiee prise : traitement.getPrises()) {
            log.info(" prise — prise_traitement={} prise_id={}, traitement_id= {}",
                    prise.getMedicamentNom(), prise.getId(), prise.getTraitementId());
            PrisePlanifieeEntity priseEntity = priseMapper.priseToEntity(prise);
            log.info(" prise — prise_entity_traitement={} prise_id={}",
                    priseEntity.getLigneMedicament().getId(), priseEntity.getId());

            // ✅ Liaison par medicamentNom — seule clé disponible côté domaine
            // prise.getMedicamentNom() = ligne.getMedicamentNom() (copié dans genererToutesLesPrises)


            prisesEntities.add(priseEntity);
        }

        // ── 4. Persister dans l'ordre : traitement+lignes d'abord ────
        // Les lignes sont en cascade ALL depuis TraitementEntity,
        // donc traitementRepo.save() persiste aussi les lignes
        TraitementEntity saved = traitementRepo.save(entity);

        // ── 5. Persister les prises séparément ──────────────────────
        // Les prises ne sont pas en cascade depuis TraitementEntity
        priseRepo.saveAll(prisesEntities);

        // ── 6. Retourner le domaine reconstitué ──────────────────────
        return mapper.toDomain(saved);
    }
package com.pharmaApp.treatement.infrastructure.mapper;

import com.pharmaApp.treatement.domain.model.PrisePlanifiee;
import com.pharmaApp.treatement.infrastructure.adapter.out.persistence.entity.PrisePlanifieeEntity;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component  // ← Ajoutez ça
public class PrisePlanifieeMapperManual {

    public PrisePlanifieeEntity priseToEntity(PrisePlanifiee prise) {
        if (prise == null) return null;

        PrisePlanifieeEntity entity = new PrisePlanifieeEntity();
        entity.setId(prise.getId());
        log.info("traitement_id={}, prise_id={}", prise.getTraitementId(), prise.getId());
        entity.getTraitement().setId(prise.getTraitementId());      // ✅ String → String
        entity.getLigneMedicament().setMedicamentId(prise.getLigneMedicamentId()); // ✅ String → String
        entity.setPatientUserId(prise.getPatientUserId());
        entity.setHeurePrevue(prise.getHeurePrevue());
        entity.setHeureReelle(prise.getHeureReelle());

        // Mapping enum
        if (prise.getStatut() != null) {
            entity.setStatut(PrisePlanifieeEntity.PriseStatutJpa.valueOf(prise.getStatut().name()));
        }

        return entity;
    }


}
package com.pharmaApp.treatement.infrastructure.adapter.out.persistence.repository;


import com.pharmaApp.treatement.infrastructure.adapter.out.persistence.entity.TraitementEntity;
import com.pharmaApp.treatement.infrastructure.adapter.out.persistence.entity.TraitementEntity.TraitementStatutJpa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;


/**
 * Repository Spring Data JPA — table traitement
 * Implémente le port sortant TraitementRepositoryPort (via TraitementJpaAdapter)
 */
public interface TraitementJpaRepository
        extends JpaRepository<TraitementEntity, String> {

    /** Traitement actif d'un patient — appelé par recommendation-service */
    Optional<TraitementEntity> findFirstByPatientUserIdAndStatut(
            String patientUserId,
            TraitementStatutJpa statut);

    /** Tous les traitements actifs d'un patient */
    List<TraitementEntity> findByPatientUserIdAndStatut(
            String patientUserId,
            TraitementStatutJpa statut);

    /**
     * Requête de détection de chevauchement (Règle R4).
     * Logique : deux périodes se chevauchent si
     *   dateDebut_existant <= dateFin_nouveau
     *   ET dateFin_existant >= dateDebut_nouveau
     */
    @Query("""
        SELECT t FROM TraitementEntity t
        WHERE t.patientUserId = :patientId
          AND t.statut = 'ACTIF'
          AND t.dateDebut <= :nouvelleFin
          AND t.dateFin   >= :nouveauDebut
    """)
    List<TraitementEntity> findChevauchements(
            @Param("patientId")    String patientId,
            @Param("nouveauDebut") LocalDate nouveauDebut,
            @Param("nouvelleFin")  LocalDate nouvelleFin);
}
package com.pharmaApp.treatement.infrastructure.adapter.out.persistence.repository;

import com.pharmaApp.treatement.infrastructure.adapter.out.persistence.entity.PrisePlanifieeEntity;
import com.pharmaApp.treatement.infrastructure.adapter.out.persistence.entity.PrisePlanifieeEntity.PriseStatutJpa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;




public interface PrisePlanifieeJpaRepository
        extends JpaRepository<PrisePlanifieeEntity, String> {

    /**
     * Requête du Scheduler (exécutée toutes les 5 minutes).
     * Retourne toutes les prises PLANIFIÉES dont l'heure prévue
     * est dépassée depuis plus de 30 minutes.
     * L'index idx_prise_statut_heure rend cette requête très rapide.
     */
    @Query("""
        SELECT p FROM PrisePlanifieeEntity p
        WHERE p.statut = 'PLANIFIEE'
          AND p.heurePrevue <= :deadline
    """)
    List<PrisePlanifieeEntity> findPrisesNonConfirmees(
            @Param("deadline") LocalDateTime deadline);

    /** Historique des prises d'un patient (pour l'écran de suivi) */
    List<PrisePlanifieeEntity> findByPatientUserIdOrderByHeurePrevueDesc(
            String patientUserId);

    /** Prises d'un patient filtrées par statut */
    List<PrisePlanifieeEntity> findByPatientUserIdAndStatut(
            String patientUserId,
            PriseStatutJpa statut);
}
   @Mapping(target = "statut",
            expression = "java(com.pharmaApp.treatement.domain.model.TraitementStatut.valueOf(entity.getStatut().name()))")
    @Mapping(target = "lignes",  ignore = true)   // gérées dans @ObjectFactory
    @Mapping(target = "prises",  ignore = true)
    @Mapping(target = "version", source = "version")
    @Mapping(target = "principesActifs", ignore = true)
    @Mapping(target = "domainEvents", ignore = true)
    Traitement toDomain(TraitementEntity entity);

*/
