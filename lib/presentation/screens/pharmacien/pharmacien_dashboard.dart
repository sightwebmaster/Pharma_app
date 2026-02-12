import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PharmacienDashboard extends StatefulWidget {
  const PharmacienDashboard({super.key});

  @override
  State<PharmacienDashboard> createState() => _PharmacienDashboardState();
}

class _PharmacienDashboardState extends State<PharmacienDashboard> {
  int _selectedIndex = 0;

  // Données simulées
  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'Youssef Ben Ali',
      'age': 64,
      'maladie': 'Diabète type 2',
      'observance': 0.67,
      'qrCode': 'PAT-001-YBA',
      'meds': [
        {'name': 'Metformine 500mg', 'dose': '1cp × 2/jour'},
        {'name': 'Aspégic 100mg', 'dose': '1cp × 1/jour'},
        {'name': 'Ramipril 5mg', 'dose': '1cp × 1/soir'},
      ],
    },
    {
      'name': 'Fatma Mansouri',
      'age': 58,
      'maladie': 'Hypertension',
      'observance': 0.92,
      'qrCode': 'PAT-002-FM',
      'meds': [
        {'name': 'Atorvastatine 20mg', 'dose': '1cp × 1/soir'},
        {'name': 'Vitamine D3', 'dose': '1cp × 1/jour'},
      ],
    },
    {
      'name': 'Karim Saidi',
      'age': 45,
      'maladie': 'Diabète type 1',
      'observance': 0.80,
      'qrCode': 'PAT-003-KS',
      'meds': [
        {'name': 'Insuline rapide', 'dose': '10UI × 3/jour'},
        {'name': 'Metformine 850mg', 'dose': '1cp × 2/jour'},
      ],
    },
  ];

  Map<String, dynamic>? _scannedPatient;
  String _searchQuery = '';

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
                ..._patients.take(2).map((p) => _buildPatientCard(p)).toList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            children: const [
              Text(
                'Bonjour 👋',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                'Dr. Sami Trabelsi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
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
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final planifActives = _patients.length;
    
    return Row(
      children: [
        _buildStatCard('${_patients.length}', 'Patients', AppColors.primaryBlue),
        const SizedBox(width: 10),
        _buildStatCard(
          '$planifActives',
          'Planif. actives',
          AppColors.primaryGreen,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '0',
          'En attente',
          AppColors.grey,
        ),
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
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final observance = patient['observance'] as double;
    Color obsColor = observance >= 0.8
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
            offset: const Offset(0, 2),
          ),
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
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          patient['name'] as String,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${patient['age']} ans · ${patient['maladie']}',
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(observance * 100).toInt()}%',
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
          ..._patients.map((p) => _buildScanPatientItem(p)).toList(),

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
                  color: AppColors.primaryBlue.withOpacity(0.25), width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2,
                    size: 80, color: AppColors.primaryBlue.withOpacity(0.5)),
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
                setState(() {
                  _scannedPatient = _patients[0];
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              label: const Text(
                'Activer la caméra',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanPatientItem(Map<String, dynamic> patient) {
    final isSelected = _scannedPatient?['name'] == patient['name'];
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
                (patient['name'] as String).substring(0, 1),
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
                        color: AppColors.black),
                  ),
                  Text(
                    '${patient['age']} ans · ${patient['maladie']}',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Text(
              patient['qrCode'] as String,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontFamily: 'monospace'),
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
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '● Actif',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
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
                  ...meds.map((med) => _buildScannedMedRow(med)).toList(),
                  const SizedBox(height: 16),

                  // Boutons action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showPlanifierDialog(patient),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '+ Planifier prise',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
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
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '🩺 Recommandation',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
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
          const Icon(Icons.medication_outlined,
              size: 18, color: AppColors.grey),
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
                      color: AppColors.black),
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
            child: ListView(
              children: _patients
                  .where((p) => (p['name'] as String)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .map((p) => _buildDetailedPatientCard(p))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPatientCard(Map<String, dynamic> patient) {
    final observance = patient['observance'] as double;
    Color obsColor = observance >= 0.8
        ? AppColors.primaryGreen
        : observance >= 0.5
            ? const Color(0xFFFFA726)
            : AppColors.errorRed;
    final meds = patient['meds'] as List<Map<String, dynamic>>;

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
                    (patient['name'] as String).substring(0, 1),
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
                            color: AppColors.black),
                      ),
                      Text(
                        '${patient['age']} ans · ${patient['maladie']}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: observance,
                                backgroundColor: obsColor.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(obsColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(observance * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: obsColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Médicaments
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: meds
                  .take(3)
                  .map((m) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m['name'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ))
                  .toList(),
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
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.visibility_outlined,
                        size: 16, color: AppColors.primaryBlue),
                    label: const Text(
                      'Voir détail',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600),
                    ),
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
                    label: const Text(
                      'Planifier',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
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
                        builder: (_) =>
                            const RecommandationPharmacienScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.medical_services_outlined,
                        color: Colors.white),
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
                      child:
                          const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Dr. Sami Trabelsi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'pharmacien@email.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '💊 Pharmacien',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
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
                  _buildProfilItem(Icons.person_outline, 'Nom complet',
                      'Dr. Sami Trabelsi'),
                  _buildProfilItem(
                      Icons.badge_outlined, 'N° Ordre', 'PHARM-2024-001'),
                  _buildProfilItem(Icons.star_outline, 'Spécialité',
                      'Pharmacie clinique'),
                  _buildProfilItem(Icons.phone_outlined, 'Téléphone',
                      '+216 XX XXX XXX'),
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
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon:
                        const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.bold),
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
                prefixIcon: const Icon(Icons.medication_outlined,
                    color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: doseController,
              decoration: InputDecoration(
                hintText: 'Posologie (ex: 1 comprimé)',
                prefixIcon: const Icon(Icons.science_outlined,
                    color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: heureController,
              decoration: InputDecoration(
                hintText: 'Heure de prise (ex: 08:00)',
                prefixIcon: const Icon(Icons.access_time,
                    color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Confirmer la planification',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
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