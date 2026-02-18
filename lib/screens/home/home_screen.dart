import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../simulator/simulator_screen.dart';
import '../documents/documents_screen.dart';
import '../education/education_screen.dart';
import '../notifications/notifications_screen.dart';
import '../actions/actions_screen.dart';
import '../chat/chat_screen.dart';

/// Écran d'accueil / Dashboard - Design Figma
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        label: Text(
          'Assistant',
          style: AppTypography.buttonMedium.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: provider.isLoading && !provider.dataLoaded
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _buildHeader(context, provider),

              // Alerte dynamique (depuis le BFF)
              _buildDynamicAlert(context, provider),

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

              // Allocation globale (depuis le BFF)
              if (provider.globalAllocation.isNotEmpty)
                _buildGlobalAllocation(context, provider),

              if (provider.globalAllocation.isNotEmpty)
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            hasBadge: true,
            badgeCount: provider.unreadNotificationsCount,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAlert(BuildContext context, AppProvider provider) {
    final alert = provider.topAlert;
    if (alert == null) {
      return const SizedBox.shrink();
    }

    // Choisir le type d'alerte selon le type backend
    final alertType = alert.type == 'retraite'
        ? AlertCardType.info
        : alert.type == 'allocation'
            ? AlertCardType.warning
            : AlertCardType.warning;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: AlertCard(
        title: alert.title,
        message: alert.message,
        type: alertType,
        onDismiss: () {},
      ),
    );
  }

  Widget _buildGlobalAllocation(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allocations = provider.globalAllocation;

    // Couleurs par categorie de support
    final categoryColors = {
      'FE001': AppColors.primary,
      'AE001': AppColors.accentYellow,
      'OB001': AppColors.info,
      'IM001': AppColors.success,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            Text(
              'Allocation globale',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapMd,
            // Barre de repartition
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: allocations.map((a) {
                    final color = categoryColors[a.code] ?? Colors.grey;
                    return Expanded(
                      flex: (a.percentage * 10).round(),
                      child: Container(color: color),
                    );
                  }).toList(),
                ),
              ),
            ),
            AppSpacing.verticalGapMd,
            // Detail par support
            ...allocations.map((a) {
              final color = categoryColors[a.code] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.label,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Text(
                      '${a.percentage.toStringAsFixed(1)}%',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Text(
                        _formatAmount(a.amount),
                        textAlign: TextAlign.right,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k\u20AC';
    }
    return '${amount.toStringAsFixed(0)}\u20AC';
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActionsScreen()),
        ),
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
    // Couleurs dédiées pour fond jaune (bon contraste WCAG AA)
    const textColorOnYellow = AppColors.textOnYellow;

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
                  color: textColorOnYellow,
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
                        color: textColorOnYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalGapXs,
                    Text(
                      'À 64 ans, vous êtes sur la bonne voie pour atteindre 2 100€/mois de rente',
                      style: AppTypography.bodySmall.copyWith(
                        color: textColorOnYellow,
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
                        foregroundColor: textColorOnYellow,
                        side: BorderSide(
                          color: textColorOnYellow.withValues(alpha: 0.5),
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
