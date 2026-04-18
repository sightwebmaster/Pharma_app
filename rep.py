import re

file_path = 'lib/presentation/screens/pharmacien/add_medicine_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r'  void _addMedicine\(\) async \{.*?(?=  @override\n  Widget build)'
replacement = '''  void _addMedicine() async {
    if (_medicineNameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _doseController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final storage = StorageService();
    final token = await storage.getAccessToken();
    final pharmacienId = await storage.getUserId();

    if (token == null || pharmacienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expiré — reconnectez-vous'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<String> heuresPrise = _calculateHeuresPrise(_timesPerDay);
    final DateTime dateDebut = DateTime.now();
    final int dureeJours = int.tryParse(_amountController.text) ?? 7;
    final DateTime dateFin = dateDebut.add(Duration(days: dureeJours));

    final Map<String, dynamic> body = {
      'patientUserId':    widget.patientId,
      'pharmacienUserId': pharmacienId,
      'dateDebut':        dateDebut.toIso8601String().split('T')[0],
      'dateFin':          dateFin.toIso8601String().split('T')[0],
      'motif':            'Prescription médicale',
      'lignes': [
        {
          'medicamentId':   null,
          'medicamentNom':  _medicineNameController.text,
          'principeActif':  _medicineNameController.text,
          'dosage':         _doseController.text,
          'type':           _typeController.text,
          'dureeJours':     dureeJours,
          'heuresPrise':    heuresPrise,
          'instructions':   _getMealTypeInstructions(_selectedMealType),
        }
      ],
    };

    final treatmentProvider = context.read<TreatmentProvider>();
    final result = await treatmentProvider.creerTraitement(body, token);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traitement créé avec succès ✅'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(treatmentProvider.error ?? 'Erreur création traitement'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  List<String> _calculateHeuresPrise(int timesPerDay) {
    switch (timesPerDay) {
      case 1:  return ['08:00'];
      case 2:  return ['08:00', '20:00'];
      case 3:  return ['08:00', '14:00', '20:00'];
      case 4:  return ['08:00', '12:00', '16:00', '20:00'];
      case 5:  return ['07:00', '10:00', '13:00', '17:00', '21:00'];
      default:
        final interval = 24 // timesPerDay;
        return List.generate(timesPerDay, (i) {
          final hour = (8 + i * interval) % 24;
          return '\:00';
        });
    }
  }

  String _getMealTypeInstructions(String mealType) {
    switch (mealType) {
      case 'Before Meals': return 'Prendre avant les repas';
      case 'After Meals':  return 'Prendre après les repas';
      case 'With Meals':   return 'Prendre pendant les repas';
      default:             return 'Prendre avant les repas';
    }
  }
'''

new_text = re.sub(pattern, replacement, text, flags=re.DOTALL)
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_text)
