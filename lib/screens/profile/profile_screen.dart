import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';
import '../personal_info/personal_info_screen.dart';
import '../beneficiaries/beneficiaries_screen.dart';
import '../notifications/notifications_screen.dart';
import '../documents/documents_screen.dart';
import '../bank_details/change_bank_details_screen.dart';

/// Écran de profil - Design Figma
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final provider = context.read<AppProvider>();
    final available = await provider.biometricService.isAvailable();
    final enabled = await provider.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête profil
              _buildProfileHeader(context, user),

              AppSpacing.verticalGapLg,

              // Informations personnelles
              _buildSection(
                context,
                title: 'Informations personnelles',
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    label: 'Mes informations',
                    subtitle: user.fullName,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInfoScreen(),
                      ),
                    ),
                  ),
                  _ProfileItem(
                    icon: Icons.credit_card,
                    label: 'Coordonnées bancaires',
                    subtitle: '${provider.bankAccounts.length} RIB enregistrés',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangeBankDetailsScreen(),
                      ),
                    ),
                  ),
                  _ProfileItem(
                    icon: Icons.people_outline,
                    label: 'Mes bénéficiaires',
                    subtitle: '${provider.beneficiaries.length} bénéficiaires',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BeneficiariesScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Sécurité
              _buildSection(
                context,
                title: 'Sécurité',
                items: [
                  _ProfileItem(
                    icon: Icons.lock_outline,
                    label: 'Mot de passe',
                    subtitle: 'Modifié il y a 2 mois',
                    onTap: () {},
                  ),
                  if (_biometricAvailable)
                    _ProfileItem(
                      icon: Icons.fingerprint,
                      label: 'Connexion biométrique',
                      subtitle: _biometricEnabled ? 'Activée' : 'Désactivée',
                      hasSwitch: true,
                      switchValue: _biometricEnabled,
                      onSwitchChanged: (value) async {
                        if (value) {
                          // Can't enable from here without credentials
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reconnectez-vous pour activer la biométrie',
                              ),
                            ),
                          );
                        } else {
                          await provider.disableBiometric();
                          setState(() => _biometricEnabled = false);
                        }
                      },
                    ),
                  _ProfileItem(
                    icon: Icons.shield_outlined,
                    label: 'Authentification à 2 facteurs',
                    subtitle: user.has2FAEnabled ? 'Activée' : 'Désactivée',
                    onTap: () {},
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Préférences
              _buildSection(
                context,
                title: 'Préférences',
                items: [
                  _ProfileItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    subtitle: _notificationsEnabled ? 'Activées' : 'Désactivées',
                    hasSwitch: true,
                    switchValue: _notificationsEnabled,
                    onSwitchChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode sombre',
                    subtitle: _darkModeEnabled ? 'Activé' : 'Désactivé',
                    hasSwitch: true,
                    switchValue: _darkModeEnabled,
                    onSwitchChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                      provider.toggleTheme();
                    },
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Documents et données
              _buildSection(
                context,
                title: 'Documents et données',
                items: [
                  _ProfileItem(
                    icon: Icons.description_outlined,
                    label: 'Mes documents',
                    subtitle: 'Relevés et attestations',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DocumentsScreen(),
                      ),
                    ),
                  ),
                  _ProfileItem(
                    icon: Icons.download_outlined,
                    label: 'Exporter mes données',
                    subtitle: 'Demande RGPD',
                    onTap: () {},
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Déconnexion
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: AppColors.error,
                      size: 20,
                    ),
                    title: Text(
                      'Se déconnecter',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ),

              AppSpacing.verticalGapLg,

              // Version
              Center(
                child: Text(
                  'Version 1.2.0 • © 2026 GAN Assurances',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memberYear = user.memberSince?.year ?? 2020;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  'Client depuis $memberYear',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ProfileItem> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.verticalGapSm,
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    _buildItemTile(context, item),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, _ProfileItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: item.hasSwitch ? null : item.onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(AppColors.radiusLg),
              ),
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (item.hasSwitch)
              Switch(
                value: item.switchValue ?? false,
                onChanged: item.onSwitchChanged,
                activeTrackColor: AppColors.primary,
                activeThumbColor: Colors.white,
              )
            else
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppProvider>().logout();
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  _ProfileItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
  });
}
