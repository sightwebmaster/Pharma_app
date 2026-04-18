import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dropdown_constants.dart';
import '../viewmodels/add_proche_viewmodel.dart';
import './qr_scanner_widget.dart';

/// Widget réutilisable pour ajouter un proche (Email ou QR Code)
class AddProcheDialogWidget extends StatefulWidget {
  final VoidCallback? onProcheAdded;

  const AddProcheDialogWidget({this.onProcheAdded, super.key});

  @override
  State<AddProcheDialogWidget> createState() => _AddProcheDialogWidgetState();
}

class _AddProcheDialogWidgetState extends State<AddProcheDialogWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController qrCodeController = TextEditingController();
  String selectedRelationEmail = 'Pere';
  String selectedRelationQR = 'Pere';

  final List<String> relations = DropdownConstants.relations;

  @override
  void dispose() {
    emailController.dispose();
    qrCodeController.dispose();
    super.dispose();
  }

  void _addProcheByEmail(BuildContext context) async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un email'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final viewModel = Provider.of<AddProcheViewModel>(context, listen: false);
    final success = await viewModel.addProcheByEmail(
      email: emailController.text.trim(),
      relation: selectedRelationEmail,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proche ajouté avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      widget.onProcheAdded?.call();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erreur lors de l\'ajout'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _addProcheByQR(BuildContext context) async {
    if (qrCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez scanner le QR code'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final viewModel = Provider.of<AddProcheViewModel>(context, listen: false);
    final success = await viewModel.addProcheByQRCode(
      procheUserId: qrCodeController.text.trim(),
      relation: selectedRelationQR,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proche ajouté avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      widget.onProcheAdded?.call();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erreur lors de l\'ajout'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _openQRScanner(BuildContext context) async {
    final qrData = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerWidget(
          onQRCodeScanned: (qrData) {
            // Auto-pop handled by QRScannerWidget
          },
        ),
      ),
    );

    if (qrData != null && mounted) {
      setState(() {
        qrCodeController.text = qrData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Ajouter un proche',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Le proche doit être déjà inscrit comme patient',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Section 1: Par Email =====
            const Text(
              'Par Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email du proche',
                hintText: 'exemple@email.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryGreen,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRelationEmail,
              decoration: InputDecoration(
                labelText: 'Lien de parenté',
                prefixIcon: const Icon(
                  Icons.family_restroom,
                  color: AppColors.primaryGreen,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: relations.map((String relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(relation),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedRelationEmail = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Consumer<AddProcheViewModel>(
                builder: (context, viewModel, _) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _addProcheByEmail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Ajouter par Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ===== Divider =====
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OU',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 24),

            // ===== Section 2: Par QR Code =====
            const Text(
              'Par QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_2,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scannez le QR code du proche',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openQRScanner(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scanner QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (qrCodeController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code scanné:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      qrCodeController.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRelationQR,
              decoration: InputDecoration(
                labelText: 'Lien de parenté',
                prefixIcon: const Icon(
                  Icons.family_restroom,
                  color: AppColors.primaryGreen,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: relations.map((String relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(relation),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedRelationQR = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppColors.grey)),
        ),
        Consumer<AddProcheViewModel>(
          builder: (context, viewModel, _) {
            return ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _addProcheByQR(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Ajouter par QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
