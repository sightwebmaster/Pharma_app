import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pharma_app/core/constants/app_colors.dart';
import 'package:pharma_app/core/routes/app_routes.dart';
import 'package:pharma_app/presentation/widgets/pharma_bottom_nav.dart';
import 'package:pharma_app/presentation/screens/recommendation/recommendation_screen.dart';
import 'package:pharma_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/pharmacien_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/profile_viewmodel.dart';
import 'package:pharma_app/presentation/widgets/common/user_avatar.dart';
import 'package:pharma_app/presentation/widgets/qr_scanner_widget.dart';

class PharmacienDashboard extends StatefulWidget {
  const PharmacienDashboard({super.key});

  @override
  State<PharmacienDashboard> createState() => _PharmacienDashboardState();
}

class _PharmacienDashboardState extends State<PharmacienDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedPatient;
  String? _pendingPatientAction;
  final TextEditingController _manualPatientIdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmacienViewModel>().loadPatients();
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  void dispose() {
    _manualPatientIdController.dispose();
    _searchController.dispose();
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
            _buildScannerTab(),
            _buildPatientsTab(),
            _buildTreatmentTab(),
            _buildProfileTab(),
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
        PharmaNavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,             label: 'Accueil'),
        PharmaNavItem(icon: Icons.qr_code_scanner,    activeIcon: Icons.qr_code_scanner,          label: 'Scanner'),
        PharmaNavItem(icon: Icons.people_outline,     activeIcon: Icons.people_rounded,           label: 'Patients'),
        PharmaNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded,       label: 'Soins'),
        PharmaNavItem(icon: Icons.person_outline,     activeIcon: Icons.person_rounded,           label: 'Profil'),
      ],
    );
  }

  Widget _buildHomeTab() {
    final vm = context.watch<PharmacienViewModel>();
    final patients = vm.patients;

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => vm.refresh(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        value: '${patients.length}',
                        label: 'Patients liés',
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        value: '${vm.pendingCount}',
                        label: 'À surveiller',
                        color: AppColors.errorRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        value: _selectedPatient == null ? '0' : '1',
                        label: 'Patient actif',
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
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
                  childAspectRatio: 1.0,
                  children: [
                    _buildActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scanner patient',
                      subtitle: 'Lier un patient par QR ou email',
                      color: AppColors.primaryBlue,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    _buildActionCard(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Recommandation IA',
                      subtitle: _selectedPatient == null
                          ? 'Choisir un patient'
                          : 'Pour ${_selectedPatient!['name']}',
                      color: AppColors.primaryGreen,
                      onTap: _openRecommendationForSelectedPatient,
                    ),
                    _buildActionCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Planifier traitement',
                      subtitle: 'Préremplir le dossier patient',
                      color: const Color(0xFF6C63FF),
                      onTap: _openTreatmentPlanning,
                    ),
                    _buildActionCard(
                      icon: Icons.settings_outlined,
                      title: 'Profil & sécurité',
                      subtitle: 'Photo, mot de passe, infos',
                      color: const Color(0xFFFF7A59),
                      onTap: () => setState(() => _selectedIndex = 4),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Patients récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    ),
                  )
                else if (patients.isEmpty)
                  _buildEmptyState(
                    title: 'Aucun patient lié',
                    subtitle: 'Scannez le QR code d’un patient pour remplir votre tableau de bord.',
                    icon: Icons.people_outline,
                    actionLabel: 'Scanner un QR',
                    onAction: () => setState(() => _selectedIndex = 1),
                  )
                else
                  ...patients.take(3).map(_buildPatientCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    final vm = context.watch<PharmacienViewModel>();
    final selectedPatient = _selectedPatient;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Scanner un patient',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Scannez le QR code du patient ou entrez son email pour récupérer son dossier.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
        _buildScannerHero(),
        const SizedBox(height: 20),
        TextField(
          controller: _manualPatientIdController,
          decoration: InputDecoration(
            labelText: 'Email ou identifiant patient',
            hintText: 'patient@example.com ou UUID',
            suffixIcon: IconButton(
              onPressed: _linkPatientManually,
              icon: const Icon(Icons.search),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onSubmitted: (_) => _linkPatientManually(),
        ),
        const SizedBox(height: 8),
        const Text(
          'Méthode 1: scannez le QR Code du patient. Méthode 2: saisissez son email puis appuyez sur la loupe.',
          style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.4),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: vm.isLoading ? null : _openQrScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: Text(
              vm.isLoading ? 'Scan en cours...' : 'Scanner le QR Code',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (vm.error != null) ...[
          const SizedBox(height: 12),
          Text(
            vm.error!,
            style: const TextStyle(color: AppColors.errorRed),
          ),
        ],
        const SizedBox(height: 24),
        if (selectedPatient != null)
          _buildSelectedPatientPanel(selectedPatient)
        else
          _buildEmptyState(
            title: 'Aucun patient sélectionné',
            subtitle: 'Après le scan, son profil médical apparaitra ici avec les données utiles à la recommandation.',
            icon: Icons.person_search_outlined,
          ),
      ],
    );
  }

  Widget _buildPatientsTab() {
    final vm = context.watch<PharmacienViewModel>();
    final query = _searchController.text.trim().toLowerCase();
    final patients = vm.patients.where((patient) {
      final haystack = [
        patient['name'],
        patient['telephone'],
        patient['groupeSanguin'],
        patient['maladie'],
      ].whereType<String>().join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Mes patients',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Recherchez un patient et ouvrez directement sa recommandation.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Rechercher',
            hintText: 'Nom, téléphone, groupe sanguin...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          )
        else if (patients.isEmpty)
          _buildEmptyState(
            title: 'Aucun patient trouvé',
            subtitle: 'Essayez un autre mot-clé ou scannez un nouveau patient.',
            icon: Icons.people_outline,
          )
        else
          ...patients.map(_buildPatientCard),
      ],
    );
  }

  Widget _buildTreatmentTab() {
    final patient = _selectedPatient;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Traitements & recommandation',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sélectionnez un patient, générez une recommandation, puis planifiez son traitement.',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
        if (patient == null)
          _buildEmptyState(
            title: 'Aucun patient actif',
            subtitle: 'Commencez par scanner un QR code patient ou sélectionnez un patient existant.',
            icon: Icons.qr_code_scanner,
            actionLabel: 'Scanner maintenant',
            onAction: () => setState(() => _selectedIndex = 1),
          )
        else ...[
          _buildSelectedPatientPanel(patient),
          const SizedBox(height: 20),
          _buildWorkflowCard(
            step: '1',
            title: 'Analyser les symptômes',
            subtitle: 'Ouvrir l’écran de recommandation IA avec le contexte patient complet.',
            icon: Icons.psychology_alt_outlined,
            color: AppColors.primaryBlue,
            onTap: _openRecommendationForSelectedPatient,
          ),
          const SizedBox(height: 12),
          _buildWorkflowCard(
            step: '2',
            title: 'Planifier le traitement',
            subtitle: 'Créer automatiquement le traitement et compléter fréquence, durée et instructions.',
            icon: Icons.calendar_month_outlined,
            color: AppColors.primaryGreen,
            onTap: _openTreatmentPlanning,
          ),
        ],
      ],
    );
  }

  Widget _buildProfileTab() {
    final profileUser = context.watch<ProfileViewModel>().currentUser;
    final authUser = context.watch<AuthViewModel>().currentUser;
    final user = profileUser ?? authUser;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, Color(0xFF6580F5)],
            ),
          ),
          child: Column(
            children: [
              UserAvatar(
                user: user,
                radius: 48,
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 14),
              Text(
                user?.fullName.isNotEmpty == true ? user!.fullName : 'Pharmacien',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                user?.specialite?.isNotEmpty == true
                    ? '${user!.specialite} · ${user.numeroOrdre ?? 'Ordre non renseigné'}'
                    : 'Profil pharmacien',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileInfoCard(user),
              const SizedBox(height: 16),
              _buildProfileActionButton(
                icon: Icons.edit_outlined,
                title: 'Modifier mon profil',
                subtitle: 'Photo, téléphone, spécialité, numéro d’ordre',
                color: AppColors.primaryBlue,
                onTap: () => AppRoutes.navigateToEditProfile(context),
              ),
              const SizedBox(height: 12),
              _buildProfileActionButton(
                icon: Icons.lock_outline,
                title: 'Sécurité du compte',
                subtitle: 'Changer le mot de passe et ouvrir les paramètres',
                color: AppColors.primaryGreen,
                onTap: () => AppRoutes.navigateToProfileSetting(context),
              ),
              const SizedBox(height: 12),
              _buildProfileActionButton(
                icon: Icons.logout,
                title: 'Déconnexion',
                subtitle: 'Fermer la session en toute sécurité',
                color: AppColors.errorRed,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final profileUser = context.watch<ProfileViewModel>().currentUser;
    final user = profileUser ?? context.watch<AuthViewModel>().currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.pharmacienGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PharmaCare',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                user?.fullName.isNotEmpty == true ? user!.fullName : 'Pharmacien',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          UserAvatar(
            user: user,
            radius: 26,
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 12,
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final observance = (patient['observance'] as num?)?.toDouble() ?? 0.0;
    final subtitle = _patientSubtitle(patient);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPatient = patient;
            _selectedIndex = 3;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
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
            UserAvatar(
              user: _mapPatientToUser(patient),
              radius: 22,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'] as String? ?? 'Patient',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  observance > 0 ? '${(observance * 100).round()}%' : 'N/A',
                  style: TextStyle(
                    color: observance >= 0.8
                        ? AppColors.primaryGreen
                        : observance >= 0.5
                            ? const Color(0xFFFFA726)
                            : AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'observance',
                  style: TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(
            Icons.qr_code_scanner,
            size: 72,
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 12),
          Text(
            'Le QR code du patient permet de récupérer ses allergies, sa grossesse éventuelle, sa date de naissance et ses maladies chroniques.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPatientPanel(Map<String, dynamic> patient) {
    final allergies = (patient['allergiesList'] as List<dynamic>? ?? const []);
    final conditions = (patient['maladiesChroniques'] as List<dynamic>? ?? const []);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                user: _mapPatientToUser(patient),
                radius: 24,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['name'] as String? ?? 'Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _patientSubtitle(patient),
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Âge: ${patient['age'] ?? 0} ans'),
              _buildTag('Grossesse: ${(patient['pregnant'] as bool? ?? false) ? 'Oui' : 'Non'}'),
              if ((patient['groupeSanguin'] as String?)?.isNotEmpty == true)
                _buildTag('Groupe: ${patient['groupeSanguin']}'),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoLine(
            'Allergies',
            allergies.isEmpty ? 'Aucune' : allergies.join(', '),
          ),
          const SizedBox(height: 8),
          _buildInfoLine(
            'Maladies chroniques',
            conditions.isEmpty ? 'Aucune' : conditions.join(', '),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openRecommendationForSelectedPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  icon: const Icon(Icons.psychology_alt_outlined, color: Colors.white),
                  label: const Text(
                    'Générer recommandation IA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowCard({
    required String step,
    required String title,
    required String subtitle,
    required IconData icon,
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
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Text(
                step,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations professionnelles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoLine('Nom', user?.fullName ?? 'Non renseigné'),
          const SizedBox(height: 10),
          _buildInfoLine('Téléphone', user?.telephone ?? 'Non renseigné'),
          const SizedBox(height: 10),
          _buildInfoLine('Email', user?.email ?? 'Non renseigné'),
          const SizedBox(height: 10),
          _buildInfoLine('Numéro d’ordre', user?.numeroOrdre ?? 'Non renseigné'),
          const SizedBox(height: 10),
          _buildInfoLine('Spécialité', user?.specialite ?? 'Non renseignée'),
        ],
      ),
    );
  }

  Widget _buildProfileActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
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
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.grey),
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
                backgroundColor: AppColors.primaryBlue,
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

  Future<void> _openQrScanner() async {
    final qrData = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerWidget(
          onQRCodeScanned: (_) {},
        ),
      ),
    );

    if (!mounted || qrData == null || qrData.trim().isEmpty) {
      return;
    }

    _manualPatientIdController.text = qrData.trim();
    await _linkPatientById(qrData.trim());
  }

  Future<void> _linkPatientManually() async {
    final value = _manualPatientIdController.text.trim();
    if (value.isEmpty) {
      return;
    }
    if (value.contains('@')) {
      await _linkPatientByEmail(value);
      return;
    }
    await _linkPatientById(value);
  }

  Future<void> _linkPatientById(String userId) async {
    final vm = context.read<PharmacienViewModel>();
    final success = await vm.scanQrCode(userId);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Impossible de lier ce patient'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final patient = vm.patients.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['id'] == userId,
          orElse: () => null,
        );

    setState(() {
      _selectedPatient = patient;
      _selectedIndex = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient lié avec succès'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    _consumePendingPatientAction();
  }

  Future<void> _linkPatientByEmail(String email) async {
    final vm = context.read<PharmacienViewModel>();
    final success = await vm.linkPatientByEmail(email);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Impossible de récupérer ce patient'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final lowered = email.toLowerCase();
    final patient = vm.patients.cast<Map<String, dynamic>?>().firstWhere(
          (item) => (item?['email'] as String? ?? '').toLowerCase() == lowered,
          orElse: () => null,
        );

    setState(() {
      _selectedPatient = patient;
      _selectedIndex = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient récupéré avec succès'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    _consumePendingPatientAction();
  }

  void _openRecommendationForSelectedPatient() {
    final patient = _selectedPatient;
    if (patient == null) {
      _pendingPatientAction = 'recommendation';
      setState(() => _selectedIndex = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scannez ou recherchez un patient avant la recommandation'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez d’abord un patient'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(
          isPharmacienMode: true,
          patientId: patient['id'] as String?,
          patientDisplayName: patient['name'] as String?,
        ),
      ),
    );
  }

  void _openTreatmentPlanning() {
    final patient = _selectedPatient;
    if (patient == null) {
      _pendingPatientAction = 'treatment';
      setState(() => _selectedIndex = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scannez ou recherchez un patient avant de planifier un traitement'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez un patient avant de planifier un traitement'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    AppRoutes.navigateToAddMedicine(
      context,
      patientId: patient['id'] as String? ?? '',
      patientName: patient['name'] as String? ?? 'Patient',
      patientAge: patient['age'] as int? ?? 0,
      patientSex: patient['sex'] as String? ?? 'Inconnu',
      allergies: patient['allergies'] as String? ?? 'Aucune',
      isPregnant: patient['pregnant'] as bool? ?? false,
    );
  }

  void _consumePendingPatientAction() {
    final action = _pendingPatientAction;
    _pendingPatientAction = null;

    if (action == 'recommendation') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openRecommendationForSelectedPatient();
        }
      });
      return;
    }

    if (action == 'treatment') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openTreatmentPlanning();
        }
      });
    }
  }

  String _patientSubtitle(Map<String, dynamic> patient) {
    final parts = <String>[];
    final age = patient['age'] as int? ?? 0;
    if (age > 0) {
      parts.add('$age ans');
    }
    final telephone = patient['telephone'] as String?;
    if (telephone != null && telephone.isNotEmpty) {
      parts.add(telephone);
    }
    final maladie = patient['maladie'] as String?;
    if (maladie != null && maladie.isNotEmpty) {
      parts.add(maladie);
    }
    return parts.isEmpty ? 'Patient' : parts.join(' · ');
  }

  dynamic _mapPatientToUser(Map<String, dynamic> patient) {
    return context.read<AuthViewModel>().currentUser?.copyWith(
          id: patient['id'] as String? ?? '',
          nom: patient['nom'] as String? ?? '',
          prenom: patient['prenom'] as String? ?? '',
          email: patient['email'] as String?,
          telephone: patient['telephone'] as String?,
          groupeSanguin: patient['groupeSanguin'] as String?,
          photoBase64: patient['photoBase64'] as String?,
          role: 'PATIENT',
        );
  }

  Future<void> _logout() async {
    context.read<ProfileViewModel>().resetState();
    await context.read<AuthViewModel>().logout();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
