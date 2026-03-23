import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/viewmodels/add_proche_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddProcheScreen extends StatefulWidget {
  const AddProcheScreen({super.key});

  @override
  State<AddProcheScreen> createState() => _AddProcheScreenState();
}

class _AddProcheScreenState extends State<AddProcheScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Par Email
  final _emailController = TextEditingController();
  String? _selectedRelationEmail;

  // Tab 2: Par QR Code
  final _qrCodeController = TextEditingController();
  String? _selectedRelationQR;

  final List<String> _relations = [
    'Pere',
    'Mere',
    'Conjoint',
    'Enfant',
    'Frere',
    'Soeur',
    'Grand-pere',
    'Grand-mere',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  void _addProcheByEmail() async {
    if (_emailController.text.isEmpty || _selectedRelationEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final viewModel = Provider.of<AddProcheViewModel>(context, listen: false);
    final success = await viewModel.addProcheByEmail(
      email: _emailController.text.trim(),
      relation: _selectedRelationEmail!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proche ajouté avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erreur lors de l\'ajout'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _addProcheByQR() async {
    if (_qrCodeController.text.isEmpty || _selectedRelationQR == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez scanner le QR code et sélectionner une relation'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final viewModel = Provider.of<AddProcheViewModel>(context, listen: false);
    final success = await viewModel.addProcheByQRCode(
      procheUserId: _qrCodeController.text.trim(),
      relation: _selectedRelationQR!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proche ajouté avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Erreur lors de l\'ajout'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un proche'),
        backgroundColor: AppColors.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.email),
              text: 'Par Email',
            ),
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: 'Par QR Code',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ====== TAB 1: Ajouter par Email ======
          _buildEmailTab(),

          // ====== TAB 2: Ajouter par QR Code ======
          _buildQRTab(),
        ],
      ),
    );
  }

  Widget _buildEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Le proche doit être déjà inscrit comme patient',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Email
          const Text(
            'Email du proche',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'exemple@email.com',
            icon: Icons.email_outlined,
            controller: _emailController,
          ),
          const SizedBox(height: 24),

          // Relation
          const Text(
            'Relation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedRelationEmail,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Sélectionnez la relation'),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: _relations.map((String relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(relation),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRelationEmail = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 40),

          // Bouton
          Consumer<AddProcheViewModel>(
            builder: (context, viewModel, _) {
              return CustomButton(
                text: 'Ajouter',
                onPressed: _addProcheByEmail,
                isLoading: viewModel.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Info
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
                    'Scannez le QR code du proche pour l\'ajouter',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // QR Scanner (pour l'instant input manuel)
          const Text(
            'ID du QR Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Collez l\'ID depuis le QR code',
            icon: Icons.qr_code_2,
            controller: _qrCodeController,
          ),
          const SizedBox(height: 16),

          // Zone QR Visuel
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  _qrCodeController.text.isEmpty
                      ? 'Aucun code scanné'
                      : 'ID: ${_qrCodeController.text}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez une caméra pour scanner',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Relation
          const Text(
            'Relation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedRelationQR,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Sélectionnez la relation'),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: _relations.map((String relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(relation),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRelationQR = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 40),

          // Bouton
          Consumer<AddProcheViewModel>(
            builder: (context, viewModel, _) {
              return CustomButton(
                text: 'Ajouter',
                onPressed: _addProcheByQR,
                isLoading: viewModel.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}
