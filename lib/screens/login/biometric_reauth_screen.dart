import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';

/// Ecran de re-verification biometrique affiche quand l'app revient du background.
/// L'utilisateur est toujours authentifie (session active) mais doit prouver
/// son identite avant de revoir le contenu de l'app.
class BiometricReauthScreen extends StatefulWidget {
  const BiometricReauthScreen({super.key});

  @override
  State<BiometricReauthScreen> createState() => _BiometricReauthScreenState();
}

class _BiometricReauthScreenState extends State<BiometricReauthScreen> {
  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    final provider = context.read<AppProvider>();
    final success = await provider.biometricService.authenticate();

    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (success) {
        provider.completeReauth();
      } else {
        setState(() => _error = 'Verification echouee');
      }
    }
  }

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
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppColors.shadowMd,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Application verrouillee',
                  style: AppTypography.displaySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Verifiez votre identite pour continuer',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Biometric button
                GestureDetector(
                  onTap: _isAuthenticating ? null : _authenticate,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLighterDark
                          : AppColors.primaryLighter,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _isAuthenticating
                        ? const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.fingerprint,
                            size: 44,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  _isAuthenticating
                      ? 'Verification...'
                      : 'Appuyez pour vous identifier',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxxl),

                // Option to fully logout
                TextButton(
                  onPressed: () {
                    context.read<AppProvider>().logout();
                  },
                  child: Text(
                    'Se deconnecter',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
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
