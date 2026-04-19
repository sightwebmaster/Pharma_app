import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:intl/intl.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/dropdown_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _dateNaissanceController = TextEditingController();

  String? _selectedGroupeSanguin;
  final List<String> _selectedAllergies = [];
  final List<String> _selectedMaladiesChroniques = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateNaissanceController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs correctement'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.signup(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      telephone: _telephoneController.text.trim(),
      adresse: _adresseController.text.trim(),
      role: AppStrings.patient,
<<<<<<< HEAD
=======
      dateNaissance: _dateNaissanceController.text.trim().isEmpty
          ? null
          : DateFormat('d/M/yyyy').parse(_dateNaissanceController.text.trim()),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      groupeSanguin: _selectedGroupeSanguin,
      allergies: _selectedAllergies,
      maladiesChroniques: _selectedMaladiesChroniques,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inscription réussie! Bienvenue ${_prenomController.text}',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Erreur d\'inscription'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signup),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de bienvenue
                const SizedBox(height: 20),
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez notre plateforme de gestion pharmaceutique',
                  style: TextStyle(fontSize: 14, color: AppColors.grey),
                ),
                const SizedBox(height: 30),

                // Champ Nom
                const Text(
                  'Nom',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Entrez votre nom',
                  icon: Icons.person_outline,
                  controller: _nomController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Prénom
                const Text(
                  'Prénom',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Entrez votre prénom',
                  icon: Icons.person_outline,
                  controller: _prenomController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prénom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Email
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est requis';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Téléphone
                const Text(
                  'Téléphone',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: '06 XX XX XX XX',
                  icon: Icons.phone_outlined,
                  controller: _telephoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le téléphone est requis';
                    }
                    if (value.length < 10) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Adresse
                const Text(
                  'Adresse',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Votre adresse complète',
                  icon: Icons.location_on_outlined,
                  controller: _adresseController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'adresse est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Date de naissance
                const Text(
                  'Date de naissance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: TextFormField(
                    controller: _dateNaissanceController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'JJ/MM/AAAA',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Groupe sanguin
                const Text(
                  'Groupe sanguin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGroupeSanguin,
                    hint: const Text('Sélectionnez votre groupe sanguin'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: DropdownConstants.groupesSanguins.map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroupeSanguin = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Allergies (Multi-select)
                const Text(
                  'Allergies',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: DropdownConstants.allergies.map((String allergy) {
                      return CheckboxListTile(
                        title: Text(allergy),
                        value: _selectedAllergies.contains(allergy),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedAllergies.add(allergy);
                            } else {
                              _selectedAllergies.remove(allergy);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Maladies chroniques (Multi-select)
                const Text(
                  'Maladies chroniques',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: DropdownConstants.maladiesChroniques.map((
                      String maladie,
                    ) {
                      return CheckboxListTile(
                        title: Text(maladie),
                        value: _selectedMaladiesChroniques.contains(maladie),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedMaladiesChroniques.add(maladie);
                            } else {
                              _selectedMaladiesChroniques.remove(maladie);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Champ Mot de passe
                const Text(
                  'Mot de passe',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 caractères',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryBlue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est requis';
                    }
                    if (value.length < 8) {
                      return 'Minimum 8 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Confirmer mot de passe
                const Text(
                  'Confirmer le mot de passe',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Retapez votre mot de passe',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryBlue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer le mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Bouton d'inscription
                CustomButton(
                  text: AppStrings.signup,
                  onPressed: _signup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: AppColors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
