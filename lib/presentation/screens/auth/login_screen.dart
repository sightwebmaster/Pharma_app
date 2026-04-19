import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
<<<<<<< HEAD
=======
import '../../../core/constants/app_text_styles.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
import '../../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
<<<<<<< HEAD
  // Controllers pour récupérer les valeurs des champs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Hover states
  bool _isEmailHovered = false;
  bool _isPasswordHovered = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Méthode de login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Vérifier le rôle pour rediriger
      final role = authViewModel.currentUser?.role;

      if (role?.toLowerCase() == 'patient') {
        Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
      } else if (role?.toLowerCase() == 'pharmacien') {
        Navigator.pushReplacementNamed(context, AppRoutes.pharmacienDashboard);
      }
    } else if (mounted) {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Erreur de connexion'),
          backgroundColor: AppColors.errorRed,
        ),
      );
=======
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool  _obscure      = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = Provider.of<AuthViewModel>(context, listen: false);
    final ok = await vm.login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      final role = vm.currentUser?.role.toLowerCase();
      Navigator.pushReplacementNamed(
        context,
        role == 'pharmacien'
            ? AppRoutes.pharmacienDashboard
            : AppRoutes.patientDashboard,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.errorMessage ?? 'Erreur de connexion'),
        backgroundColor: AppColors.errFg,
      ));
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo - Medicine bag with plus icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F6),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.local_pharmacy,
                        size: 60,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 10),
                    // App Name
                    const Text(
                      'Project Pharma',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    // Tagline
                    const Text(
                      'Your Health, Connected.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Connexion title
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Please sign in to continue',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isEmailHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isEmailHovered = false;
                        });
                      },
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _isEmailHovered
                                  ? AppColors.primaryGreen
                                  : const Color(0xFFDDDDDD),
                              width: _isEmailHovered ? 2 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isPasswordHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isPasswordHovered = false;
                        });
                      },
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          prefixIcon: const Icon(
                            Icons.lock_outlined,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _isPasswordHovered
                                  ? AppColors.primaryGreen
                                  : const Color(0xFFDDDDDD),
                              width: _isPasswordHovered ? 2 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authViewModel.isLoading
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: authViewModel.isLoading
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
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signup);
                          },
                          child: const Text(
                            'Inscription',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Divider with text
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.grey[300]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.grey[300]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          color: AppColors.primaryGreen,
                          onPressed: () {
                            // TODO: Implement Google login
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.code,
                          color: const Color.fromARGB(255, 37, 43, 51),
                          onPressed: () {
                            // TODO: Implement GitHub login
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          color: AppColors.primaryGreen,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: AppColors.grey, // Border color
                              width: 2.0, // Border width
                            ),
                          ),
                          onPressed: () {
                            // TODO: Implement Facebook login
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
=======
      backgroundColor: AppColors.surface,
      body: Consumer<AuthViewModel>(
        builder: (ctx, vm, _) {
          if (vm.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final role = vm.currentUser?.role.toUpperCase();
              Navigator.pushReplacementNamed(
                context,
                role == 'PHARMACIEN'
                    ? AppRoutes.pharmacienDashboard
                    : AppRoutes.patientDashboard,
              );
            });
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // Radial gradient background
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: 320,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.4),
                          radius: 1.1,
                          colors: [AppColors.greenTint, AppColors.surface],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 64),

                          // ── Logo mark ───────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.greenGradient,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x5912B8A0),
                                        blurRadius: 28,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.medical_services_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text('PharmaCare', style: AppTextStyles.headline1),
                                const SizedBox(height: 4),
                                const Text(
                                  'L\'assistant du pharmacien',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ── "Bon retour" label ───────────────────────
                          const Text(
                            'Bon retour 👋',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Email ────────────────────────────────────
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'email@exemple.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Champ requis';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // ── Password (focus ring on border) ──────────
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textFaint,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Champ requis';
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // ── Forgot password ──────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Login button ─────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: vm.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                disabledBackgroundColor:
                                    AppColors.borderSoft,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Divider ──────────────────────────────────
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'ou continuer avec',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Social buttons ───────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialBtn(label: 'G'),
                              const SizedBox(width: 12),
                              _SocialBtn(label: '@'),
                              const SizedBox(width: 12),
                              _SocialBtn(label: 'f'),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ── Sign up link ─────────────────────────────
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pas encore de compte ? ',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.signup),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Inscription',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              ),
            ),
          );
        },
<<<<<<< HEAD
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    ShapeBorder? shape,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(29, 5, 242, 139),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
=======
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  const _SocialBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
}
