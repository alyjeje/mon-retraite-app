import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/beneficiary_designation_model.dart';
import '../../../widgets/widgets.dart';

/// Étape 4: Récapitulatif de la désignation
class SummaryStep extends StatelessWidget {
  final BeneficiaryDesignation designation;
  final VoidCallback onConfirm;
  final Function(int step) onEdit;

  const SummaryStep({
    super.key,
    required this.designation,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapSm,
                Text(
                  'Vérifiez les informations avant de signer électroniquement.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Contrat concerné
                _SectionCard(
                  title: 'Contrat concerné',
                  onEdit: () => onEdit(0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Text(
                          designation.contractName,
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalGapMd,

                // Type de désignation
                _SectionCard(
                  title: 'Type de désignation',
                  onEdit: () => onEdit(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getDesignationIcon(),
                            color: AppColors.primary,
                            size: 20,
                          ),
                          AppSpacing.horizontalGapSm,
                          Text(
                            _getDesignationTypeLabel(),
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalGapMd,

                // Clause bénéficiaire
                _SectionCard(
                  title: 'Clause bénéficiaire',
                  onEdit: designation.designationType == DesignationType.nominative
                      ? () => onEdit(1)
                      : () => onEdit(0),
                  child: Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(
                        color:
                            isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      designation.clauseText,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                AppSpacing.verticalGapMd,

                // Détail des bénéficiaires (si nominatif)
                if (designation.designationType == DesignationType.nominative) ...[
                  _SectionCard(
                    title: 'Bénéficiaires (${designation.nominativeBeneficiaries.length})',
                    onEdit: () => onEdit(1),
                    child: Column(
                      children: designation.beneficiariesByRank.entries.map((entry) {
                        final rank = entry.key;
                        final beneficiaries = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: AppSpacing.borderRadiusFull,
                                  ),
                                  child: Text(
                                    'Rang $rank',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (rank > 1) ...[
                                  AppSpacing.horizontalGapSm,
                                  Text(
                                    '(à défaut)',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            AppSpacing.verticalGapSm,
                            ...beneficiaries.map((b) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: _BeneficiarySummaryRow(
                                    beneficiary: b,
                                    distributionMode: designation.distributionMode,
                                    dateFormat: dateFormat,
                                  ),
                                )),
                            if (entry.key != designation.beneficiariesByRank.keys.last)
                              AppSpacing.verticalGapMd,
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  AppSpacing.verticalGapMd,

                  // Mode de répartition
                  _SectionCard(
                    title: 'Mode de répartition',
                    onEdit: () => onEdit(2),
                    child: Row(
                      children: [
                        Icon(
                          designation.distributionMode == DistributionMode.equalParts
                              ? Icons.balance
                              : Icons.pie_chart_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        AppSpacing.horizontalGapSm,
                        Text(
                          designation.distributionMode == DistributionMode.equalParts
                              ? 'Parts égales'
                              : 'Pourcentages personnalisés',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                AppSpacing.verticalGapLg,

                // Avertissement
                AlertCard(
                  title: 'Important',
                  message:
                      'En signant ce document, vous confirmez que les informations sont exactes et que vous souhaitez modifier la clause bénéficiaire de votre contrat. Cette désignation remplacera toute désignation antérieure.',
                  type: AlertCardType.warning,
                ),

                AppSpacing.verticalGapXxl,
              ],
            ),
          ),
        ),

        // Bouton confirmer
        Container(
          padding: AppSpacing.screenPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: AppButton(
              label: 'Passer à la signature',
              variant: AppButtonVariant.primary,
              trailingIcon: Icons.arrow_forward,
              onPressed: onConfirm,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDesignationIcon() {
    switch (designation.designationType) {
      case DesignationType.nominative:
        return Icons.people_alt_outlined;
      case DesignationType.standardClause:
        return Icons.description_outlined;
      case DesignationType.freeClause:
        return Icons.edit_note_outlined;
    }
  }

  String _getDesignationTypeLabel() {
    switch (designation.designationType) {
      case DesignationType.nominative:
        return 'Bénéficiaires nominatifs';
      case DesignationType.standardClause:
        return 'Clause type : ${designation.standardClauseType?.label ?? ""}';
      case DesignationType.freeClause:
        return 'Clause libre';
    }
  }
}

/// Carte de section avec titre et bouton modifier
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  const _SectionCard({
    required this.title,
    required this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      AppSpacing.horizontalGapXxs,
                      Text(
                        'Modifier',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          AppSpacing.verticalGapMd,
          child,
        ],
      ),
    );
  }
}

/// Ligne résumé d'un bénéficiaire
class _BeneficiarySummaryRow extends StatelessWidget {
  final NominativeBeneficiary beneficiary;
  final DistributionMode distributionMode;
  final DateFormat dateFormat;

  const _BeneficiarySummaryRow({
    required this.beneficiary,
    required this.distributionMode,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: Text(
                '${beneficiary.firstName[0]}${beneficiary.lastName[0]}'.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiary.fullName,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${beneficiary.relationshipLabel} • Né(e) le ${dateFormat.format(beneficiary.birthDate)}',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${beneficiary.percentage.toStringAsFixed(0)}%',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (beneficiary.dismembermentType != DismembermentType.none)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellowLight,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    beneficiary.dismembermentLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnYellow,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
