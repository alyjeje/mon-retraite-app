import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';

/// Ecran propose apres la premiere connexion reussie
/// pour activer la biometrie (Face ID / Touch ID).
class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryLighterDark
                        : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Connexion biometrique',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'Souhaitez-vous activer la connexion par empreinte digitale ou Face ID pour vos prochaines connexions ?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Activer button
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightLg,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AppProvider>().enableBiometricFromPending();
                    },
                    icon: const Icon(Icons.fingerprint, size: 22),
                    label: const Text('Activer'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Plus tard button
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightLg,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AppProvider>().declineBiometric();
                    },
                    child: Text(
                      'Plus tard',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
