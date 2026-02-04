import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import 'app_card.dart';

/// Carte de contrat pour la liste
class ContractCard extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback? onTap;
  final bool showPerformance;

  const ContractCard({
    super.key,
    required this.contract,
    this.onTap,
    this.showPerformance = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final percentFormat = NumberFormat.decimalPercentPattern(
      locale: 'fr_FR',
      decimalDigits: 2,
    );

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec type de produit et numéro
          Row(
            children: [
              _ProductBadge(productType: contract.productType),
              const Spacer(),
              Text(
                contract.contractNumber,
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Nom du contrat
          Text(
            contract.name,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,

          // Encours
          Text(
            currencyFormat.format(contract.currentBalance),
            style: AppTypography.amountMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,

          // Performance et Plus-value
          if (showPerformance)
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Plus-value',
                    value: currencyFormat.format(contract.totalGains),
                    valueColor: contract.isPositivePerformance
                        ? AppColors.performancePositive
                        : AppColors.performanceNegative,
                    prefix: contract.isPositivePerformance ? '+' : '',
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Performance',
                    value: percentFormat.format(contract.performancePercent / 100),
                    valueColor: contract.isPositivePerformance
                        ? AppColors.performancePositive
                        : AppColors.performanceNegative,
                    prefix: contract.isPositivePerformance ? '+' : '',
                  ),
                ),
              ],
            ),

          // Versement programmé
          if (contract.hasScheduledPayment) ...[
            AppSpacing.verticalGapMd,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.autorenew,
                    size: 14,
                    color: AppColors.accentDark,
                  ),
                  AppSpacing.horizontalGapXs,
                  Text(
                    'Versement programmé : ${currencyFormat.format(contract.scheduledPaymentAmount)}/mois',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge du type de produit
class _ProductBadge extends StatelessWidget {
  final ProductType productType;

  const _ProductBadge({required this.productType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        productType.code,
        style: AppTypography.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (productType) {
      case ProductType.perin:
        return AppColors.perinColor;
      case ProductType.pero:
        return AppColors.peroColor;
      case ProductType.ere:
        return AppColors.ereColor;
      case ProductType.epargne:
        return AppColors.epargneColor;
    }
  }
}

/// Item de statistique
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String prefix;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        Text(
          '$prefix$value',
          style: AppTypography.labelMedium.copyWith(
            color: valueColor ??
                (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}

/// Carte de résumé total (en-tête dashboard)
class TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalGains;
  final double performancePercent;
  final VoidCallback? onTap;

  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalGains,
    required this.performancePercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final isPositive = totalGains >= 0;

    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Mon épargne retraite',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    AppSpacing.horizontalGapXxs,
                    Text(
                      '${isPositive ? '+' : ''}${performancePercent.toStringAsFixed(2)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Montant total
          Text(
            currencyFormat.format(totalBalance),
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
            ),
          ),
          AppSpacing.verticalGapSm,

          // Plus-value
          Row(
            children: [
              Text(
                'Plus-value : ',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${currencyFormat.format(totalGains)}',
                style: AppTypography.labelMedium.copyWith(
                  color: isPositive
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
