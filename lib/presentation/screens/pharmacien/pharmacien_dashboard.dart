import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:pharma_app/core/constants/app_colors.dart';
import 'package:pharma_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/pharmacien_viewmodel.dart';
import 'package:pharma_app/core/routes/app_routes.dart';

=======

import 'package:pharma_app/core/constants/app_colors.dart';
import 'package:pharma_app/core/routes/app_routes.dart';
import 'package:pharma_app/presentation/widgets/pharma_bottom_nav.dart';
import 'package:pharma_app/presentation/screens/recommendation/recommendation_screen.dart';
import 'package:pharma_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/pharmacien_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/profile_viewmodel.dart';
import 'package:pharma_app/presentation/widgets/common/user_avatar.dart';
import 'package:pharma_app/presentation/widgets/qr_scanner_widget.dart';

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
class PharmacienDashboard extends StatefulWidget {
  const PharmacienDashboard({super.key});

  @override
  State<PharmacienDashboard> createState() => _PharmacienDashboardState();
}

class _PharmacienDashboardState extends State<PharmacienDashboard> {
  int _selectedIndex = 0;
<<<<<<< HEAD

  Map<String, dynamic>? _scannedPatient;
  String _searchQuery = '';
  String _buildPatientSubtitle(Map<String, dynamic> patient) {
    final parts = <String>[];

    final maladie = patient['maladie'] as String?;
    if (maladie != null && maladie.isNotEmpty) parts.add(maladie);

    final telephone = patient['telephone'] as String?;
    if (telephone != null && telephone.isNotEmpty) parts.add(telephone);

    final groupeSanguin = patient['groupeSanguin'] as String?;
    if (groupeSanguin != null && groupeSanguin.isNotEmpty) {
      parts.add('Groupe: $groupeSanguin');
    }

    return parts.isNotEmpty ? parts.join(' · ') : 'Patient';
  }
=======
  Map<String, dynamic>? _selectedPatient;
  String? _pendingPatientAction;
  final TextEditingController _manualPatientIdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmacienViewModel>().loadPatients();
<<<<<<< HEAD
=======
      context.read<ProfileViewModel>().loadProfile();
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
            _buildAccueilTab(),
            _buildScannerTab(),
            _buildPatientsTab(),
            _buildTraitementsTab(),
            _buildProfilTab(),
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
      {'icon': Icons.qr_code_scanner, 'label': 'Scanner'},
      {'icon': Icons.people_outline, 'label': 'Patients'},
      {'icon': Icons.assignment_outlined, 'label': 'Traitements'},
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
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: items
            .map(
              (e) => BottomNavigationBarItem(
                icon: Icon(e['icon'] as IconData),
                label: e['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }

  // ─── ACCUEIL TAB ───────────────────────────────────────────────────────────
  Widget _buildAccueilTab() {
    final patients = context.watch<PharmacienViewModel>().patients;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPharmacienHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(),
                const SizedBox(height: 24),

                // Actions rapides
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildQuickAction(
                      Icons.qr_code_scanner,
                      'Scanner Patient',
                      AppColors.primaryBlue,
                      () => setState(() => _selectedIndex = 1),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      Icons.medical_services_outlined,
                      'Recommandation',
                      AppColors.primaryGreen,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RecommandationPharmacienScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Liste patients récents
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Patients récents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 2),
                      child: const Text(
                        'Voir tous',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...patients.take(2).map((p) => _buildPatientCard(p)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacienHeader() {
    final user = context.watch<AuthViewModel>().currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF6580F5)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bonjour 👋',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                user?.fullName ?? 'Pharmacien',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Pharmacien',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final vm = context.watch<PharmacienViewModel>();
    final patients = vm.patients;

    return Row(
      children: [
        _buildStatCard('${patients.length}', 'Patients', AppColors.primaryBlue),
        const SizedBox(width: 10),
        _buildStatCard(
          '${patients.length}',
          'Planif. actives',
          AppColors.primaryGreen,
        ),
        const SizedBox(width: 10),
        _buildStatCard('${vm.pendingCount}', 'En attente', AppColors.grey),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CORRECTION 2 — _buildPatientCard
  // ❌ patient['age'] = 0, patient['maladie'] = '' → affichage vide
  // ✅ Afficher telephone + groupeSanguin si age/maladie absents
  // ─────────────────────────────────────────────────────────────

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final observance = patient['observance'] as double? ?? 0.0;
    Color obsColor = observance >= 0.8
        ? AppColors.primaryGreen
        : observance >= 0.5
        ? const Color(0xFFFFA726)
        : AppColors.grey; // ✅ gris si 0.0 (pas encore chargé)

    // ✅ Ligne de détail selon les données disponibles
    final String subtitle = _buildPatientSubtitle(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
          child: Text(
            (patient['name'] as String).isNotEmpty
                ? (patient['name'] as String).substring(0, 1)
                : '?',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          patient['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              observance > 0
                  ? '${(observance * 100).toInt()}%'
                  : 'N/A', // ✅ N/A si pas encore connecté à adherence-service
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: obsColor,
              ),
            ),
            const Text(
              'observance',
              style: TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
        onTap: () {
          // ✅ Sélectionne le patient et va sur l'onglet Scanner
          setState(() {
            _scannedPatient = patient;
            _selectedIndex = 1;
          });
        },
      ),
    );
  }

  // ─── SCANNER TAB ───────────────────────────────────────────────────────────
  Widget _buildScannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Scanner QR Code',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scannez le QR code du patient pour accéder à son profil',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 24),

          // Zone de scan
          _buildScanArea(),
          const SizedBox(height: 24),

          // Ou sélectionner manuellement
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ou sélectionner un patient',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          ...context.watch<PharmacienViewModel>().patients.map(
            (p) => _buildScanPatientItem(p),
          ),

          // Patient scanné
          if (_scannedPatient != null) ...[
            const SizedBox(height: 24),
            _buildScannedPatientDetail(),
          ],
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.25),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: AppColors.primaryBlue.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pointez vers le QR Code du patient',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Du bracelet ou de son profil',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                // Simulation scan → sélectionner le premier patient
                final patients = context.read<PharmacienViewModel>().patients;
                setState(() {
                  _scannedPatient = patients.isNotEmpty ? patients[0] : null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR Code scanné avec succès !'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              label: const Text(
                'Activer la caméra',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CORRECTION 1 — _buildScanPatientItem
  // ❌ patient['qrCode'] affiche tout le base64 PNG → overflow + 404
  // ✅ Afficher seulement les 8 premiers caractères de l'userId
  // ─────────────────────────────────────────────────────────────

  Widget _buildScanPatientItem(Map<String, dynamic> patient) {
    final isSelected = _scannedPatient?['name'] == patient['name'];
    // ✅ Afficher userId tronqué au lieu du base64
    final String patientId = patient['id'] as String? ?? '';
    final String idDisplay = patientId.length > 8
        ? '${patientId.substring(0, 8)}...'
        : patientId;

    return GestureDetector(
      onTap: () => setState(() => _scannedPatient = patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
              child: Text(
                (patient['name'] as String).isNotEmpty
                    ? (patient['name'] as String).substring(0, 1)
                    : '?',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    // ✅ maladie peut être vide — afficher téléphone si dispo
                    patient['telephone'] as String? ??
                        patient['maladie'] as String? ??
                        '',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            // ✅ Afficher ID tronqué au lieu du base64
            Text(
              idDisplay,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              size: 16,
              color: isSelected ? AppColors.primaryGreen : AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedPatientDetail() {
    final patient = _scannedPatient!;
    final meds = patient['meds'] as List<Map<String, dynamic>>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header patient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF6580F5)],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(
                      (patient['name'] as String).substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${patient['age']} ans · ${patient['maladie']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '● Actif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Médicaments
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Traitement en cours',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...meds.map((med) => _buildScannedMedRow(med)),
                  const SizedBox(height: 16),

                  // Boutons action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            AppRoutes.navigateToAddMedicine(
                              context,
                              patientId: patient['id'] as String,
                              patientName: patient['name'] as String,
                              patientAge: patient['age'] as int,
                              patientSex: patient['sex'] as String,
                              allergies: patient['allergies'] as String,
                              isPregnant: patient['pregnant'] as bool,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '+ Planifier prise',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RecommandationPharmacienScreen(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '🩺 Recommandation',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedMedRow(Map<String, dynamic> med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medication_outlined,
            size: 18,
            color: AppColors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  med['dose'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PATIENTS TAB ──────────────────────────────────────────────────────────
  Widget _buildPatientsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Mes Patients',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Search
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Rechercher un patient...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: context
                  .watch<PharmacienViewModel>()
                  .patients
                  .where(
                    (p) => (p['name'] as String).toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .map<Widget>((p) => _buildDetailedPatientCard(p))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CORRECTION 3 — _buildDetailedPatientCard
  // ✅ Même corrections que _buildPatientCard + bouton Planifier
  // ─────────────────────────────────────────────────────────────

  Widget _buildDetailedPatientCard(Map<String, dynamic> patient) {
    final observance = patient['observance'] as double? ?? 0.0;
    Color obsColor = observance >= 0.8
        ? AppColors.primaryGreen
        : observance >= 0.5
        ? const Color(0xFFFFA726)
        : AppColors.grey;

    final String subtitle = _buildPatientSubtitle(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                  child: Text(
                    (patient['name'] as String).isNotEmpty
                        ? (patient['name'] as String).substring(0, 1)
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: observance,
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(obsColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            observance > 0
                                ? '${(observance * 100).toInt()}%'
                                : 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: obsColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Allergies au lieu de meds vides
          if ((patient['allergies'] as String?)?.isNotEmpty == true &&
              patient['allergies'] != 'Aucune')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 14,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Allergies: ${patient['allergies']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _scannedPatient = patient;
                        _selectedIndex = 1;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    label: const Text(
                      'Voir détail',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // ✅ patient['id'] = userId Keycloak (après correction viewmodel)
                      AppRoutes.navigateToAddMedicine(
                        context,
                        patientId: patient['id'] as String,
                        patientName: patient['name'] as String,
                        patientAge: patient['age'] as int? ?? 0,
                        patientSex: patient['sex'] as String? ?? 'Male',
                        allergies: patient['allergies'] as String? ?? 'Aucune',
                        isPregnant: patient['pregnant'] as bool? ?? false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text(
                      'Planifier',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TRAITEMENTS TAB ───────────────────────────────────────────────────────
  Widget _buildTraitementsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Traitements & Recommandation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gérez les traitements de vos patients',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 32),

          // Bouton Recommandation
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 44,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Système de recommandation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'À développer',
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommandationPharmacienScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Accéder à la Recommandation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROFIL TAB ────────────────────────────────────────────────────────────
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, Color(0xFF6580F5)],
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  context.watch<AuthViewModel>().currentUser?.fullName ??
                      'Pharmacien',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.watch<AuthViewModel>().currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '💊 Pharmacien',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfilSection('Informations professionnelles', [
                  _buildProfilItem(
                    Icons.person_outline,
                    'Nom complet',
                    context.watch<AuthViewModel>().currentUser?.fullName ?? '',
                  ),
                  _buildProfilItem(
                    Icons.badge_outlined,
                    'N° Ordre',
                    'PHARM-2024-001',
                  ),
                  _buildProfilItem(
                    Icons.star_outline,
                    'Spécialité',
                    'Pharmacie clinique',
                  ),
                  _buildProfilItem(
                    Icons.phone_outlined,
                    'Téléphone',
                    context.watch<AuthViewModel>().currentUser?.telephone ??
                        '+216 XX XXX XXX',
                  ),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilSection(String title, List<Widget> items) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfilItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
        ],
      ),
    );
  }

  // ─── DIALOGS ───────────────────────────────────────────────────────────────
  void _showPlanifierDialog(Map<String, dynamic> patient) {
    final medController = TextEditingController();
    final heureController = TextEditingController();
    final doseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Planifier pour ${(patient['name'] as String).split(' ').first}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: medController,
              decoration: InputDecoration(
                hintText: 'Médicament',
                prefixIcon: const Icon(
                  Icons.medication_outlined,
                  color: AppColors.primaryGreen,
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: doseController,
              decoration: InputDecoration(
                hintText: 'Posologie (ex: 1 comprimé)',
                prefixIcon: const Icon(
                  Icons.science_outlined,
                  color: AppColors.primaryGreen,
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: heureController,
              decoration: InputDecoration(
                hintText: 'Heure de prise (ex: 08:00)',
                prefixIcon: const Icon(
                  Icons.access_time,
                  color: AppColors.primaryGreen,
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Traitement planifié pour ${patient['name']}',
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmer la planification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PAGE RECOMMANDATION PHARMACIEN (à développer) ─────────────────────────────
class RecommandationPharmacienScreen extends StatelessWidget {
  const RecommandationPharmacienScreen({super.key});

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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 44,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Système de recommandation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'À développer',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retour',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
}
