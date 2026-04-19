<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_app/core/constants/app_colors.dart';
import 'package:pharma_app/core/routes/app_routes.dart';
import 'package:pharma_app/data/models/proche_model.dart';
import 'package:pharma_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/proche_viewmodel.dart';
import 'package:pharma_app/presentation/widgets/add_proche_dialog_widget.dart';
import 'package:pharma_app/presentation/widgets/week_calendar_widget.dart';
import 'package:pharma_app/services/treatment_provider.dart';
import 'package:pharma_app/services/storage_service.dart';
import 'profile_setting_screen.dart';

=======
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pharma_app/core/constants/app_colors.dart';
import 'package:pharma_app/core/constants/app_text_styles.dart';
import 'package:pharma_app/core/routes/app_routes.dart';
import 'package:pharma_app/data/models/proche_model.dart';
import 'package:pharma_app/presentation/screens/patient/profile_setting_screen.dart';
import 'package:pharma_app/presentation/screens/recommendation/recommendation_screen.dart';
import 'package:pharma_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/proche_viewmodel.dart';
import 'package:pharma_app/presentation/widgets/add_proche_dialog_widget.dart';
import 'package:pharma_app/presentation/widgets/common/user_avatar.dart';
import 'package:pharma_app/presentation/widgets/pharma_bottom_nav.dart';
import 'package:pharma_app/presentation/widgets/week_calendar_widget.dart';
import 'package:pharma_app/services/local_notification_service.dart';
import 'package:pharma_app/services/notification_preferences_service.dart';
import 'package:pharma_app/services/treatment_provider.dart';

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
<<<<<<< HEAD

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.person_outline, 'label': 'Profil'},
    {'icon': Icons.medication_outlined, 'label': 'Médicaments'},
    {'icon': Icons.assignment_outlined, 'label': 'Planning'},
    {'icon': Icons.medical_services_outlined, 'label': 'Recommandation'},
    {'icon': Icons.family_restroom, 'label': 'Proche', 'badge': 'Nouveau'},
  ];
=======
  Timer? _refreshTimer;
  String? _lastReminderPriseId;
  DateTime? _lastReminderShownAt;
  final NotificationPreferencesService _notificationPreferencesService =
      NotificationPreferencesService();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
<<<<<<< HEAD
      // ✅ Charge les proches depuis le backend
      context.read<ProcheViewModel>().loadProches();

      // ✅ Charge les prises du jour depuis treatment-service
      final authVm = context.read<AuthViewModel>();
      final patientId = authVm.currentUser?.id;
      if (patientId != null) {
        context.read<TreatmentProvider>().loadTodayPrises(patientId);
      }
