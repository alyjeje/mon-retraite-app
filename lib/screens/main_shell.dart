import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/widgets.dart';
import 'home/home_screen.dart';
import 'contracts/contracts_screen.dart';
import 'payments/payments_screen.dart';
import 'help/help_screen.dart';
import 'profile/profile_screen.dart';

/// Shell principal avec Bottom Navigation - Design Figma
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final screens = [
      const HomeScreen(),
      const ContractsScreen(),
      const PaymentsScreen(),
      const HelpScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: provider.currentNavIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: provider.currentNavIndex,
        onTap: provider.setNavIndex,
      ),
    );
  }
}
