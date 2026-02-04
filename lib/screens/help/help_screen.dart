import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Écran d'aide - Design Figma
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aide & Support',
                      style: AppTypography.headlineLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      'Comment pouvons-nous vous aider ?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalGapLg,

              // Contact cards
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Messagerie',
                        subtitle: 'Écrivez-nous',
                        color: AppColors.primary,
                        onTap: () {},
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.phone_outlined,
                        title: 'Téléphone',
                        subtitle: '09 69 32 12 12',
                        color: AppColors.success,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalGapLg,

              // FAQ Section
              _buildSection(
                context,
                title: 'Questions fréquentes',
                items: [
                  _HelpItem(
                    icon: Icons.help_outline,
                    title: 'Comment effectuer un versement ?',
                    onTap: () {},
                  ),
                  _HelpItem(
                    icon: Icons.help_outline,
                    title: 'Comment modifier mes bénéficiaires ?',
                    onTap: () {},
                  ),
                  _HelpItem(
                    icon: Icons.help_outline,
                    title: 'Comment télécharger mes documents ?',
                    onTap: () {},
                  ),
                  _HelpItem(
                    icon: Icons.help_outline,
                    title: 'Quelle est la fiscalité de mon PERIN ?',
                    onTap: () {},
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Guides Section
              _buildSection(
                context,
                title: 'Guides et tutoriels',
                items: [
                  _HelpItem(
                    icon: Icons.play_circle_outline,
                    title: 'Découvrir l\'application',
                    subtitle: 'Tutoriel vidéo • 3 min',
                    onTap: () {},
                  ),
                  _HelpItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Guide de l\'épargne retraite',
                    subtitle: 'PDF • 12 pages',
                    onTap: () {},
                  ),
                  _HelpItem(
                    icon: Icons.calculate_outlined,
                    title: 'Comprendre les simulations',
                    subtitle: 'Article • 5 min de lecture',
                    onTap: () {},
                  ),
                ],
              ),

              AppSpacing.verticalGapLg,

              // Appointment
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusLg),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prendre rendez-vous',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Échangez avec un conseiller',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_HelpItem> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
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
                    ListTile(
                      leading: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      title: Text(
                        item.title,
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: item.subtitle != null
                          ? Text(
                              item.subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      onTap: item.onTap,
                    ),
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
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppColors.radiusLg),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            AppSpacing.verticalGapSm,
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _HelpItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
