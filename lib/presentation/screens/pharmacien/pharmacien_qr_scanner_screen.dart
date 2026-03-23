import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/qrcode_model.dart';
import '../../../services/qrcode_service.dart';

class PharmacienQRScannerScreen extends StatefulWidget {
  const PharmacienQRScannerScreen({super.key});

  @override
  State<PharmacienQRScannerScreen> createState() =>
      _PharmacienQRScannerScreenState();
}

class _PharmacienQRScannerScreenState extends State<PharmacienQRScannerScreen> {
  final QRCodeService _qrcodeService = QRCodeService();
  final _qrInputController = TextEditingController();
  QRCodeModel? _scannedPatient;
  bool _isLoading = false;
  String? _error;

  void _scanQRCode() async {
    if (_qrInputController.text.isEmpty) {
      setState(() {
        _error = 'Veuillez entrer l\'ID du patient';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _qrcodeService.scanPatientQRCode(
      _qrInputController.text.trim(),
    );

    if (response.success && response.data != null) {
      setState(() {
        _scannedPatient = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message ?? 'Patient non trouvé';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _qrInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code Patient'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: _scannedPatient == null
          ? _buildScannerView()
          : _buildPatientDetailsView(),
    );
  }

  Widget _buildScannerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 80,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Scanner QR Code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scannez le QR code d\'un patient pour afficher son profil complet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _qrInputController,
            decoration: InputDecoration(
              hintText: 'Collez le code QR ici',
              prefixIcon: const Icon(Icons.qr_code_2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.lightGrey,
            ),
            onSubmitted: (_) => _scanQRCode(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _scanQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : const Text(
                      'Scanner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailsView() {
    final patient = _scannedPatient!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  patient.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoSection('Informations de base', [
            ('Email', patient.email),
            ('Téléphone', patient.telephone ?? 'N/A'),
            ('Adresse', patient.adresse ?? 'N/A'),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Santé', [
            ('Groupe sanguin', patient.groupeSanguin ?? 'N/A'),
            (
              'Allergies',
              patient.allergies.isEmpty
                  ? 'Aucune'
                  : patient.allergies.join(', '),
            ),
            (
              'Maladies chroniques',
              patient.maladiesChroniques.isEmpty
                  ? 'Aucune'
                  : patient.maladiesChroniques.join(', '),
            ),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _scannedPatient = null;
                  _qrInputController.clear();
                  _error = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Scanner un autre patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<(String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) => Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      items[index].$1,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items[index].$2,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
