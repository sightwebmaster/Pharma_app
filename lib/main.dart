import 'package:flutter/material.dart';
import 'package:pharma_app/presentation/viewmodels/medication_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/pharmacien_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/proche_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/add_proche_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/proche_detail_viewmodel.dart';
import 'package:pharma_app/presentation/viewmodels/profile_viewmodel.dart';
import 'package:pharma_app/services/treatment_provider.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'services/api_client.dart';
import 'services/storage_service.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';

void main() async {
  // Assurer l'initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  await StorageService().init();
  ApiClient().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(create: (_) => MedicationViewModel()),
        ChangeNotifierProvider(create: (_) => PharmacienViewModel()),
        ChangeNotifierProvider(create: (_) => ProcheViewModel()),
        ChangeNotifierProvider(create: (_) => AddProcheViewModel()),
        ChangeNotifierProvider(create: (_) => ProcheDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => TreatmentProvider()),
      ],
      child: MaterialApp(
        title: 'Projet Pharma',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
