import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  // ── Données profil depuis le backend ──────────────────────────────────────
  String _firstName  = '';
  String _lastName   = '';
  String _email      = '';
  String _phone      = '';
  bool   _loadingProfile = true;

  // ── Allergies depuis le backend ───────────────────────────────────────────
  List<dynamic> _allergies = [];

  // ── Médicaments (simulés pour Sprint 1, à remplacer Sprint 2) ────────────
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D',
      'dose': '1 Capsule, 1000mg',
      'time': '09:41',
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
    {
      'name': 'Aspirine 100mg',
      'dose': '1 Comprimé, matin',
      'time': '08:00',
      'color': const Color(0xFF4CAF50),
      'taken': false,
      'date': DateTime.now().add(const Duration(days: 1)),
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.person_outline, 'label': 'Profil'},
    {'icon': Icons.medication_outlined, 'label': 'Médicaments'},
    {'icon': Icons.assignment_outlined, 'label': 'Planning'},
    {'icon': Icons.medical_services_outlined, 'label': 'Recommandation'},
    {'icon': Icons.family_restroom, 'label': 'Proche', 'badge': 'Nouveau'},
  ];

  // ── Proches (simulés Sprint 1) ────────────────────────────────────────────
  final List<Map<String, dynamic>> _familyMembers = [
    {
      'name': 'Youssef',
      'role': 'Père',
      'avatar': '👴',
      'status': 'À surveiller',
      'nextMed': 'Aspégic 100mg - 18:00',
      'color': const Color(0xFF4361EE),
    },
    {
      'name': 'Fatima',
      'role': 'Mère',
      'avatar': '👵',
      'status': 'Observant',
      'nextMed': 'Tardyféron - 20:00',
      'color': const Color(0xFFFF6B6B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Chargement des données depuis le backend ──────────────────────────────
  Future<void> _loadData() async {
    setState(() => _loadingProfile = true);
    try {
      // 1. Charger le profil
      final profile = await ApiService.getMyProfile();
      if (profile != null && mounted) {
        setState(() {
          _firstName = profile['firstName'] ?? '';
          _lastName  = profile['lastName']  ?? '';
          _email     = profile['email']     ?? '';
          _phone     = profile['phoneNumber'] ?? '';
        });
      }

      // 2. Charger les allergies
      final allergies = await ApiService.getAllergies();
      if (mounted) {
        setState(() => _allergies = allergies);
      }
    } catch (e) {
      debugPrint('_loadData error: $e');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String get _fullName {
    final name = '$_firstName $_lastName'.trim();
    return name.isEmpty ? 'Patient' : name;
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
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

  // ─── HOME TAB ──────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  ..._medications
                      .where((med) =>
                          (med['date'] as DateTime).day == DateTime.now().day &&
                          (med['date'] as DateTime).month ==
                              DateTime.now().month)
                      .map((med) => _buildPlanningMedItem(med)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header avec vrai nom ──────────────────────────────────────────────────
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
                  const Row(
                    children: [
                      Text('👋 ', style: TextStyle(fontSize: 16)),
                      Text(
                        'Bonjour !',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // ← VRAI NOM depuis le backend
                  _loadingProfile
                      ? const SizedBox(
                          width: 140,
                          height: 20,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _fullName,
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
    final today = _medications.where((m) {
      final d = m['date'] as DateTime;
      return d.day == DateTime.now().day && !(m['taken'] as bool);
    }).toList();

    final nextMed = today.isNotEmpty ? today.first : _medications.first;

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
          const Row(
            children: [
              Icon(Icons.alarm, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Prochain médicament',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nextMed['name'] as String,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextMed['time']} · ${nextMed['dose']}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prise confirmée !'),
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Confirmer la prise',
                style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Services ──────────────────────────────────────────────────────────────
  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
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
    final isProfil = service['label'] == 'Profil';

    return GestureDetector(
      onTap: () {
        if (isProche)  _showFamilyMembersDialog();
        if (isProfil)  setState(() => _selectedIndex = 4);
        if (isReco)    _showComingSoon('Recommandation');
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isProche
                      ? const Color(0xFFFF6B6B)
                      : (isReco
                          ? AppColors.primaryBlue
                          : AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(service['icon'] as IconData,
                    color: Colors.white, size: 28),
              ),
              if (service.containsKey('badge'))
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      service['badge'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            service['label'] as String,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — disponible au Sprint 2'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  // ── Section Proches ────────────────────────────────────────────────────────
  Widget _buildFamilySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('👨‍👩‍👧‍👦 Mes proches',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              TextButton(
                onPressed: _showFamilyMembersDialog,
                child: const Text('Voir tout',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) =>
                  _buildFamilyMemberCard(_familyMembers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(Map<String, dynamic> member) {
    Color statusColor = member['status'] == 'Observant'
        ? AppColors.primaryGreen
        : member['status'] == 'À surveiller'
            ? const Color(0xFFFFA726)
            : AppColors.errorRed;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (member['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(member['avatar'] as String,
                    style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(member['name'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black)),
                Text(member['role'] as String,
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.grey)),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member['status'] as String,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFamilyMembersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('👨‍👩‍👧‍👦 Mes proches',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 8),
            const Text('Suivez les prises de médicaments de vos proches',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 20),
            ..._familyMembers.map((m) => _buildFamilyMemberDetail(m)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Ajouter un proche',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberDetail(Map<String, dynamic> member) {
    final statusColor = member['status'] == 'Observant'
        ? AppColors.primaryGreen
        : member['status'] == 'À surveiller'
            ? const Color(0xFFFFA726)
            : AppColors.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (member['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(member['avatar'] as String,
                    style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member['name'] as String,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black)),
                    const SizedBox(width: 8),
                    Text('· ${member['role']}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(member['status'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Prochaine prise: ${member['nextMed']}',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }

  // ─── CALENDRIER ────────────────────────────────────────────────────────────
  Widget _buildAdaptiveCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📅 Calendrier',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () => setState(() => _currentMonth =
                        DateTime(_currentMonth.year,
                            _currentMonth.month - 1, 1)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(_getMonthYear(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen)),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () => setState(() => _currentMonth =
                        DateTime(_currentMonth.year,
                            _currentMonth.month + 1, 1)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Expanded(
                      child: Text(day,
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
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _getDaysInMonthGrid(),
            itemBuilder: (context, index) => _buildCalendarDay(index),
          ),
        ],
      ),
    );
  }

  int _getDaysInMonthGrid() {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = first.weekday == 7 ? 0 : first.weekday;
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    return offset + daysInMonth;
  }

  Widget _buildCalendarDay(int index) {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = first.weekday == 7 ? 0 : first.weekday;
    final dayNumber = index - offset + 1;

    if (dayNumber < 1) return const SizedBox();

    final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
    final isSelected = date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;
    final hasMed = _medications.any((m) {
      final d = m['date'] as DateTime;
      return d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    });
    final pendingMeds = _medications.where((m) {
      final d = m['date'] as DateTime;
      return d.year == date.year &&
          d.month == date.month &&
          d.day == date.day &&
          !(m['taken'] as bool);
    }).length;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
        _showMedicationsForDate(date);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : isToday
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primaryGreen, width: 1.5)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.black,
                ),
              ),
            ),
            if (hasMed)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: pendingMeds > 0
                        ? AppColors.errorRed
                        : AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMedicationsForDate(DateTime date) {
    final meds = _medications.where((m) {
      final d = m['date'] as DateTime;
      return d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('📅 ${_formatDate(date)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 16),
            if (meds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun médicament programmé',
                      style: TextStyle(color: AppColors.grey)),
                ),
              )
            else
              ...meds.map((m) => _buildCalendarMedItem(m)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarMedItem(Map<String, dynamic> med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (med['color'] as Color).withOpacity(0.1),
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
          Text(
            (med['taken'] as bool) ? '✓ Pris' : '⏳ ${med['time']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: (med['taken'] as bool)
                  ? AppColors.primaryGreen
                  : const Color(0xFFFFA726),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PLANNING TAB ──────────────────────────────────────────────────────────
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
          _buildAdaptiveCalendar(),
          const SizedBox(height: 24),
          const Text('Médicaments programmés',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          ..._medications.map((m) => _buildPlanningMedItem(m)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showAddMedDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Planifier un médicament',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningMedItem(Map<String, dynamic> med) {
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
              color: taken
                  ? AppColors.primaryGreen.withOpacity(0.12)
                  : AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_outlined,
                color:
                    taken ? AppColors.primaryGreen : AppColors.primaryBlue,
                size: 22),
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
                          : const Color(0xFFFFA726)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMedDialog() {
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
              const Text('Planifier un médicament',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              const SizedBox(height: 20),
              _dialogField('Nom du médicament', Icons.medication_outlined),
              const SizedBox(height: 12),
              _dialogField('Heure de prise (ex: 08:00)', Icons.access_time),
              const SizedBox(height: 12),
              _dialogField('Dosage (ex: 1 comprimé)', Icons.info_outline),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer',
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

  // ─── HISTORIQUE TAB ────────────────────────────────────────────────────────
  Widget _buildHistoriqueTab() {
    final history = [
      {'date': "Aujourd'hui", 'meds': 2, 'total': 3, 'pct': 0.67},
      {'date': 'Hier', 'meds': 3, 'total': 3, 'pct': 1.0},
      {'date': '10 Fév', 'meds': 1, 'total': 3, 'pct': 0.33},
      {'date': '09 Fév', 'meds': 3, 'total': 3, 'pct': 1.0},
    ];

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
                _buildStatItem(
                    '42', 'Prises\neffectuées', AppColors.primaryBlue),
                _buildStatItem('8', 'Prises\nmanquées', AppColors.errorRed),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Détail par jour',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          ...history.map((h) => _buildHistoryItem(h)),
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

  Widget _buildHistoryItem(Map<String, dynamic> h) {
    final pct = h['pct'] as double;
    final color = pct == 1.0
        ? AppColors.primaryGreen
        : pct >= 0.5
            ? const Color(0xFFFFA726)
            : AppColors.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(
                pct == 1.0 ? Icons.check_circle_outline : Icons.info_outline,
                color: color,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h['date'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.black)),
                Text('${h['meds']} sur ${h['total']} prises effectuées',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Text('${(pct * 100).toInt()}%',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  // ─── NOTIFICATIONS TAB ─────────────────────────────────────────────────────
  Widget _buildNotificationsTab() {
    final notifs = [
      {
        'title': 'Rappel médicament',
        'body': "Il est l'heure de prendre Metformine 500mg",
        'time': 'Il y a 5 min',
        'icon': Icons.alarm,
        'color': AppColors.primaryGreen,
        'read': false,
      },
      {
        'title': "Proche – Youssef",
        'body': "Aspégic 100mg n'a pas été confirmée",
        'time': 'Il y a 35 min',
        'icon': Icons.warning_amber_outlined,
        'color': AppColors.errorRed,
        'read': false,
      },
      {
        'title': 'Prise confirmée',
        'body': 'Vitamin D 1000UI confirmée avec succès',
        'time': 'Ce matin à 08:00',
        'icon': Icons.check_circle_outline,
        'color': AppColors.primaryBlue,
        'read': true,
      },
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
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              TextButton(
                onPressed: () {},
                child: const Text('Tout lire',
                    style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600)),
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
        color:
            read ? Colors.white : (n['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: read
            ? null
            : Border.all(color: (n['color'] as Color).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: (n['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(n['icon'] as IconData,
                color: n['color'] as Color, size: 22),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.black)),
                    if (!read)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: n['color'] as Color,
                              shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n['body'] as String,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey)),
                const SizedBox(height: 4),
                Text(n['time'] as String,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROFIL TAB — données réelles ─────────────────────────────────────────
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
                colors: [AppColors.primaryGreen, Color(0xFF00C9B4)],
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
                    : Text(
                        _fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
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
                _buildProfileSection('Informations personnelles', [
                  _buildProfileItem(
                      Icons.person_outline, 'Nom complet', _fullName),
                  _buildProfileItem(
                      Icons.email_outlined, 'Email', _email.isEmpty ? '—' : _email),
                  _buildProfileItem(Icons.phone_outlined, 'Téléphone',
                      _phone.isEmpty ? '—' : _phone),
                ]),
                const SizedBox(height: 16),
                // ← VRAIES ALLERGIES depuis le backend
                _buildProfileSection(
                  'Allergies (${_allergies.length})',
                  _allergies.isEmpty
                      ? [
                          _buildProfileItem(Icons.check_circle_outline,
                              'Statut', 'Aucune allergie enregistrée')
                        ]
                      : _allergies
                          .map((a) => _buildProfileItem(
                              Icons.warning_amber_outlined,
                              a['substanceName'] ?? '',
                              a['severity'] ?? ''))
                          .toList(),
                ),
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _getMonthYear() {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

void _avatarFallback(Object exception, StackTrace? stackTrace) {}

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