import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/patient/patient_dashboard.dart';
import '../../presentation/screens/pharmacien/pharmacien_dashboard.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient';
  static const String pharmacienDashboard = '/pharmacien';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    patientDashboard: (context) => const PatientDashboard(),
    pharmacienDashboard: (context) => const PharmacienDashboard(),
  };
}