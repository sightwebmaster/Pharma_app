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

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.person_outline, 'label': 'Profil'},
    {'icon': Icons.medication_outlined, 'label': 'Médicaments'},
    {'icon': Icons.assignment_outlined, 'label': 'Planning'},
    {'icon': Icons.medical_services_outlined, 'label': 'Recommandation'},
    {'icon': Icons.family_restroom, 'label': 'Proche', 'badge': 'Nouveau'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Charge les proches depuis le backend
      context.read<ProcheViewModel>().loadProches();

      // ✅ Charge les prises du jour depuis treatment-service
      final authVm = context.read<AuthViewModel>();
      final patientId = authVm.currentUser?.id;
      if (patientId != null) {
        context.read<TreatmentProvider>().loadTodayPrises(patientId);
      }
    });
  }

  @override
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
      ),
    );
  }
}