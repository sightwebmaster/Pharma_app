import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.login),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SvgPicture.asset('assets/images/pharmaconnect-logo.svg', height: 120, width: 120, fit: BoxFit.contain),
              const SizedBox(height: 20),
              Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hint: AppStrings.email,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hint: AppStrings.password,
                icon: Icons.lock,
                obscureText: true,
              ),
             
              
              const SizedBox(height: 16),
              CustomButton(
                text: '${AppStrings.login} ',
                color: AppColors.primaryGreen,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.pharmacienDashboard);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signup);
                },
                child: const Text(AppStrings.signup),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}