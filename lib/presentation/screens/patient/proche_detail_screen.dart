import 'dart:convert';

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
    final storage = StorageService();
    final userId = storage.getUserId();

    if (userId != null) {
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
          if (viewModel.isLoading &&
              viewModel.procheDetails == null &&
              viewModel.traitements.isEmpty &&
              viewModel.historique.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null &&
              viewModel.procheDetails == null &&
              viewModel.traitements.isEmpty &&
              viewModel.historique.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAllData,
                    child: const Text('Reessayer'),
                  ),
                ],
              ),
            );
          }

          final details = viewModel.procheDetails ?? <String, dynamic>{};
          return RefreshIndicator(
            onRefresh: () async => _loadAllData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(details),
                const SizedBox(height: 16),
                _buildInfoCard(details),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 12),
                if (_selectedTab == 0)
                  _buildTraitementsTab(viewModel)
                else
                  _buildHistoriqueTab(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> details) {
    final imageData = _extractBase64(
      (details['photoBase64'] ?? widget.proche.photoBase64)?.toString(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
            backgroundImage: imageData == null ? null : MemoryImage(base64Decode(imageData)),
            child: imageData == null
                ? Text(
                    widget.proche.prenom.isNotEmpty
                        ? widget.proche.prenom[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.proche.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.proche.relation,
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('Traitements ${_viewModel.traitements.length}'),
                    _chip('Historique ${_viewModel.historique.length}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> details) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil medical',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _infoRow('Telephone', details['telephone']?.toString() ?? widget.proche.telephone ?? 'N/A'),
          _infoRow('Email', details['email']?.toString() ?? widget.proche.email ?? 'N/A'),
          _infoRow('Groupe sanguin', details['groupeSanguin']?.toString() ?? widget.proche.groupeSanguin ?? 'N/A'),
          _infoRow('Date naissance', details['dateNaissance']?.toString() ?? widget.proche.dateNaissance ?? 'N/A'),
          _infoRow(
            'Allergies',
            _joinList(details['allergies']) ?? _joinList(widget.proche.allergies) ?? 'Aucune',
          ),
          _infoRow(
            'Maladies chroniques',
            _joinList(details['maladiesChroniques']) ??
                _joinList(widget.proche.maladiesChroniques) ??
                'Aucune',
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabButton('Traitements', 0)),
        const SizedBox(width: 12),
        Expanded(child: _tabButton('Historique', 1)),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.primaryBlue : AppColors.grey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTraitementsTab(ProcheDetailViewModel viewModel) {
    if (viewModel.traitements.isEmpty) {
      return _emptyBlock(
        icon: Icons.medication_outlined,
        title: 'Aucun traitement detecte',
        subtitle: 'Les traitements et prises de ce proche apparaitront ici.',
      );
    }

    return Column(
      children: viewModel.traitements.map((traitement) {
        final statutColor = switch (traitement.statut.toLowerCase()) {
          'termine' => AppColors.primaryGreen,
          'a surveiller' => AppColors.errorRed,
          _ => AppColors.primaryBlue,
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      traitement.medicament,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statutColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      traitement.statut,
                      style: TextStyle(
                        color: statutColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _infoRow('Dosage', traitement.dosage),
              _infoRow('Heures', traitement.frequence),
              _infoRow('Debut', traitement.dateDebut ?? 'N/A'),
              _infoRow('Fin', traitement.dateFin ?? 'N/A'),
              if ((traitement.notes ?? '').isNotEmpty)
                _infoRow('Instructions', traitement.notes!),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoriqueTab(ProcheDetailViewModel viewModel) {
    if (viewModel.historique.isEmpty) {
      return _emptyBlock(
        icon: Icons.history,
        title: 'Aucun historique detecte',
        subtitle: 'Le detail des prises confirmees ou manquees apparaitra ici.',
      );
    }

    return Column(
      children: viewModel.historique.map((item) {
        final isConfirmed = item.detail.toLowerCase().contains('confirmee');
        final color = isConfirmed ? AppColors.primaryGreen : AppColors.errorRed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.diagnostic ?? 'Prise',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.detail} - ${item.date}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyBlock({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  String? _joinList(dynamic raw) {
    if (raw is List) {
      final values = raw.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
      return values.isEmpty ? null : values.join(', ');
    }
    return null;
  }

  String? _extractBase64(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return raw.contains(',') ? raw.split(',').last : raw;
  }
}
