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
import 'package:pharma_app/services/treatment_provider.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final patientId = authVm.currentUser?.id;

      context.read<ProcheViewModel>().loadProches();

      if (patientId != null && patientId.isNotEmpty) {
        final treatmentProvider = context.read<TreatmentProvider>();
        treatmentProvider.loadTodayPrises(patientId);
        treatmentProvider.loadAllPrises(patientId);
        treatmentProvider.loadAdherenceSummary(patientId);
      }
    });
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
      ),
    );
  }

  Widget _buildHomeTab() {
    final authVm = context.watch<AuthViewModel>();
    final treatmentProvider = context.watch<TreatmentProvider>();
    final prochesVm = context.watch<ProcheViewModel>();
    final user = authVm.currentUser;

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
                  ...treatmentProvider.todayPrises
                      .map((prise) => _buildPriseCard(prise)),
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
          ...treatmentProvider.todayPrises.map((prise) => _buildPriseCard(prise)),
      ],
    );
  }

  Widget _buildHistoriqueTab() {
    final treatmentProvider = context.watch<TreatmentProvider>();
    final adherence = treatmentProvider.adherenceSummary;
    final prises = treatmentProvider.todayPrises;
    final confirmedCount = prises.where((prise) => prise.statut == 'CONFIRMEE').length;
    final totalCount = prises.length;
    final missedCount = totalCount - confirmedCount;
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
          ...prises.map(
            (prise) => _buildHistoryRow(
              title: prise.medicamentNom ?? 'Médicament',
              subtitle: '${prise.heurePrevue ?? 'N/A'} · ${prise.dosage ?? 'N/A'}',
              isSuccess: prise.statut == 'CONFIRMEE',
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

    final notifications = <Map<String, dynamic>>[
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
          const Text(
            'Prochaine prise',
            style: TextStyle(color: Colors.white70, fontSize: 13),
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
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              if (nextPrise.id == null) {
                return;
              }
              final success = await context.read<TreatmentProvider>().confirmerPrise(nextPrise);
              if (!mounted) {
                return;
              }
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
            child: const Text('Confirmer maintenant'),
          ),
        ],
      ),
    );
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
              child: Text(
                _avatarLabel(proche),
                style: const TextStyle(fontSize: 18),
              ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriseCard(dynamic prise) {
    final isConfirmed = prise.statut == 'CONFIRMEE';
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
              color: (isConfirmed ? AppColors.primaryGreen : AppColors.primaryBlue)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: isConfirmed ? AppColors.primaryGreen : AppColors.primaryBlue,
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isConfirmed ? AppColors.primaryGreen : AppColors.errorRed)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isConfirmed ? 'Confirmée' : 'En attente',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isConfirmed ? AppColors.primaryGreen : AppColors.errorRed,
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

  Future<void> _refreshAll() async {
    final authVm = context.read<AuthViewModel>();
    final patientId = authVm.currentUser?.id;
    await context.read<ProcheViewModel>().refresh();
    if (patientId != null && patientId.isNotEmpty) {
      await context.read<TreatmentProvider>().loadTodayPrises(patientId);
      await context.read<TreatmentProvider>().loadAllPrises(patientId);
      await context.read<TreatmentProvider>().loadAdherenceSummary(patientId);
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
                      child: Text(_avatarLabel(proche)),
                    ),
                    title: Text(proche.fullName),
                    subtitle: Text(proche.relation ?? 'Proche'),
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
}
