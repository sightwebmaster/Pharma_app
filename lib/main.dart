import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Vérifier si l'utilisateur est déjà connecté
  String initialRoute = AppRoutes.login;

  try {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final role = await AuthService.getRole();
      if (role == 'PHARMACIEN' || role == 'ADMIN') {
        initialRoute = AppRoutes.pharmacienDashboard;
      } else {
        initialRoute = AppRoutes.patientDashboard;
      }
    }
  } catch (e) {
    // En cas d'erreur → retour au login
    initialRoute = AppRoutes.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmConnect',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
