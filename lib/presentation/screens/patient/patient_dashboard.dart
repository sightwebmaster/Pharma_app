import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  
  // Données simulées
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D',
      'dose': '1 Capsule, 1000mg',
      'time': '09:41',
      'icon': Icons.circle,
      'color': Color(0xFFFFA726),
      'taken': false,
      'date': DateTime.now(),
    },
    {
      'name': 'B12 Drops',
      'dose': '6 Drops, 1200mg',
      'time': '06:13',
      'icon': Icons.circle,
      'color': Color(0xFFFFA726),
      'taken': false,
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'name': 'Metformine 500mg',
      'dose': '1 Comprimé, avec repas',
      'time': '12:00',
      'icon': Icons.circle,
      'color': Color(0xFF4361EE),
      'taken': true,
      'date': DateTime.now(),
    },
    {
      'name': 'Aspirine 100mg',
      'dose': '1 Comprimé, matin',
      'time': '08:00',
      'icon': Icons.circle,
      'color': Color(0xFF4CAF50),
      'taken': false,
      'date': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'name': 'Oméprazole 20mg',
      'dose': '1 Gélule, avant repas',
      'time': '07:30',
      'icon': Icons.circle,
      'color': Color(0xFF9C27B0),
      'taken': true,
      'date': DateTime.now().add(const Duration(days: 2)),
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.person_outline, 'label': 'Profil'},
    {'icon': Icons.medication_outlined, 'label': 'Médicaments'},
    {'icon': Icons.assignment_outlined, 'label': 'Planning'},
    {'icon': Icons.medical_services_outlined, 'label': 'Recommandation'},
    {'icon': Icons.family_restroom, 'label': 'Proche', 'badge': 'Nouveau'},
  ];

  final List<Map<String, dynamic>> _familyMembers = [
    {
      'name': 'Youssef',
      'role': 'Père',
      'avatar': '👴',
      'status': 'À surveiller',
      'nextMed': 'Aspégic 100mg - 18:00',
      'color': Color(0xFF4361EE),
    },
    {
      'name': 'Fatima',
      'role': 'Mère',
      'avatar': '👵',
      'status': 'Observant',
      'nextMed': 'Tardyféron - 20:00',
      'color': Color(0xFFFF6B6B),
    },
    {
      'name': 'Ahmed',
      'role': 'Grand-père',
      'avatar': '👴',
      'status': 'Rappel nécessaire',
      'nextMed': 'Doliprane - 15:30',
      'color': Color(0xFFFFA726),
    },
  ];

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
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildServices(),
          const SizedBox(height: 24),
          _buildFamilySection(), // NOUVEAU : Section Proche
          const SizedBox(height: 24),
          _buildAdaptiveCalendar(), // NOUVEAU : Calendrier adaptatif
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
                        med['date']!.day == DateTime.now().day &&
                        med['date']!.month == DateTime.now().month &&
                        med['date']!.year == DateTime.now().year)
                    .map((med) => _buildPlanningMedItem(med))
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Header avec gradient vert
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
          // Greeting row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('👋 ', style: TextStyle(fontSize: 16)),
                      Text(
                        'Bonjour!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Nom Prénom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/avatar.png'),
                    fit: BoxFit.cover,
                    onError: _avatarFallback,
                  ),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Prochain médicament card
          _buildNextMedCard(),
        ],
      ),
    );
  }

  Widget _buildNextMedCard() {
    final nextMed = _medications.firstWhere(
      (med) => !med['taken'] && med['date']!.day == DateTime.now().day,
      orElse: () => _medications.first,
    );
    
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
          Row(
            children: const [
              Icon(Icons.alarm, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Prochain médicament',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nextMed['name'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextMed['time']} · ${nextMed['dose']}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prise confirmée !'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Confirmer la prise',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Services grid
  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
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
    final isReco = service['label'] == 'Recommandation';
    final isProche = service['label'] == 'Proche';
    
    return GestureDetector(
      onTap: () {
        if (isReco) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RecommandationScreen(),
            ),
          );
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isProche 
                      ? const Color(0xFFFF6B6B)
                      : (isReco ? AppColors.primaryBlue : AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              if (service.containsKey('badge'))
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        fontWeight: FontWeight.bold,
                      ),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // NOUVEAU : Section Proche
  Widget _buildFamilySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '👨‍👩‍👧‍👦 Mes proches',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: _showFamilyMembersDialog,
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                return _buildFamilyMemberCard(member);
              },
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
              color: (member['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member['avatar'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  member['role'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member['status'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '👨‍👩‍👧‍👦 Mes proches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Suivez les prises de médicaments de vos proches',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            ..._familyMembers.map((member) => _buildFamilyMemberDetail(member)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Ajouter un proche',
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

  Widget _buildFamilyMemberDetail(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
              child: Text(
                member['avatar'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${member['role']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: member['status'] == 'Observant'
                            ? AppColors.primaryGreen
                            : member['status'] == 'À surveiller'
                                ? const Color(0xFFFFA726)
                                : AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member['status'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: member['status'] == 'Observant'
                            ? AppColors.primaryGreen
                            : member['status'] == 'À surveiller'
                                ? const Color(0xFFFFA726)
                                : AppColors.errorRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Prochaine prise: ${member['nextMed']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.grey),
            onPressed: () {
              Navigator.pop(context);
              // Navigation vers le détail du proche
            },
          ),
        ],
      ),
    );
  }

  // NOUVEAU : Calendrier adaptatif
  Widget _buildAdaptiveCalendar() {
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
                  color: AppColors.black,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMonthYear(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grille du calendrier
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _getDaysInMonthGrid(),
            itemBuilder: (context, index) {
              return _buildCalendarDay(index);
            },
          ),
        ],
      ),
    );
  }

  int _getDaysInMonthGrid() {
    DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int weekday = firstDayOfMonth.weekday;
    // Ajuster pour commencer le lundi (1) au lieu du dimanche (7)
    int offset = weekday == 7 ? 0 : weekday;
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    return offset + daysInMonth;
  }

  Widget _buildCalendarDay(int index) {
    DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int weekday = firstDayOfMonth.weekday;
    int offset = weekday == 7 ? 0 : weekday;
    
    int dayNumber = index - offset + 1;
    DateTime date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
    
    bool isCurrentMonth = date.month == _currentMonth.month;
    bool isSelected = date.day == _selectedDate.day && 
                      date.month == _selectedDate.month && 
                      date.year == _selectedDate.year;
    bool isToday = date.day == DateTime.now().day && 
                   date.month == DateTime.now().month && 
                   date.year == DateTime.now().year;
    
    // Vérifier s'il y a des médicaments ce jour-là
    bool hasMedication = _medications.any((med) => 
      med['date']!.year == date.year &&
      med['date']!.month == date.month &&
      med['date']!.day == date.day
    );
    
    // Compter les médicaments non pris
    int pendingMeds = _medications.where((med) => 
      med['date']!.year == date.year &&
      med['date']!.month == date.month &&
      med['date']!.day == date.day &&
      !med['taken']
    ).length;

    return GestureDetector(
      onTap: isCurrentMonth ? () => _selectDate(date) : null,
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
                isCurrentMonth ? dayNumber.toString() : '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : isCurrentMonth 
                          ? AppColors.black 
                          : AppColors.grey.withOpacity(0.3),
                ),
              ),
            ),
            if (hasMedication && isCurrentMonth)
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
            if (pendingMeds > 0 && isCurrentMonth)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    pendingMeds.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    // Afficher les médicaments du jour sélectionné
    _showMedicationsForDate(date);
  }

  void _showMedicationsForDate(DateTime date) {
    final medsForDate = _medications.where((med) => 
      med['date']!.year == date.year &&
      med['date']!.month == date.month &&
      med['date']!.day == date.day
    ).toList();

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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '📅 ${_formatDate(date)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (medsForDate.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.primaryGreen.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun médicament programmé',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...medsForDate.map((med) => _buildCalendarMedItem(med)),
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
            child: Icon(
              Icons.medication_outlined,
              color: med['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  med['dose'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (med['taken'] as bool)
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  med['time'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: (med['taken'] as bool)
                        ? AppColors.primaryGreen
                        : const Color(0xFFFFA726),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (med['taken'] as bool) ? '✓ Pris' : '⏳ En attente',
                style: TextStyle(
                  fontSize: 10,
                  color: (med['taken'] as bool)
                      ? AppColors.primaryGreen
                      : AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthYear() {
    return '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  // ─── PLANNING TAB ──────────────────────────────────────────────────────────

  Widget _buildPlanningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Mon Planning',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Suivi de vos prises de médicaments',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          _buildAdaptiveCalendar(), // Réutilisation du calendrier adaptatif
          const SizedBox(height: 24),
          const Text(
            'Médicaments programmés',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._medications.map((med) => _buildPlanningMedItem(med)).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showAddMedDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Planifier un médicament',
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
              color: taken
                  ? AppColors.primaryGreen.withOpacity(0.12)
                  : AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: taken ? AppColors.primaryGreen : AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  med['dose'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                med['time'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    color: taken ? AppColors.primaryGreen : const Color(0xFFFFA726),
                  ),
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
            const SizedBox(height: 20),
            const Text(
              'Planifier un médicament',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Nom du médicament',
                prefixIcon: const Icon(Icons.medication_outlined,
                    color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Heure de prise (ex: 08:00)',
                prefixIcon: const Icon(Icons.access_time,
                    color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Dosage (ex: 1 comprimé)',
                prefixIcon: const Icon(Icons.info_outline,
                    color: AppColors.primaryGreen),
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
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

  // ─── HISTORIQUE TAB ────────────────────────────────────────────────────────

  Widget _buildHistoriqueTab() {
    final history = [
      {'date': 'Aujourd\'hui', 'meds': 2, 'total': 3, 'pct': 0.67},
      {'date': 'Hier', 'meds': 3, 'total': 3, 'pct': 1.0},
      {'date': '10 Fév', 'meds': 2, 'total': 3, 'pct': 0.67},
      {'date': '09 Fév', 'meds': 1, 'total': 3, 'pct': 0.33},
      {'date': '08 Fév', 'meds': 3, 'total': 3, 'pct': 1.0},
      {'date': '07 Fév', 'meds': 2, 'total': 3, 'pct': 0.67},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Historique',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Suivi de votre observance',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          // Résumé
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
          const Text(
            'Détail par jour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...history.map((h) => _buildHistoryItem(h)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> h) {
    final pct = h['pct'] as double;
    Color statusColor = pct == 1.0
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
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              pct == 1.0 ? Icons.check_circle_outline : Icons.info_outline,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h['date'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${h['meds']} sur ${h['total']} prises effectuées',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${(pct * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── NOTIFICATIONS TAB ─────────────────────────────────────────────────────

  Widget _buildNotificationsTab() {
    final notifs = [
      {
        'title': 'Rappel médicament',
        'body': 'Il est l\'heure de prendre Metformine 500mg',
        'time': 'Il y a 5 min',
        'icon': Icons.alarm,
        'color': AppColors.primaryGreen,
        'read': false,
      },
      {
        'title': 'Proche – Youssef',
        'body': 'Aspégic 100mg n\'a pas été confirmée',
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
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Tout lire',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...notifs.map((n) => _buildNotifItem(n)).toList(),
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
        border: read
            ? null
            : Border.all(color: (n['color'] as Color).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              n['icon'] as IconData,
              color: n['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                    if (!read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: n['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['body'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  n['time'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey,
                    fontStyle: FontStyle.italic,
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
          // Header profil
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nom Prénom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'patient@email.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🩺 Patient',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Infos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildProfileSection('Informations personnelles', [
                  _buildProfileItem(Icons.person_outline, 'Nom complet', 'Nom Prénom'),
                  _buildProfileItem(Icons.email_outlined, 'Email', 'patient@email.com'),
                  _buildProfileItem(Icons.phone_outlined, 'Téléphone', '+216 XX XXX XXX'),
                  _buildProfileItem(Icons.location_on_outlined, 'Adresse', 'Tunis, Tunisie'),
                ]),
                const SizedBox(height: 16),
                _buildProfileSection('Informations médicales', [
                  _buildProfileItem(Icons.water_drop_outlined, 'Groupe sanguin', 'A+'),
                  _buildProfileItem(Icons.warning_amber_outlined, 'Allergies', 'Pénicilline'),
                  _buildProfileItem(Icons.medical_information_outlined, 'Maladies chroniques', 'Diabète type 2'),
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

  Widget _buildProfileSection(String title, List<Widget> items) {
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
                color: AppColors.primaryGreen,
              ),
            ),
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
}

// Fallback pour image avatar
void _avatarFallback(Object exception, StackTrace? stackTrace) {}

// ─── PAGE RECOMMANDATION ──────────────────────────────────────────────────────

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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
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
}