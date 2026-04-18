import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/patient/patient_dashboard.dart';
import '../../presentation/screens/patient/proche_detail_screen.dart';
import '../../presentation/screens/patient/medication_details_screen.dart';
import '../../presentation/screens/patient/full_calendar_screen.dart';
import '../../presentation/screens/patient/profile_setting_screen.dart';
import '../../presentation/screens/patient/edit_profile_screen.dart';
import '../../presentation/screens/patient/share_profile_qr_screen.dart';
import '../../presentation/screens/pharmacien/pharmacien_dashboard.dart';
import '../../presentation/screens/pharmacien/pharmacien_qr_scanner_screen.dart';
import '../../presentation/screens/pharmacien/add_medicine_screen.dart';
import '../../data/models/proche_model.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient';
  static const String pharmacienDashboard = '/pharmacien';
  static const String addProche = '/add-proche';
  static const String procheDetail = '/proche-detail';
  static const String pharmacienQRScanner = '/pharmacien-qr-scanner';
  static const String medicationDetails = '/medication-details';
  static const String fullCalendar = '/full-calendar';
  static const String profileSetting = '/profile-setting';
  static const String editProfile = '/edit-profile';
  static const String shareProfileQR = '/share-profile-qr';
  static const String addMedicine = '/add-medicine';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    patientDashboard: (context) => const PatientDashboard(),
    pharmacienDashboard: (context) => const PharmacienDashboard(),
    pharmacienQRScanner: (context) => const PharmacienQRScannerScreen(),
    fullCalendar: (context) => const FullCalendarScreen(),
    profileSetting: (context) => const ProfileSettingScreen(),
    editProfile: (context) => const EditProfileScreen(),
    shareProfileQR: (context) => const ShareProfileQRScreen(),
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

  /// Navigue vers l'écran des détails des médicaments pour un jour
  static void navigateToMedicationDetails(
    BuildContext context,
    DateTime selectedDate,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MedicationDetailsScreen(selectedDate: selectedDate),
      ),
    );
  }

  /// Navigue vers l'écran de paramètres du compte
  static void navigateToProfileSetting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSettingScreen()),
    );
  }

  /// Navigue vers l'écran d'édition du profil
  static void navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  /// Navigue vers l'écran de partage du profil avec QR code
  static void navigateToShareProfileQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShareProfileQRScreen()),
    );
  }

  /// Navigue vers l'écran d'ajout de médicament (Pharmacien)
  static void navigateToAddMedicine(
    BuildContext context, {
    required String patientId,
    required String patientName,
    required int patientAge,
    required String patientSex,
    required String allergies,
    required bool isPregnant,
    String? initialMedicationName,
    String? initialDosage,
    String? initialType,
    int? initialDurationDays,
    String? recommendationNote,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(
          patientId: patientId,
          patientName: patientName,
          patientAge: patientAge,
          patientSex: patientSex,
          allergies: allergies,
          isPregnant: isPregnant,
          initialMedicationName: initialMedicationName,
          initialDosage: initialDosage,
          initialType: initialType,
          initialDurationDays: initialDurationDays,
          recommendationNote: recommendationNote,
        ),
      ),
    );
  }
}
