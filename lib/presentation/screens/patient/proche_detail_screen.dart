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
  late String _userId;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProcheDetailViewModel>();
    _getUserId();
    _loadData();
  }

  void _getUserId() async {
    final storage = StorageService();
    final userId = storage.getUserId();
    setState(() {
      _userId = userId!;
    });
  }

  void _loadData() async {
    await _viewModel.loadAllProcheData(_userId, widget.proche.id);
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
                    onPressed: _loadData,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.proche.status == 'observant'
                              ? Colors.green
                              : widget.proche.status == 'à surveiller'
                              ? Colors.orange
                              : widget.proche.status == 'rappel nécessaire'
                              ? Colors.red
                              : AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.proche.status ?? 'Non défini',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    if (viewModel.traitements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.medication_outlined, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun traitement en cours',
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.traitements.length,
      itemBuilder: (context, index) {
        final traitement = viewModel.traitements[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        traitement.medicament,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: traitement.statut == 'en cours'
                            ? Colors.green
                            : traitement.statut == 'terminé'
                            ? Colors.grey
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        traitement.statut,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Dosage: ${traitement.dosage}',
                  style: const TextStyle(color: AppColors.grey),
                ),
                Text(
                  'Fréquence: ${traitement.frequence}',
                  style: const TextStyle(color: AppColors.grey),
                ),
                if (traitement.notes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Notes: ${traitement.notes}',
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoriqueTab(ProcheDetailViewModel viewModel) {
    if (viewModel.historique.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun historique',
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.historique.length,
      itemBuilder: (context, index) {
        final item = viewModel.historique[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.date,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.type,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.detail,
                  style: const TextStyle(color: AppColors.grey),
                ),
                if (item.diagnostic != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Diagnostic: ${item.diagnostic}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
