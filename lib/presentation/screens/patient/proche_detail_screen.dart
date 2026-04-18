import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/proche_model.dart';
import '../../../presentation/viewmodels/proche_detail_viewmodel.dart';
import '../../../services/storage_service.dart';

class ProcheDetailScreen extends StatefulWidget {
  final ProcheModel proche;

  const ProcheDetailScreen({required this.proche, super.key});

  @override
  State<ProcheDetailScreen> createState() => _ProcheDetailScreenState();
}

class _ProcheDetailScreenState extends State<ProcheDetailScreen> {
  late ProcheDetailViewModel _viewModel;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProcheDetailViewModel>();
    _loadAllData();
  }

  void _loadAllData() async {
    // Get userId first
    final storage = StorageService();
    final userId = storage.getUserId();

    if (userId != null) {
      // Then load proche data
      await _viewModel.loadAllProcheData(userId, widget.proche.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proche.fullName),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Consumer<ProcheDetailViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAllData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profil Info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.lightGrey,
                  child: Column(
                    children: [
                      Text(
                        widget.proche.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Relation: ${widget.proche.relation}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // Medical Information Section
                      Column(
                        children: [
                          if (viewModel.procheDetails != null) ...[
                            // Groupe sanguin
                            if (viewModel.procheDetails?['groupeSanguin'] !=
                                null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Groupe sanguin:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      viewModel
                                              .procheDetails?['groupeSanguin'] ??
                                          'N/A',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Date de naissance
                            if (viewModel.procheDetails?['dateNaissance'] !=
                                null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Date de naissance:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      viewModel
                                              .procheDetails?['dateNaissance'] ??
                                          'N/A',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Allergies
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Allergies:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (viewModel.procheDetails?['allergies']
                                                    as List?)
                                                ?.isEmpty ??
                                            true
                                        ? 'Aucune'
                                        : (viewModel.procheDetails?['allergies']
                                                      as List?)
                                                  ?.join(', ') ??
                                              'N/A',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Maladies chroniques
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Maladies chroniques:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (viewModel.procheDetails?['maladiesChroniques']
                                                  as List?)
                                              ?.isEmpty ??
                                          true
                                      ? 'Aucune'
                                      : (viewModel.procheDetails?['maladiesChroniques']
                                                    as List?)
                                                ?.join(', ') ??
                                            'N/A',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedTab == 0
                                      ? AppColors.primaryBlue
                                      : AppColors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Traitements',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedTab == 0
                                    ? AppColors.primaryBlue
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedTab == 1
                                      ? AppColors.primaryBlue
                                      : AppColors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Historique',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedTab == 1
                                    ? AppColors.primaryBlue
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _selectedTab == 0
                      ? _buildTraitementsTab(viewModel)
                      : _buildHistoriqueTab(viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTraitementsTab(ProcheDetailViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.medication_outlined, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'Traitements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bientôt disponible',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cette fonctionnalité sera disponible prochainement via le service prescription.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueTab(ProcheDetailViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'Historique',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bientôt disponible',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cette fonctionnalité sera disponible prochainement.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
