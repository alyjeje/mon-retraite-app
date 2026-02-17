import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_shell.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/biometric_prompt_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les locales pour le formatage des dates
  await initializeDateFormatting('fr_FR', null);

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MonRetraiteApp());
}

/// Application Mon Epargne Retraite
/// Prototype pour assures retraites - Gan Assurances
class MonRetraiteApp extends StatelessWidget {
  const MonRetraiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Listener(
            onPointerDown: (_) => provider.resetInactivityTimer(),
            onPointerMove: (_) => provider.resetInactivityTimer(),
            child: MaterialApp(
              title: 'Mon Epargne Retraite',
              debugShowCheckedModeBanner: false,

              // Themes
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: provider.themeMode,

              // Auth gate: 3 etats
              home: _buildAuthGate(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthGate(AppProvider provider) {
    if (provider.isAuthenticated) {
      return const MainShell();
    }
    if (provider.requiresBiometricAuth) {
      return const BiometricPromptScreen();
    }
    return const LoginScreen();
  }
}
