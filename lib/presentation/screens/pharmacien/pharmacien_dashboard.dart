import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class PharmacienDashboard extends StatefulWidget {
  const PharmacienDashboard({super.key});

  @override
  State<PharmacienDashboard> createState() => _PharmacienDashboardState();
}

class _PharmacienDashboardState extends State<PharmacienDashboard> {
  int _selectedIndex = 0;

  // ── Profil pharmacien depuis le backend ───────────────────────────────────
  String _firstName      = '';
  String _lastName       = '';
  String _email          = '';
  String _phone          = '';
  bool   _loadingProfile = true;

  // ── Liste patients depuis le backend ──────────────────────────────────────
  List<dynamic> _patients     = [];
  bool          _loadingPatients = true;

  String _searchQuery = '';
  Map<String, dynamic>? _scannedPatient;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loadingProfile  = true;
      _loadingPatients = true;
    });

    // Charger profil + patients en parallèle
    final results = await Future.wait([
      ApiService.getMyProfile(),
      ApiService.getPatients(),
    ]);

    if (!mounted) return;

    // Profil
    final profile = results[0] as Map<String, dynamic>?;
    if (profile != null) {
      setState(() {
        _firstName = profile['firstName'] ?? '';
        _lastName  = profile['lastName']  ?? '';
        _email     = profile['email']     ?? '';
        _phone     = profile['phoneNumber'] ?? '';
      });
    }

    // Patients
    final patients = results[1] as List<dynamic>;
    setState(() {
      _patients        = patients;
      _loadingProfile  = false;
      _loadingPatients = false;
    });
  }

  String get _fullName {
    final name = '$_firstName $_lastName'.trim();
    return name.isEmpty ? 'Pharmacien' : name;
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  // ── Patients filtrés par la recherche ─────────────────────────────────────
  List<dynamic> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((p) {
      final name =
          '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.toLowerCase();
      final email = (p['email'] ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
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
              offset: const Offset(0, -3))
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
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: items
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e['icon'] as IconData),
                  label: e['label'] as String,
                ))
            .toList(),
      ),
    );
  }

  // ─── ACCUEIL TAB ───────────────────────────────────────────────────────────
  Widget _buildAccueilTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  const Text('Actions rapides',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black)),
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
                                  const RecommandationPharmacienScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Patients récents',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black)),
                      GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 2),
                        child: const Text('Voir tous',
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _loadingPatients
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: AppColors.primaryBlue),
                          ),
                        )
                      : _patients.isEmpty
                          ? _buildEmptyPatients()
                          : Column(
                              children: _patients
                                  .take(2)
                                  .map((p) => _buildPatientCard(p))
                                  .toList(),
                            ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPatients() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 48, color: AppColors.primaryBlue.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('Aucun patient pour le moment',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('Les patients apparaîtront ici après inscription',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── Header avec vrai nom ──────────────────────────────────────────────────
  Widget _buildPharmacienHeader() {
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
              const Text('Bonjour 👋',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 2),
              // ← VRAI NOM
              _loadingProfile
                  ? const SizedBox(
                      width: 160,
                      height: 20,
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.white24,
                          color: Colors.white),
                    )
                  : Text(
                      _fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 2),
              const Text('Pharmacien',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
            _loadingPatients ? '...' : '${_patients.length}',
            'Patients',
            AppColors.primaryBlue),
        const SizedBox(width: 10),
        _buildStatCard(
            _loadingPatients ? '...' : '${_patients.length}',
            'Planif. actives',
            AppColors.primaryGreen),
        const SizedBox(width: 10),
        _buildStatCard('0', 'En attente', AppColors.grey),
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
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card patient ──────────────────────────────────────────────────────────
  Widget _buildPatientCard(dynamic patient) {
    final firstName = patient['firstName'] ?? '';
    final lastName  = patient['lastName']  ?? '';
    final email     = patient['email']     ?? '';
    final fullName  = '$firstName $lastName'.trim();
    final initial   = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
          child: Text(initial,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        title: Text(
          fullName.isEmpty ? email : fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Patient',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600)),
        ),
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
          const Text('Scanner QR Code',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Sélectionnez un patient pour accéder à son profil',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 24),
          _buildScanArea(),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('ou sélectionner un patient',
                    style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          _loadingPatients
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue))
              : _patients.isEmpty
                  ? _buildEmptyPatients()
                  : Column(
                      children: _patients
                          .map((p) => _buildScanPatientItem(p))
                          .toList(),
                    ),
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
            color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.qr_code_2,
                size: 80, color: AppColors.primaryBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          const Text('Pointez vers le QR Code du patient',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Du bracelet ou de son profil',
              style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_patients.isNotEmpty) {
                  setState(() => _scannedPatient = _patients[0]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code scanné avec succès !'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              label: const Text('Activer la caméra',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanPatientItem(dynamic patient) {
    final firstName = patient['firstName'] ?? '';
    final lastName  = patient['lastName']  ?? '';
    final email     = patient['email']     ?? '';
    final fullName  = '$firstName $lastName'.trim();
    final initial   = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final isSelected = _scannedPatient?['email'] == email;

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
              child: Text(initial,
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName.isEmpty ? email : fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.black)),
                  Text(email,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                ],
              ),
            ),
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
    final patient   = _scannedPatient!;
    final firstName = patient['firstName'] ?? '';
    final lastName  = patient['lastName']  ?? '';
    final email     = patient['email']     ?? '';
    final fullName  = '$firstName $lastName'.trim();
    final initial   = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, Color(0xFF6580F5)]),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName.isEmpty ? email : fullName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('● Patient',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPlanifierDialog(patient),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('+ Planifier prise',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const RecommandationPharmacienScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('🩺 Recommandation',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
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

  // ─── PATIENTS TAB ──────────────────────────────────────────────────────────
  Widget _buildPatientsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes Patients (${_patients.length})',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                onPressed: _loadData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Rechercher un patient...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.primaryBlue),
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
            child: _loadingPatients
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue))
                : _filteredPatients.isEmpty
                    ? _buildEmptyPatients()
                    : ListView(
                        children: _filteredPatients
                            .map((p) => _buildDetailedPatientCard(p))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPatientCard(dynamic patient) {
    final firstName = patient['firstName'] ?? '';
    final lastName  = patient['lastName']  ?? '';
    final email     = patient['email']     ?? '';
    final phone     = patient['phoneNumber'] ?? '';
    final fullName  = '$firstName $lastName'.trim();
    final initial   = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2))
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
                  child: Text(initial,
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isEmpty ? email : fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.black)),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey)),
                      if (phone.isNotEmpty)
                        Text(phone,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Patient',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _scannedPatient = patient;
                        _selectedIndex  = 1;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.visibility_outlined,
                        size: 16, color: AppColors.primaryBlue),
                    label: const Text('Voir détail',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPlanifierDialog(patient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon:
                        const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Planifier',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
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
          const Text('Traitements & Recommandation',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Gérez les traitements de vos patients',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 32),
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
                  child: const Icon(Icons.medical_services_outlined,
                      size: 44, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 20),
                const Text('Système de recommandation',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black)),
                const SizedBox(height: 8),
                const Text('Disponible au Sprint 2',
                    style: TextStyle(fontSize: 13, color: AppColors.grey)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const RecommandationPharmacienScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.medical_services_outlined,
                        color: Colors.white),
                    label: const Text('Accéder à la Recommandation',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
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
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 14),
                // ← VRAI NOM
                _loadingProfile
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // ← VRAI EMAIL
                Text(_email.isEmpty ? '—' : _email,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('💊 Pharmacien',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfilSection('Informations professionnelles', [
                  _buildProfilItem(Icons.person_outline, 'Nom complet', _fullName),
                  _buildProfilItem(Icons.email_outlined, 'Email',
                      _email.isEmpty ? '—' : _email),
                  _buildProfilItem(Icons.phone_outlined, 'Téléphone',
                      _phone.isEmpty ? '—' : _phone),
                  _buildProfilItem(Icons.people_outline, 'Patients suivis',
                      '${_patients.length} patient(s)'),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text('Se déconnecter',
                        style: TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold)),
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
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
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppColors.grey),
        ],
      ),
    );
  }

  // ─── DIALOG PLANIFIER ──────────────────────────────────────────────────────
  void _showPlanifierDialog(dynamic patient) {
    final firstName = patient['firstName'] ?? '';
    final lastName  = patient['lastName']  ?? '';
    final name      = '$firstName $lastName'.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month,
                      color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Planifier pour ${name.isEmpty ? 'le patient' : name.split(' ').first}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _dialogField('Médicament', Icons.medication_outlined),
              const SizedBox(height: 10),
              _dialogField(
                  'Posologie (ex: 1 comprimé)', Icons.science_outlined),
              const SizedBox(height: 10),
              _dialogField('Heure de prise (ex: 08:00)', Icons.access_time),
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
                            'Traitement planifié pour ${name.isEmpty ? 'le patient' : name}'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirmer la planification',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }
}

// ── Page Recommandation Pharmacien ───────────────────────────────────────────
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
              child: const Icon(Icons.medical_services_outlined,
                  size: 44, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text('Système de recommandation',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 8),
            const Text('Disponible au Sprint 2',
                style: TextStyle(fontSize: 14, color: AppColors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retour',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}