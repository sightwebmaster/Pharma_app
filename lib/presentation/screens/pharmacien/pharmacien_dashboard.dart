import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class PharmacienDashboard extends StatefulWidget {
  const PharmacienDashboard({super.key});

  @override
  State<PharmacienDashboard> createState() => _PharmacienDashboardState();
}

class _PharmacienDashboardState extends State<PharmacienDashboard> {
  int _selectedIndex = 0;

  // ── DONNÉES RÉELLES ───────────────────────────────────────────────────────
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  // ── DONNÉES SIMULÉES (Sprint 1) ───────────────────────────────────────────
  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'Youssef Ben Ali',
      'age': 64,
      'maladie': 'Diabète type 2',
      'observance': 0.67,
      'meds': ['Metformine 500mg', 'Aspégic 100mg'],
    },
    {
      'name': 'Fatma Mansouri',
      'age': 58,
      'maladie': 'Hypertension',
      'observance': 0.92,
      'meds': ['Atorvastatine 20mg', 'Vitamine D3'],
    },
    {
      'name': 'Karim Saidi',
      'age': 45,
      'maladie': 'Diabète type 1',
      'observance': 0.80,
      'meds': ['Insuline rapide', 'Metformine 850mg'],
    },
  ];

  String _searchQuery = '';

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await ApiService.getMyProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String get _displayName {
    if (_userProfile == null) return 'Dr. ...';
    final first = _userProfile!['firstName'] ?? '';
    final last = _userProfile!['lastName'] ?? '';
    if (first.isEmpty && last.isEmpty) return 'Pharmacien';
    return 'Dr. $first $last'.trim();
  }

  String get _displayEmail {
    return _userProfile?['email'] ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildAccueilTab(),
            _buildPatientsTab(),
            _buildProfilTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_filled, 'label': 'Accueil'},
      {'icon': Icons.people_outline, 'label': 'Patients'},
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

  // ── ACCUEIL TAB ───────────────────────────────────────────────────────────
  Widget _buildAccueilTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Row(
                  children: [
                    _buildStatCard('${_patients.length}', 'Patients',
                        AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    _buildStatCard('${_patients.length}', 'Planif. actives',
                        AppColors.primaryGreen),
                    const SizedBox(width: 10),
                    _buildStatCard('0', 'En attente', AppColors.grey),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Patients récents',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black)),
                const SizedBox(height: 12),
                ..._patients.take(2).map((p) => _buildPatientCard(p)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: const Text('Voir tous les patients →',
                        style: TextStyle(
                            color: AppColors.primaryBlue,
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

  Widget _buildHeader() {
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
              _isLoadingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(_displayName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              const Text('Pharmacien',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 26),
          ),
        ],
      ),
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
                style:
                    const TextStyle(fontSize: 10, color: AppColors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final observance = patient['observance'] as double;
    final obsColor = observance >= 0.8
        ? AppColors.primaryGreen
        : observance >= 0.5
            ? const Color(0xFFFFA726)
            : AppColors.errorRed;

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
          child: Text(
            (patient['name'] as String).substring(0, 1),
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        title: Text(patient['name'] as String,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${patient['age']} ans · ${patient['maladie']}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${(observance * 100).toInt()}%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: obsColor)),
            const Text('observance',
                style: TextStyle(fontSize: 10, color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  // ── PATIENTS TAB ──────────────────────────────────────────────────────────
  Widget _buildPatientsTab() {
    final filtered = _patients
        .where((p) => (p['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Mes Patients',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un patient...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.primaryBlue),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: filtered.map((p) => _buildPatientCard(p)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROFIL TAB ────────────────────────────────────────────────────────────
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
                Text(_displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_displayEmail,
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
                _buildPharmaSection('Informations professionnelles', [
                  _buildPharmaItem(
                      Icons.person_outline, 'Nom complet', _displayName),
                  _buildPharmaItem(
                      Icons.email_outlined, 'Email', _displayEmail),
                  _buildPharmaItem(Icons.phone_outlined, 'Téléphone',
                      _userProfile?['phoneNumber'] ?? 'Non renseigné'),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
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

  Widget _buildPharmaSection(String title, List<Widget> items) {
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

  Widget _buildPharmaItem(IconData icon, String label, String value) {
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
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