=======
      context.read<ProcheViewModel>().loadProches();
      unawaited(_refreshAll());
      _startAutoRefresh();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    });
  }

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildPlanningTab(),
            _buildHistoriqueTab(),
            _buildNotificationsTab(),
            const ProfileSettingScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_filled, 'label': 'Accueil'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Planning'},
      {'icon': Icons.assignment_outlined, 'label': 'Historique'},
      {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: items.map((e) => BottomNavigationBarItem(
          icon: Icon(e['icon'] as IconData),
          label: e['label'] as String,
        )).toList(),
      ),
    );
  }

  // ─── HOME TAB ──────────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildServices(),
          const SizedBox(height: 24),
          _buildFamilySection(),
          const SizedBox(height: 24),
          _buildAdaptiveCalendar(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Médicaments du jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ Utilise TreatmentProvider — données réelles
                ...context.watch<TreatmentProvider>().todayPrises
                    .map((prise) => _buildMedicineReminderItem(prise)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, Color(0xFF00C9B4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Text('👋 ', style: TextStyle(fontSize: 16)),
                    Text('Bonjour!', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    context.watch<AuthViewModel>().currentUser?.fullName ?? 'Chargement...',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 25,
                child: Icon(Icons.person, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNextMedCard(),
        ],
      ),
    );
  }

  Widget _buildNextMedCard() {
    final treatmentProvider = context.watch<TreatmentProvider>();

    final nextPrise = treatmentProvider.todayPrises
        .where((p) => p.statut != 'CONFIRMEE' && p.statut != 'confirmee')
        .cast<dynamic>()
        .firstOrNull;

    if (nextPrise == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            '✅ Tous les médicaments du jour sont pris !',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.alarm, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text('Prochain médicament', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          Text(
            nextPrise.medicamentNom ?? 'Médicament',
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextPrise.heurePrevue ?? 'N/A'} · ${nextPrise.dosage ?? 'N/A'}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              final storage = StorageService();
              final token = await storage.getAccessToken();
              if (token != null && nextPrise.id != null) {
                // ✅ confirmerPrise via TreatmentProvider → POST /api/treatments/prises/{id}/confirmer
                await treatmentProvider.confirmerPrise(nextPrise.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prise confirmée !'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Confirmer la prise',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _services.map((s) => _buildServiceItem(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final isReco   = service['label'] == 'Recommandation';
    final isProche = service['label'] == 'Proche';

    return GestureDetector(
      onTap: () {
        if (isReco) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommandationScreen()));
        } else if (isProche) {
          _showFamilyMembersDialog();
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  color: isProche
                      ? const Color(0xFFFF6B6B)
                      : isReco ? AppColors.primaryBlue : AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(service['icon'] as IconData, color: Colors.white, size: 28),
              ),
              if (service.containsKey('badge'))
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(service['badge'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(service['label'] as String,
              style: const TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── FAMILLE ──────────────────────────────────────────────────────────────

  Widget _buildFamilySection() {
    // ✅ List<ProcheModel>
    final proches   = context.watch<ProcheViewModel>().proches;
    final isLoading = context.watch<ProcheViewModel>().isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('👨‍👩‍👧‍👦 Mes proches',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black)),
              TextButton(
                onPressed: _showFamilyMembersDialog,
                child: const Text('Voir tout',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : proches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Aucun proche ajouté',
                            style: TextStyle(fontSize: 13, color: AppColors.grey)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddProcheDialog,
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Ajouter un proche'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: proches.length,
                    itemBuilder: (_, index) => _buildFamilyMemberCard(proches[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ Accepte ProcheModel
  Widget _buildFamilyMemberCard(ProcheModel proche) {
    final Color statusColor = _getStatusColor(proche.status);
    final String avatar     = _getAvatar(proche.relation);

    return GestureDetector(
      onTap: () => AppRoutes.navigateToProcheDetail(context, proche),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(avatar, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${proche.prenom} ${proche.nom}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(proche.relation ?? '', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      proche.status ?? 'Actif',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Accepte ProcheModel
  Widget _buildFamilyMemberDetail(ProcheModel proche) {
    final Color statusColor = _getStatusColor(proche.status);
    final String avatar     = _getAvatar(proche.relation);

    return Dismissible(
      key: Key(proche.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Supprimer le proche',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Text('Êtes-vous sûr de vouloir supprimer ${proche.prenom} ${proche.nom} ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler', style: TextStyle(color: AppColors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) async {
        // ✅ proche.id au lieu de member['id']
        final success = await context.read<ProcheViewModel>().deleteProche(proche.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success
                ? '${proche.prenom} ${proche.nom} supprimé'
                : 'Erreur lors de la suppression'),
            backgroundColor: success ? AppColors.primaryGreen : AppColors.errorRed,
          ));
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.errorRed, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Supprimer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          AppRoutes.navigateToProcheDetail(context, proche);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(avatar, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ✅ proche.prenom + proche.nom
                        Text('${proche.prenom} ${proche.nom}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                        const SizedBox(width: 8),
                        // ✅ proche.relation
                        Text('· ${proche.relation ?? ''}',
                            style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          proche.status ?? 'Actif',
                          style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showFamilyMembersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            // ✅ ProcheModel depuis ProcheViewModel
            final proches   = ctx.watch<ProcheViewModel>().proches;
            final isLoading = ctx.watch<ProcheViewModel>().isLoading;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('👨‍👩‍👧‍👦 Mes proches',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const SizedBox(height: 8),
                  const Text('Suivez les prises de médicaments de vos proches',
                      style: TextStyle(fontSize: 13, color: AppColors.grey)),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ))
                  else if (proches.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucun proche ajouté',
                          style: TextStyle(fontSize: 14, color: AppColors.grey)),
                    ))
                  else
                    // ✅ itère sur List<ProcheModel>
                    ...proches.map((proche) => _buildFamilyMemberDetail(proche)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _showAddProcheDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text('Ajouter un proche',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProcheDialog() {
    showDialog(
      context: context,
      builder: (_) => AddProcheDialogWidget(
        onProcheAdded: () {
          if (mounted) context.read<ProcheViewModel>().refresh();
        },
      ),
    );
  }

  Widget _buildAdaptiveCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📅 Cette Semaine',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.fullCalendar),
                child: const Text('Vue mensuelle →',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeekCalendarWidget(
            onDaySelected: (date) => AppRoutes.navigateToMedicationDetails(context, date),
          ),
        ],
      ),
    );
  }

  // ─── PLANNING TAB ──────────────────────────────────────────────────────────

  Widget _buildPlanningTab() {
    final prises = context.watch<TreatmentProvider>().todayPrises;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Mon Planning',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Suivi de vos prises de médicaments',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 24),
          _buildAdaptiveCalendar(),
          const SizedBox(height: 24),
          const Text('Médicaments programmés',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 12),
          // ✅ Données réelles depuis TreatmentProvider
          if (prises.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Aucune prise planifiée aujourd\'hui',
                    style: TextStyle(fontSize: 14, color: AppColors.grey)),
              ),
            )
          else
            ...prises.map((prise) => _buildMedicineReminderItem(prise)),
        ],
      ),
    );
  }

  Widget _buildMedicineReminderItem(dynamic prise) {
    // ✅ statut correct : CONFIRMEE (majuscules — backend Spring Boot)
    final isConfirmed = prise.statut == 'CONFIRMEE';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConfirmed
              ? AppColors.primaryGreen.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.primaryGreen.withOpacity(0.12)
                  : AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: isConfirmed ? AppColors.primaryGreen : AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prise.medicamentNom ?? 'Médicament',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
                Text(prise.dosage ?? 'N/A',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(prise.heurePrevue ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? AppColors.primaryGreen.withOpacity(0.12)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isConfirmed ? '✓ Pris' : '⏳ En attente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isConfirmed ? AppColors.primaryGreen : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HISTORIQUE TAB ────────────────────────────────────────────────────────

  Widget _buildHistoriqueTab() {
    // TODO : connecter à adherence-service
    // GET /api/adherence/{patientId}/summary
    // GET /api/adherence/{patientId}/historique
    final history = [
      {'date': 'Aujourd\'hui', 'meds': 2, 'total': 3, 'pct': 0.67},
      {'date': 'Hier', 'meds': 3, 'total': 3, 'pct': 1.0},
      {'date': '10 Fév', 'meds': 2, 'total': 3, 'pct': 0.67},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Historique',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Suivi de votre observance',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('85%', 'Observance\nglobale', AppColors.primaryGreen),
                _buildStatItem('42', 'Prises\neffectuées', AppColors.primaryBlue),
                _buildStatItem('8', 'Prises\nmanquées', AppColors.errorRed),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Détail par jour',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 12),
          ...history.map((h) => _buildHistoryItem(h)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> h) {
    final pct = h['pct'] as double;
    final Color statusColor = pct == 1.0
        ? AppColors.primaryGreen
        : pct >= 0.5 ? const Color(0xFFFFA726) : AppColors.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(pct == 1.0 ? Icons.check_circle_outline : Icons.info_outline, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h['date'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
                Text('${h['meds']} sur ${h['total']} prises effectuées',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Text('${(pct * 100).toInt()}%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor)),
        ],
      ),
    );
  }

  // ─── NOTIFICATIONS TAB ─────────────────────────────────────────────────────

  Widget _buildNotificationsTab() {
    // TODO : connecter à notification-service
    // GET /api/v1/notifications/historique/{patientId}
    final notifs = [
      {'title': 'Rappel médicament', 'body': 'Il est l\'heure de prendre Metformine 500mg', 'time': 'Il y a 5 min', 'icon': Icons.alarm, 'color': AppColors.primaryGreen, 'read': false},
      {'title': 'Proche – Youssef', 'body': 'Aspégic 100mg n\'a pas été confirmée', 'time': 'Il y a 35 min', 'icon': Icons.warning_amber_outlined, 'color': AppColors.errorRed, 'read': false},
      {'title': 'Prise confirmée', 'body': 'Vitamin D 1000UI confirmée avec succès', 'time': 'Ce matin à 08:00', 'icon': Icons.check_circle_outline, 'color': AppColors.primaryBlue, 'read': true},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
              TextButton(
                onPressed: () {},
                child: const Text('Tout lire',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...notifs.map((n) => _buildNotifItem(n)),
        ],
      ),
    );
  }

  Widget _buildNotifItem(Map<String, dynamic> n) {
    final read = n['read'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: read ? Colors.white : (n['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: read ? null : Border.all(color: (n['color'] as Color).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: (n['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(n['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
                    if (!read)
                      Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: n['color'] as Color, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n['body'] as String, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                const SizedBox(height: 4),
                Text(n['time'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'observant': case 'bon':      return AppColors.primaryGreen;
      case 'à surveiller': case 'moyen': return const Color(0xFFFFA726);
      case 'critique': case 'mauvais':   return AppColors.errorRed;
      default:                           return AppColors.grey;
    }
  }

  String _getAvatar(String? relation) {
    switch (relation?.toLowerCase()) {
      case 'père': case 'pere':             return '👨';
      case 'mère': case 'mere':             return '👩';
      case 'fils': case 'fille':            return '🧒';
      case 'grand-père': case 'grand père': return '👴';
      case 'grand-mère': case 'grand mère': return '👵';
      case 'frère': case 'soeur':           return '🧑';
      case 'conjoint': case 'conjointe':    return '💑';
      default:                              return '👤';
    }
  }
}

void _avatarFallback(Object exception, StackTrace? stackTrace) {}

// ─── RECOMMANDATION ────────────────────────────────────────────────────────

class RecommandationScreen extends StatelessWidget {
  const RecommandationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandation'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services_outlined, size: 44, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text('Système de recommandation IA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
            const SizedBox(height: 8),
            const Text('BERT NLP — À développer (Phase 3)',
                style: TextStyle(fontSize: 14, color: AppColors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: 200, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
=======
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildPlanningTab(),
            _buildHistoriqueTab(),
            _buildNotificationsTab(),
            const ProfileSettingScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return PharmaBottomNav(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        PharmaNavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,             label: 'Accueil'),
        PharmaNavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Planning'),
        PharmaNavItem(icon: Icons.assignment_outlined,   activeIcon: Icons.assignment_rounded,        label: 'Historique'),
        PharmaNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded,   label: 'Alertes'),
        PharmaNavItem(icon: Icons.person_outline,        activeIcon: Icons.person_rounded,            label: 'Profil'),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _todayLabel() {
    const days = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    const months = ['janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildHeroRingCard(TreatmentProvider treatmentProvider) {
    final total     = treatmentProvider.todayPrises.length;
    final confirmed = treatmentProvider.todayPrises.where((p) => p.statut == 'CONFIRMEE').length;
    final ratio     = total == 0 ? 0.0 : confirmed / total;
    final next      = treatmentProvider.todayPrises
        .where((p) => p.statut == 'PLANIFIEE' && p.heurePrevueDateTime != null)
        .toList()
      ..sort((a, b) => a.heurePrevueDateTime!.compareTo(b.heurePrevueDateTime!));
    final nextTime  = next.isEmpty ? null : next.first.heurePrevueDateTime;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x3312B8A0), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blob
          Positioned(
            right: -20, bottom: -20,
            child: Container(
              width: 120, height: 120,
              decoration: const BoxDecoration(
                color: Color(0x10FFFFFF), shape: BoxShape.circle),
            ),
          ),
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 72, height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72, height: 72,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$confirmed/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prises du jour',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$confirmed prise${confirmed > 1 ? 's' : ''} sur $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    if (nextTime != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Prochaine à ${nextTime.hour.toString().padLeft(2,'0')}h${nextTime.minute.toString().padLeft(2,'0')}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      ),
    );
  }

  Widget _buildHomeTab() {
    final authVm = context.watch<AuthViewModel>();
    final treatmentProvider = context.watch<TreatmentProvider>();
    final prochesVm = context.watch<ProcheViewModel>();
    final user = authVm.currentUser;
<<<<<<< HEAD
=======
    final nextPrise = _findPriorityPrise(treatmentProvider.todayPrises);
>>>>>>> aa86dbabf5ff427bb1e238a1def1446a9a57bc24

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _refreshAll,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Top greeting (no gradient — design uses plain top + hero card) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayLabel(),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bonjour, ${user?.fullName.split(' ').first ?? 'Patient'}',
                      style: AppTextStyles.headline2,
                    ),
                  ],
                ),
                Stack(
                  children: [
                    UserAvatar(user: user, radius: 21, backgroundColor: AppColors.greenSoft),
                    if (treatmentProvider.todayPrises.any((p) => p.statut == 'PLANIFIEE'))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.warnFg,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Hero ring card (green gradient) ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeroRingCard(treatmentProvider),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(treatmentProvider, prochesVm.proches.length),
                const SizedBox(height: 24),
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                  children: [
                    _buildActionCard(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Recommandation IA',
                      subtitle: 'Décrire vos symptômes',
                      color: AppColors.primaryBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendationScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      icon: Icons.qr_code_2_outlined,
                      title: 'Mon QR Code',
                      subtitle: 'Partager votre profil',
                      color: AppColors.primaryGreen,
                      onTap: () => AppRoutes.navigateToShareProfileQR(context),
                    ),
                    _buildActionCard(
                      icon: Icons.family_restroom,
                      title: 'Mes proches',
                      subtitle: '${prochesVm.proches.length} lié(s)',
                      color: const Color(0xFFFF7A59),
                      onTap: _showFamilyMembersDialog,
                    ),
                    _buildActionCard(
                      icon: Icons.settings_outlined,
                      title: 'Mon profil',
                      subtitle: 'Photo, mot de passe, infos',
                      color: const Color(0xFF6C63FF),
                      onTap: () => setState(() => _selectedIndex = 4),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFamilySection(prochesVm),
                const SizedBox(height: 24),
                const Text(
                  'Planning de la semaine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                WeekCalendarWidget(
                  onDaySelected: (date) =>
                      AppRoutes.navigateToMedicationDetails(context, date),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Prises du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (treatmentProvider.todayPrises.isEmpty)
                  _buildEmptyState(
                    title: 'Aucune prise planifiée',
                    subtitle: 'Vos traitements du jour apparaitront ici.',
                    icon: Icons.medication_outlined,
                  )
                else
                  _buildTodayPrisesSections(
                    treatmentProvider.todayPrises,
                    emptyTitle: 'Aucune prise planifiee',
                    emptySubtitle: 'Vos traitements du jour apparaitront ici.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningTab() {
    final treatmentProvider = context.watch<TreatmentProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Planning de traitement',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Consultez vos prises prévues et confirmez-les à temps.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
        WeekCalendarWidget(
          onDaySelected: (date) =>
              AppRoutes.navigateToMedicationDetails(context, date),
        ),
        const SizedBox(height: 24),
        if (treatmentProvider.todayPrises.isEmpty)
          _buildEmptyState(
            title: 'Aucun traitement actif',
            subtitle: 'Les traitements planifiés par votre pharmacien seront listés ici.',
            icon: Icons.calendar_month_outlined,
          )
        else
          _buildTodayPrisesSections(
            treatmentProvider.todayPrises,
            emptyTitle: 'Aucun traitement actif',
            emptySubtitle:
                'Les traitements planifies par votre pharmacien seront listes ici.',
          ),
      ],
    );
  }

  Widget _buildHistoriqueTab() {
    final treatmentProvider = context.watch<TreatmentProvider>();
    final adherence = treatmentProvider.adherenceSummary;
    final prises = _sortedPrises(treatmentProvider.allPrises);
    final confirmedCount = prises.where(_isConfirmedPrise).length;
    final totalCount = prises.length;
    final missedCount = prises.where(_isMissedPrise).length;
    final todayPct = totalCount == 0 ? 0 : ((confirmedCount / totalCount) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Historique d\'observance',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Suivez votre taux de prise et les rappels importants.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                value: '${adherence?.pourcentageGlobal ?? todayPct}%',
                label: 'Observance',
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                value: '${adherence?.prisesConfirmees ?? confirmedCount}',
                label: 'Prises ok',
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                value: '${adherence?.prisesManquees ?? missedCount}',
                label: 'Manquées',
                color: AppColors.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Détail du jour',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (prises.isEmpty)
          _buildEmptyState(
            title: 'Pas encore de données',
            subtitle: 'Confirmez vos prises pour alimenter votre historique.',
            icon: Icons.history_toggle_off,
          )
        else
          ...prises.take(20).map(
            (prise) => _buildHistoryRow(
              title: prise.medicamentNom ?? 'Médicament',
              subtitle: '${prise.heurePrevue ?? 'N/A'} · ${prise.dosage ?? 'N/A'}',
              isSuccess: _isConfirmedPrise(prise),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    final prises = context.watch<TreatmentProvider>().todayPrises;
    final proches = context.watch<ProcheViewModel>().proches;
    final pendingPrises = prises.where((prise) => prise.statut != 'CONFIRMEE').toList();
    final confirmedPrises = prises.where((prise) => prise.statut == 'CONFIRMEE').toList();
    final overduePrises = pendingPrises.where(_isOverdueByThirtyMinutes).toList();

    final notifications = <Map<String, dynamic>>[
      ...overduePrises.map(
        (prise) => {
          'title': 'Alerte prise en retard',
          'subtitle': '${prise.medicamentNom ?? 'Medicament'} depasse 30 minutes sans confirmation',
          'icon': Icons.warning_amber_rounded,
          'color': AppColors.errorRed,
        },
      ),
      ...pendingPrises.map(
        (prise) => {
          'title': 'Prise en attente',
          'subtitle': '${prise.medicamentNom ?? 'Médicament'} à ${prise.heurePrevue ?? 'N/A'}',
          'icon': Icons.alarm,
          'color': AppColors.errorRed,
        },
      ),
      ...confirmedPrises.take(2).map(
        (prise) => {
          'title': 'Prise confirmée',
          'subtitle': '${prise.medicamentNom ?? 'Médicament'} bien enregistrée',
          'icon': Icons.check_circle_outline,
          'color': AppColors.primaryBlue,
        },
      ),
      if (proches.isNotEmpty)
        {
          'title': 'Suivi des proches',
          'subtitle': '${proches.length} proche(s) liés à votre compte',
          'icon': Icons.family_restroom,
          'color': AppColors.primaryGreen,
        },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Alertes et rappels',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vos rappels de prise et vos événements importants.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
        if (notifications.isEmpty)
          _buildEmptyState(
            title: 'Aucune alerte',
            subtitle: 'Les rappels s’afficheront ici automatiquement.',
            icon: Icons.notifications_none_outlined,
          )
        else
          ...notifications.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'] as String,
                          style: const TextStyle(fontSize: 13, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNextDoseCard(dynamic nextPrise) {
    if (nextPrise == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Tous les médicaments du jour sont confirmés.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isOverdue(nextPrise)
                ? 'Prise en retard'
                : _isDueSoon(nextPrise)
                    ? 'A prendre maintenant'
                    : 'Prochaine prise',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight:
                  _isOverdue(nextPrise) ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextPrise.medicamentNom ?? 'Médicament',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextPrise.heurePrevue ?? 'N/A'} · ${nextPrise.dosage ?? 'N/A'}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _buildDoseStatusMessage(nextPrise),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              if (nextPrise.id == null) {
                return;
              }
              if (nextPrise.statut == 'CONFIRMEE' || nextPrise.statut == 'MANQUEE') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_buildDoseStatusMessage(nextPrise)),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }
              final success = await context.read<TreatmentProvider>().confirmerPrise(nextPrise);
              final provider = context.read<TreatmentProvider>();
              if (!mounted) {
                return;
              }
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.error ?? 'Impossible de confirmer la prise.',
                    ),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }
              unawaited(
                LocalNotificationService().cancelDoseReminder(
                  nextPrise.id.hashCode,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Prise confirmée.' : 'Impossible de confirmer la prise.',
                  ),
                  backgroundColor:
                      success ? AppColors.primaryGreen : AppColors.errorRed,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  String _buildDoseStatusMessage(dynamic prise) {
    if (prise.statut == 'CONFIRMEE') {
      return 'Cette prise a deja ete confirmee.';
    }
    if (prise.statut == 'MANQUEE') {
      return 'Cette prise est deja marquee comme manquee et ne peut plus etre confirmee.';
    }
    if (_isOverdue(prise)) {
      return 'Cette prise est en retard. Confirmez-la des que possible.';
    }
    return 'Confirmez la prise apres avoir pris le medicament.';
  }

  Widget _buildTodayPrisesSections(
    List<dynamic> prises, {
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    final sorted = _sortedPrises(prises);
    final upcoming = sorted
        .where((prise) => !_isConfirmedPrise(prise) && !_isMissedPrise(prise))
        .toList();
    final missed = sorted.where(_isMissedPrise).toList();
    final confirmed = sorted.where(_isConfirmedPrise).toList();

    if (sorted.isEmpty) {
      return _buildEmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: Icons.medication_outlined,
      );
    }

    return Column(
      children: [
        if (upcoming.isNotEmpty) ...[
          _buildPriseSection(
            _hasOverduePrise(upcoming) ? 'A prendre / en retard' : 'A prendre',
            upcoming,
          ),
          const SizedBox(height: 12),
        ],
        if (missed.isNotEmpty) ...[
          _buildPriseSection('Prises manquees', missed),
          const SizedBox(height: 12),
        ],
        if (confirmed.isNotEmpty) _buildPriseSection('Prises confirmees', confirmed),
      ],
    );
  }

  Widget _buildPriseSection(String title, List<dynamic> prises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...prises.map((prise) => _buildPriseCard(prise)),
      ],
    );
  }

  List<dynamic> _sortedPrises(List<dynamic> prises) {
    final copy = List<dynamic>.from(prises);
    copy.sort((a, b) {
      final aDate = a.heurePrevueDateTime ?? DateTime.now();
      final bDate = b.heurePrevueDateTime ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    return copy;
  }

  bool _isConfirmedPrise(dynamic prise) => prise.statut == 'CONFIRMEE';

  bool _isMissedPrise(dynamic prise) => prise.statut == 'MANQUEE';

  bool _hasOverduePrise(List<dynamic> prises) =>
      prises.any((prise) => _isOverdue(prise));

  String _statusLabel(dynamic prise) {
    if (_isConfirmedPrise(prise)) {
      return 'Confirmee';
    }
    if (_isMissedPrise(prise)) {
      return 'Manquee';
    }
    if (_isOverdue(prise)) {
      return 'En retard';
    }
    return 'Planifiee';
  }

  Widget _buildSummaryCards(TreatmentProvider treatmentProvider, int prochesCount) {
    final adherence = treatmentProvider.adherenceSummary;
    final totalPrises = treatmentProvider.todayPrises.length;
    final pendingPrises = treatmentProvider.todayPrises
        .where((prise) => prise.statut != 'CONFIRMEE')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            value: '${adherence?.pourcentageGlobal ?? 0}%',
            label: 'Observance',
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            value: '$totalPrises',
            label: 'Prises du jour',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            value: '$prochesCount',
            label: 'Proches',
            color: pendingPrises > 0 ? AppColors.errorRed : const Color(0xFFFF7A59),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySection(ProcheViewModel prochesVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes proches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            TextButton(
              onPressed: _showFamilyMembersDialog,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (prochesVm.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          )
        else if (prochesVm.proches.isEmpty)
          _buildEmptyState(
            title: 'Aucun proche ajouté',
            subtitle: 'Ajoutez un proche par email ou QR code pour suivre son observance.',
            icon: Icons.family_restroom,
            actionLabel: 'Ajouter un proche',
            onAction: _showAddProcheDialog,
          )
        else
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: prochesVm.proches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildProcheCard(prochesVm.proches[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildProcheCard(ProcheModel proche) {
    final imageData = _extractBase64(proche.photoBase64);
    return InkWell(
      onTap: () => AppRoutes.navigateToProcheDetail(context, proche),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 210,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
              backgroundImage: imageData == null ? null : MemoryImage(base64Decode(imageData)),
              child: imageData == null
                  ? Text(
                      _avatarLabel(proche),
                      style: const TextStyle(fontSize: 18),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    proche.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    proche.relation ?? 'Proche',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  if ((proche.status ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      proche.status!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (proche.status ?? '').toLowerCase().contains('rappel')
                            ? AppColors.errorRed
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriseCard(dynamic prise) {
    final isConfirmed = _isConfirmedPrise(prise);
    final isMissed = _isMissedPrise(prise);
    final isOverdue = _isOverdue(prise);
    final accentColor = isConfirmed
        ? AppColors.primaryGreen
        : isMissed || isOverdue
            ? AppColors.errorRed
            : AppColors.primaryBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prise.medicamentNom ?? 'Médicament',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${prise.heurePrevue ?? 'N/A'} · ${prise.dosage ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildDoseStatusMessage(prise),
                  style: TextStyle(fontSize: 11, color: accentColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isConfirmed ? 'Confirmée' : 'En attente',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow({
    required String title,
    required String subtitle,
    required bool isSuccess,
  }) {
    final color = isSuccess ? AppColors.primaryGreen : AppColors.errorRed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            isSuccess ? 'OK' : 'En retard',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

<<<<<<< HEAD
=======
  dynamic _findPriorityPrise(List<dynamic> prises) {
    if (prises.isEmpty) {
      return null;
    }

    final pending = prises
        .where(
          (prise) =>
              prise.statut != 'CONFIRMEE' && prise.statut != 'MANQUEE',
        )
        .toList();
    if (pending.isEmpty) {
      return null;
    }

    pending.sort((a, b) {
      final aDate = a.heurePrevueDateTime ?? DateTime.now();
      final bDate = b.heurePrevueDateTime ?? DateTime.now();
      return aDate.compareTo(bDate);
    });

    final overdue = pending.where(_isOverdue).toList();
    if (overdue.isNotEmpty) {
      return overdue.first;
    }

    return pending.first;
  }

>>>>>>> aa86dbabf5ff427bb1e238a1def1446a9a57bc24
  Future<void> _refreshAll() async {
    final authVm = context.read<AuthViewModel>();
    final patientId = authVm.currentUser?.id;
    await context.read<ProcheViewModel>().refresh();
    if (patientId != null && patientId.isNotEmpty) {
      final treatmentProvider = context.read<TreatmentProvider>();
      await treatmentProvider.loadTodayPrises(patientId);
      await treatmentProvider.loadAllPrises(patientId);
      await treatmentProvider.loadAdherenceSummary(patientId);
      await _syncScheduledDoseReminders(treatmentProvider.todayPrises);
      _maybeShowDueDoseReminder();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      unawaited(_refreshAll());
    });
  }

  Future<void> _syncScheduledDoseReminders(List<dynamic> prises) async {
    final preferences = await _notificationPreferencesService.load();
    if (!preferences.remindersEnabled) {
      return;
    }

    final now = DateTime.now();
    for (final prise in prises) {
      final notificationId = prise.id.hashCode;
      if (_isConfirmedPrise(prise) || _isMissedPrise(prise)) {
        await LocalNotificationService().cancelDoseReminder(notificationId);
        continue;
      }

      final scheduled = prise.heurePrevueDateTime;
      if (scheduled == null || !scheduled.isAfter(now)) {
        continue;
      }

      await LocalNotificationService().scheduleExactDoseReminder(
        id: notificationId,
        scheduledAt: scheduled,
        title: 'Prise de medicament',
        body:
            'Il est l\'heure de prendre ${prise.medicamentNom} (${prise.dosage ?? 'dose prescrite'}).',
        playSound: preferences.soundEnabled,
      );
    }
  }

  String _avatarLabel(ProcheModel proche) {
    final relation = (proche.relation ?? '').toLowerCase();
    if (relation.contains('pere')) return '👨';
    if (relation.contains('mere')) return '👩';
    if (relation.contains('fils') || relation.contains('fille')) return '🧒';
    if (relation.contains('grand')) return '👴';
    return '👤';
  }

  void _showAddProcheDialog() {
    showDialog(
      context: context,
      builder: (_) => AddProcheDialogWidget(
        onProcheAdded: () {
          if (mounted) {
            context.read<ProcheViewModel>().refresh();
          }
        },
      ),
    );
  }

  void _showFamilyMembersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final proches = ctx.watch<ProcheViewModel>().proches;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
                'Mes proches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              if (proches.isEmpty)
                _buildEmptyState(
                  title: 'Aucun proche lié',
                  subtitle: 'Ajoutez un proche pour partager le suivi médical.',
                  icon: Icons.family_restroom,
                  actionLabel: 'Ajouter',
                  onAction: () {
                    Navigator.pop(ctx);
                    _showAddProcheDialog();
                  },
                )
              else
                ...proches.map(
                  (proche) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                      backgroundImage: _extractBase64(proche.photoBase64) == null
                          ? null
                          : MemoryImage(base64Decode(_extractBase64(proche.photoBase64)!)),
                      child: _extractBase64(proche.photoBase64) == null
                          ? Text(_avatarLabel(proche))
                          : null,
                    ),
                    title: Text(proche.fullName),
                    subtitle: Text(
                      [
                        proche.relation ?? 'Proche',
                        if ((proche.status ?? '').isNotEmpty) proche.status!,
                      ].join(' • '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      AppRoutes.navigateToProcheDetail(context, proche);
                    },
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAddProcheDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    'Ajouter un proche',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isOverdueByThirtyMinutes(dynamic prise) {
    final scheduled = prise.heurePrevueDateTime;
    if (scheduled == null || prise.statut == 'CONFIRMEE') {
      return false;
    }
    return DateTime.now().isAfter(scheduled.add(const Duration(minutes: 30)));
  }

  bool _isOverdue(dynamic prise) {
    final scheduled = prise.heurePrevueDateTime;
    if (scheduled == null || prise.statut == 'CONFIRMEE') {
      return false;
    }
    return DateTime.now().isAfter(scheduled);
  }

  bool _isDueSoon(dynamic prise) {
    final scheduled = prise.heurePrevueDateTime;
    if (scheduled == null || prise.statut == 'CONFIRMEE') {
      return false;
    }
    final now = DateTime.now();
    return scheduled.isBefore(now.add(const Duration(minutes: 5))) &&
        scheduled.isAfter(now.subtract(const Duration(minutes: 10)));
  }

  String _formatScheduleLabel(DateTime? scheduled) {
    if (scheduled == null) {
      return 'Heure inconnue';
    }

    final hh = scheduled.hour.toString().padLeft(2, '0');
    final mm = scheduled.minute.toString().padLeft(2, '0');
    final now = DateTime.now();

    if (_isSameDay(now, scheduled)) {
      return '$hh:$mm aujourd\'hui';
    }

    final day = scheduled.day.toString().padLeft(2, '0');
    final month = scheduled.month.toString().padLeft(2, '0');
    return '$hh:$mm le $day/$month';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _maybeShowDueDoseReminder() {
    final due = _findPriorityPrise(context.read<TreatmentProvider>().todayPrises);
    if (due == null) {
      return;
    }
    final shouldRemind = _isOverdue(due) || _isDueSoon(due);
    if (!shouldRemind) {
      return;
    }
    unawaited(_triggerDoseReminder(due));
  }

  Future<void> _triggerDoseReminder(dynamic due) async {
    final preferences = await _notificationPreferencesService.load();
    if (!preferences.remindersEnabled) {
      return;
    }

    final now = DateTime.now();
    final minimumGap = preferences.repeatEveryMinuteUntilConfirmed
        ? const Duration(minutes: 1)
        : const Duration(minutes: 30);

    if (_lastReminderPriseId == due.id &&
        _lastReminderShownAt != null &&
        now.difference(_lastReminderShownAt!) < minimumGap) {
      return;
    }

    _lastReminderPriseId = due.id;
    _lastReminderShownAt = now;

    final title = _isOverdue(due) ? 'Rappel urgent de prise' : 'Rappel de prise';

    final body =
        'Prenez ${due.medicamentNom} (${due.dosage ?? 'dose prescrite'}) puis confirmez la prise dans PharmaCare.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title: ${due.medicamentNom} a ${_formatScheduleLabel(due.heurePrevueDateTime)}.',
        ),
        backgroundColor:
            _isOverdue(due) ? AppColors.errorRed : AppColors.primaryBlue,
        duration: const Duration(seconds: 6),
      ),
    );

    await LocalNotificationService().showDoseReminder(
      id: due.id.hashCode,
      title: title,
      body: body,
      playSound: preferences.soundEnabled,
    );
  }

  String? _extractBase64(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return raw.contains(',') ? raw.split(',').last : raw;
  }
}

