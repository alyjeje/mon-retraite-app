import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../simulator/simulator_screen.dart';
import '../documents/documents_screen.dart';
import '../education/education_screen.dart';

/// Écran d'accueil / Dashboard - Design Figma
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _buildHeader(context, provider),

              // Alerte action recommandée
              _buildWarningAlert(context),

              // Synthèse patrimoniale
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: TotalBalanceCard(
                  totalBalance: provider.totalBalance,
                  totalGains: provider.totalGains,
                  performancePercent: provider.overallPerformance,
                  onTap: () => provider.setNavIndex(1),
                ),
              ),

              AppSpacing.verticalGapLg,

              // Mes contrats
              _buildContractsSection(context, provider),

              AppSpacing.verticalGapLg,

              // Actions rapides (grille 2x2)
              _buildQuickActionsGrid(context, provider),

              AppSpacing.verticalGapLg,

              // Objectif retraite
              _buildRetirementGoalCard(context),

              AppSpacing.verticalGapLg,

              // Le saviez-vous
              _buildDidYouKnowCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${provider.user.firstName} 👋',
                  style: AppTypography.headlineLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  'Voici un aperçu de votre épargne retraite',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () {},
            hasBadge: true,
            badgeCount: provider.unreadNotificationsCount,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningAlert(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: AlertCard(
        title: 'Action recommandée',
        message: 'Pensez à mettre à jour vos bénéficiaires pour sécuriser votre succession.',
        type: AlertCardType.warning,
        onDismiss: () {},
      ),
    );
  }

  Widget _buildContractsSection(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes contrats',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton.icon(
                onPressed: () => provider.setNavIndex(1),
                icon: Text(
                  'Tout voir',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                label: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapSm,
          ...provider.contracts.map((contract) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ContractCard(
                contract: contract,
                onTap: () {},
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _QuickAction(
        icon: Icons.track_changes,
        title: 'Simuler ma retraite',
        description: 'Estimez votre future rente',
        bgColor: AppColors.primaryLighter,
        iconColor: AppColors.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SimulatorScreen()),
        ),
      ),
      _QuickAction(
        icon: Icons.trending_up,
        title: 'Faire un versement',
        description: 'Alimentez votre épargne',
        bgColor: AppColors.accentYellowLight,
        iconColor: AppColors.accentYellowDark,
        onTap: () => provider.setNavIndex(2),
      ),
      _QuickAction(
        icon: Icons.menu_book,
        title: 'Comprendre mes produits',
        description: 'PERIN, PERO, ERE expliqués',
        bgColor: AppColors.infoLight,
        iconColor: AppColors.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EducationScreen()),
        ),
      ),
      _QuickAction(
        icon: Icons.description_outlined,
        title: 'Mes documents',
        description: 'Relevés et attestations',
        bgColor: AppColors.successLight,
        iconColor: AppColors.success,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DocumentsScreen()),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.2,
            children: actions.map((action) => _QuickActionCard(action: action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRetirementGoalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentYellowLight,
              AppColors.warningLight,
            ],
          ),
          borderRadius: AppSpacing.cardRadius,
          border: Border(
            left: BorderSide(
              color: AppColors.accentYellow,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.track_changes,
                  color: isDark ? AppColors.foregroundLight : AppColors.foregroundLight,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre objectif retraite',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalGapXs,
                    Text(
                      'À 64 ans, vous êtes sur la bonne voie pour atteindre 2 100€/mois de rente',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SimulatorScreen()),
                      ),
                      icon: const Text('Ajuster mon objectif'),
                      label: const Icon(Icons.arrow_forward, size: 16),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDidYouKnowCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(AppColors.radiusLg),
              ),
              child: Icon(
                Icons.menu_book,
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
                    'Le saviez-vous ?',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalGapXs,
                  Text(
                    'Les versements sur votre PERIN sont déductibles de vos impôts, dans la limite de 10% de vos revenus.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapSm,
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EducationScreen()),
                    ),
                    child: Text(
                      'En savoir plus sur la fiscalité',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String description;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: action.bgColor,
                borderRadius: BorderRadius.circular(AppColors.radiusLg),
              ),
              child: Icon(
                action.icon,
                color: action.iconColor,
                size: 20,
              ),
            ),
            AppSpacing.verticalGapSm,
            Text(
              action.title,
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.verticalGapXxs,
            Text(
              action.description,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
