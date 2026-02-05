import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';
import 'beneficiary_designation_flow_screen.dart';

/// Écran de gestion des bénéficiaires
class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final beneficiaries = [
      {
        'id': '1',
        'name': 'Pierre Martin',
        'relationship': 'Conjoint',
        'percentage': 50,
        'order': 1,
        'contract': 'Mon PERIN GAN',
      },
      {
        'id': '2',
        'name': 'Léa Martin',
        'relationship': 'Enfant',
        'percentage': 25,
        'order': 2,
        'contract': 'Mon PERIN GAN',
      },
      {
        'id': '3',
        'name': 'Hugo Martin',
        'relationship': 'Enfant',
        'percentage': 25,
        'order': 2,
        'contract': 'Mon PERIN GAN',
      },
    ];

    final totalPercentage = beneficiaries.fold<int>(
      0,
      (sum, b) => sum + (b['percentage'] as int),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mes bénéficiaires'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gérez les bénéficiaires de vos contrats',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Alerte pédagogique
            AlertCard(
              title: 'Pourquoi désigner des bénéficiaires ?',
              message:
                  'En cas de décès, le capital de vos contrats retraite sera versé aux bénéficiaires que vous avez désignés, en dehors de votre succession. C\'est important pour protéger vos proches.',
              type: AlertCardType.info,
            ),
            AppSpacing.verticalGapLg,

            // Statistiques répartition
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Répartition totale',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: totalPercentage == 100
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      '$totalPercentage%',
                      style: AppTypography.labelMedium.copyWith(
                        color: totalPercentage == 100
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (totalPercentage != 100) ...[
              AppSpacing.verticalGapSm,
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  AppSpacing.horizontalGapXs,
                  Text(
                    'La répartition doit atteindre 100%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.verticalGapLg,

            // Liste des bénéficiaires
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bénéficiaires (${beneficiaries.length})',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppButton(
                  label: 'Ajouter',
                  variant: AppButtonVariant.primary,
                  leadingIcon: Icons.add,
                  onPressed: () => _navigateToDesignationFlow(context),
                ),
              ],
            ),
            AppSpacing.verticalGapMd,

            ...beneficiaries.map((beneficiary) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _BeneficiaryCard(
                name: beneficiary['name'] as String,
                relationship: beneficiary['relationship'] as String,
                percentage: beneficiary['percentage'] as int,
                order: beneficiary['order'] as int,
                contract: beneficiary['contract'] as String,
                onModify: () => _showComingSoon(context),
                onDelete: () => _showComingSoon(context),
              ),
            )),
            AppSpacing.verticalGapLg,

            // Information pédagogique
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Bon à savoir',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  _InfoSection(
                    title: 'Ordre de priorité',
                    description:
                        'Les bénéficiaires de rang 1 sont prioritaires. Si aucun n\'est en vie, le capital est versé au rang 2, etc.',
                  ),
                  AppSpacing.verticalGapSm,
                  _InfoSection(
                    title: 'Répartition',
                    description:
                        'Vous pouvez répartir le capital entre plusieurs bénéficiaires d\'un même rang en pourcentage.',
                  ),
                  AppSpacing.verticalGapSm,
                  _InfoSection(
                    title: 'Clause type',
                    description:
                        'Par défaut, sans désignation spécifique, le capital revient à votre conjoint puis à vos enfants.',
                  ),
                ],
              ),
            ),

            AppSpacing.verticalGapXxl,
          ],
        ),
      ),
    );
  }

  void _navigateToDesignationFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BeneficiaryDesignationFlowScreen(
          contractId: 'PERIN-2024-001',
          contractName: 'Mon PERIN GAN',
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _BeneficiaryCard extends StatelessWidget {
  final String name;
  final String relationship;
  final int percentage;
  final int order;
  final String contract;
  final VoidCallback onModify;
  final VoidCallback onDelete;

  const _BeneficiaryCard({
    required this.name,
    required this.relationship,
    required this.percentage,
    required this.order,
    required this.contract,
    required this.onModify,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTypography.labelLarge.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        AppSpacing.horizontalGapSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.backgroundLight,
                            borderRadius: AppSpacing.borderRadiusFull,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            'Rang $order',
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      relationship,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      contract,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Modifier',
                  variant: AppButtonVariant.outline,
                  leadingIcon: Icons.edit_outlined,
                  onPressed: onModify,
                ),
              ),
              AppSpacing.horizontalGapMd,
              AppButton(
                label: 'Supprimer',
                variant: AppButtonVariant.text,
                leadingIcon: Icons.delete_outline,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String description;

  const _InfoSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
