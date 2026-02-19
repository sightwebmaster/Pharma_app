import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;

  // ── DONNÉES RÉELLES depuis l'API ──────────────────────────────────────────
  Map<String, dynamic>? _userProfile;
  List<dynamic> _allergies = [];
  bool _isLoadingProfile = true;

  // ── DONNÉES UI (médicaments simulés pour Sprint 1) ────────────────────────
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D',
      'dose': '1 Capsule, 1000mg',
      'time': '09:00',
      'color': const Color(0xFFFFA726),
      'taken': false,
      'date': DateTime.now(),
    },
    {
      'name': 'Metformine 500mg',
      'dose': '1 Comprimé, avec repas',
      'time': '12:00',
      'color': const Color(0xFF4361EE),
      'taken': true,
      'date': DateTime.now(),
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await ApiService.getMyProfile();
      final allergies = await ApiService.getAllergies();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _allergies = allergies;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String get _displayName {
    if (_userProfile == null) return 'Chargement...';
    final first = _userProfile!['firstName'] ?? '';
    final last = _userProfile!['lastName'] ?? '';
    if (first.isEmpty && last.isEmpty) return 'Utilisateur';
    return '$first $last'.trim();
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
            _buildHomeTab(),
            _buildPlanningTab(),
            _buildHistoriqueTab(),
            _buildNotificationsTab(),
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

  // ── HOME TAB ──────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCalendar(),
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
                ..._medications
                    .where((med) =>
                        (med['date'] as DateTime).day == DateTime.now().day)
                    .map((med) => _buildMedItem(med)),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '👋 Bonjour!',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 4),
              _isLoadingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ── CALENDRIER ────────────────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📅 Calendrier',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () => setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month - 1, 1);
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _monthYear,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () => setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month + 1, 1);
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1),
            itemCount: _daysInGrid,
            itemBuilder: (_, i) => _buildCalendarDay(i),
          ),
        ],
      ),
    );
  }

  int get _daysInGrid {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = first.weekday == 7 ? 0 : first.weekday;
    final days = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    return offset + days;
  }

  Widget _buildCalendarDay(int index) {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = first.weekday == 7 ? 0 : first.weekday;
    final dayNum = index - offset + 1;

    if (dayNum < 1 ||
        dayNum > DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day) {
      return const SizedBox();
    }

    final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
    final isSelected = date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;
    final hasMed = _medications.any((m) {
      final d = m['date'] as DateTime;
      return d.day == date.day && d.month == date.month && d.year == date.year;
    });

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : isToday
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primaryGreen, width: 1.5)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.black,
                ),
              ),
            ),
            if (hasMed)
              Positioned(
                bottom: 3,
                right: 3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _monthYear {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  // ── MED ITEM ──────────────────────────────────────────────────────────────
  Widget _buildMedItem(Map<String, dynamic> med) {
    final taken = med['taken'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: taken
              ? AppColors.primaryGreen.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (med['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_outlined,
                color: med['color'] as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.black)),
                Text(med['dose'] as String,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(med['time'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.black)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: taken
                      ? AppColors.primaryGreen.withOpacity(0.12)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  taken ? '✓ Pris' : '⏳ En attente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: taken
                        ? AppColors.primaryGreen
                        : const Color(0xFFFFA726),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PLANNING TAB ──────────────────────────────────────────────────────────
  Widget _buildPlanningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Mon Planning',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Suivi de vos prises de médicaments',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 24),
          _buildCalendar(),
          const SizedBox(height: 24),
          const Text('Tous les médicaments',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          ..._medications.map((med) => _buildMedItem(med)),
        ],
      ),
    );
  }

  // ── HISTORIQUE TAB ────────────────────────────────────────────────────────
  Widget _buildHistoriqueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Historique',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
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
                _buildStatItem('85%', 'Observance\nglobale',
                    AppColors.primaryGreen),
                _buildStatItem('42', 'Prises\neffectuées',
                    AppColors.primaryBlue),
                _buildStatItem('8', 'Prises\nmanquées', AppColors.errorRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }

  // ── NOTIFICATIONS TAB ─────────────────────────────────────────────────────
  Widget _buildNotificationsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_outlined,
              size: 60, color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text('Aucune notification',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          SizedBox(height: 8),
          Text('Disponible Sprint 3',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      ),
    );
  }

  // ── PROFIL TAB ────────────────────────────────────────────────────────────
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryGreen, Color(0xFF00C9B4)],
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
                    GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
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
                  child: const Text('🩺 Patient',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Infos personnelles
                _buildProfileSection('Informations personnelles', [
                  _buildProfileItem(Icons.person_outline, 'Nom complet',
                      _displayName),
                  _buildProfileItem(
                      Icons.email_outlined, 'Email', _displayEmail),
                  _buildProfileItem(
                      Icons.phone_outlined,
                      'Téléphone',
                      _userProfile?['phoneNumber'] ?? 'Non renseigné'),
                ]),
                const SizedBox(height: 16),

                // Allergies
                _buildProfileSection(
                    'Allergies (${_allergies.length})',
                    _allergies.isEmpty
                        ? [
                            _buildProfileItem(Icons.info_outline,
                                'Aucune allergie', 'enregistrée')
                          ]
                        : _allergies
                            .map((a) => _buildProfileItem(
                                Icons.warning_amber_outlined,
                                a['substanceName'] ?? '',
                                a['severity'] ?? ''))
                            .toList()),
                const SizedBox(height: 16),

                // Bouton ajouter allergie
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _showAddAllergyDialog,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add,
                        color: AppColors.primaryGreen),
                    label: const Text('Ajouter une allergie',
                        style: TextStyle(color: AppColors.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 16),

                // Déconnexion
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

  Widget _buildProfileSection(String title, List<Widget> items) {
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
                    color: AppColors.primaryGreen)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
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

  // ── DIALOGS ───────────────────────────────────────────────────────────────
  void _showEditProfileDialog() {
    final firstController = TextEditingController(
        text: _userProfile?['firstName'] ?? '');
    final lastController = TextEditingController(
        text: _userProfile?['lastName'] ?? '');
    final phoneController = TextEditingController(
        text: _userProfile?['phoneNumber'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modifier mon profil',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              const SizedBox(height: 20),
              TextField(
                controller: firstController,
                decoration: _inputDeco('Prénom', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastController,
                decoration: _inputDeco('Nom', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco('Téléphone', Icons.phone_outlined),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await ApiService.updateProfile(
                      firstName: firstController.text,
                      lastName: lastController.text,
                      phoneNumber: phoneController.text,
                    );
                    if (ok && mounted) {
                      await _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil mis à jour !'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAllergyDialog() {
    final nameController = TextEditingController();
    String selectedSeverity = 'MILD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter une allergie',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: _inputDeco(
                      'Nom de la substance', Icons.warning_amber_outlined),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  decoration: _inputDeco('Sévérité', Icons.info_outline),
                  items: const [
                    DropdownMenuItem(value: 'MILD', child: Text('Légère')),
                    DropdownMenuItem(
                        value: 'MODERATE', child: Text('Modérée')),
                    DropdownMenuItem(value: 'SEVERE', child: Text('Sévère')),
                  ],
                  onChanged: (v) =>
                      setModalState(() => selectedSeverity = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;
                      Navigator.pop(ctx);
                      final ok = await ApiService.addAllergy(
                        substanceName: nameController.text,
                        severity: selectedSeverity,
                      );
                      if (ok && mounted) {
                        await _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Allergie ajoutée !'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ajouter',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryGreen),
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
