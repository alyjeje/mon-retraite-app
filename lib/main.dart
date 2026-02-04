import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_shell.dart';

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

/// Application Mon Épargne Retraite
/// Prototype pour assurés retraités - Gan Assurances
class MonRetraiteApp extends StatelessWidget {
  const MonRetraiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Mon Épargne Retraite',
            debugShowCheckedModeBanner: false,

            // Thèmes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,

            // Écran principal
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
