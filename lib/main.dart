import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/finance_provider.dart';
import 'screens/modern_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar formateo de fechas para español de México
  await initializeDateFormatting('es_MX', null);
  Intl.defaultLocale = 'es_MX';
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FinanceProvider()..initializeDefaultAccounts(),
      child: MaterialApp(
        title: 'Finanzas Personales',
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: const ModernDashboardScreen(),
      ),
    );
  }
}