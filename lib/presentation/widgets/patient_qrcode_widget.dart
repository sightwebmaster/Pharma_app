import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/qrcode_service.dart';

class PatientQRCodeWidget extends StatefulWidget {
  final String userId;

  const PatientQRCodeWidget({required this.userId, super.key});

  @override
  State<PatientQRCodeWidget> createState() => _PatientQRCodeWidgetState();
}

class _PatientQRCodeWidgetState extends State<PatientQRCodeWidget> {
  final QRCodeService _qrcodeService = QRCodeService();
  String? _qrData;
  bool _isLoading = false;
  String? _error;

  void _loadQRCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _qrcodeService.getPatientQRCode(widget.userId);

    if (response.success && response.data != null) {
      setState(() {
        _qrData = response.data!.id;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message ?? 'Erreur lors de la génération du QR code';
        _isLoading = false;
      });
    }
  }

  void _showQRCodeDialog() {
    if (_qrData == null) {
      _loadQRCode();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Votre QR Code'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : _qrData != null
                ? QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 250,
                    gapless: false,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.qr_code_2,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Mon QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Partagez votre QR code avec vos proches pour qu\'ils vous retrouvent facilement',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showQRCodeDialog,
              icon: const Icon(Icons.visibility),
              label: const Text('Afficher mon QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
