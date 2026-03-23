import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/patient/patient_dashboard.dart';
import '../../presentation/screens/patient/add_proche_screen.dart';
import '../../presentation/screens/patient/proche_detail_screen.dart';
import '../../presentation/screens/pharmacien/pharmacien_dashboard.dart';
import '../../presentation/screens/pharmacien/pharmacien_qr_scanner_screen.dart';
import '../../data/models/proche_model.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient';
  static const String pharmacienDashboard = '/pharmacien';
  static const String addProche = '/add-proche';
  static const String procheDetail = '/proche-detail';
  static const String pharmacienQRScanner = '/pharmacien-qr-scanner';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    patientDashboard: (context) => const PatientDashboard(),
    pharmacienDashboard: (context) => const PharmacienDashboard(),
    addProche: (context) => const AddProcheScreen(),
    pharmacienQRScanner: (context) => const PharmacienQRScannerScreen(),
  };

  /// Navigue vers l'écran des détails d'un proche
  static void navigateToProcheDetail(BuildContext context, ProcheModel proche) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcheDetailScreen(proche: proche),
      ),
    );
  }
}
