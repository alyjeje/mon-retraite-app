import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran de gestion des versements
class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scheduledPayments = [
      {
        'id': '1',
        'contract': 'Mon PERIN GAN',
        'amount': 200.0,
        'frequency': 'Mensuel',
        'nextDate': '15 Mar 2026',
        'status': 'active',
      },
      {
        'id': '2',
        'contract': 'PERO Entreprise',
        'amount': 150.0,
        'frequency': 'Mensuel',
        'nextDate': '01 Mar 2026',
        'status': 'active',
      },
    ];

    final recentPayments = [
      {
        'date': '15 Fév 2026',
        'contract': 'Mon PERIN GAN',
        'amount': 200.0,
        'status': 'completed',
        'method': 'Prélèvement automatique',
      },
      {
        'date': '01 Fév 2026',
        'contract': 'PERO Entreprise',
        'amount': 150.0,
        'status': 'completed',
        'method': 'Prélèvement automatique',
      },
      {
        'date': '15 Jan 2026',
        'contract': 'Mon PERIN GAN',
        'amount': 5000.0,
        'status': 'completed',
        'method': 'Virement bancaire',
      },
      {
        'date': '01 Jan 2026',
        'contract': 'PERO Entreprise',
        'amount': 150.0,
        'status': 'completed',
        'method': 'Prélèvement automatique',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Versements'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Text(
              'Gérez vos versements et opérations',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Actions rapides
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Versement ponctuel',
                    subtitle: 'Alimentez votre épargne',
                    icon: Icons.arrow_upward,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _showComingSoon(context),
                  ),
                ),
                AppSpacing.horizontalGapMd,
                Expanded(
                  child: _QuickActionCard(
                    title: 'Versement programmé',
                    subtitle: 'Automatisez vos versements',
                    icon: Icons.calendar_today,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _showComingSoon(context),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapXl,

            // Versements programmés
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versements programmés',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () => _showComingSoon(context),
                  child: const Text('Gérer'),
                ),
              ],
            ),
            AppSpacing.verticalGapMd,

            ...scheduledPayments.map((payment) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ScheduledPaymentCard(
                contract: payment['contract'] as String,
                amount: payment['amount'] as double,
                frequency: payment['frequency'] as String,
                nextDate: payment['nextDate'] as String,
                status: payment['status'] as String,
                onModify: () => _showComingSoon(context),
                onSuspend: () => _showComingSoon(context),
              ),
            )),

            AppButton(
              label: 'Créer un nouveau versement programmé',
              variant: AppButtonVariant.outline,
              leadingIcon: Icons.calendar_today,
              onPressed: () => _showComingSoon(context),
            ),
            AppSpacing.verticalGapXl,

            // Historique
            Text(
              'Historique des versements',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapMd,

            AppCard(
              child: Column(
                children: recentPayments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final payment = entry.value;
                  return Column(
                    children: [
                      _PaymentHistoryItem(
                        contract: payment['contract'] as String,
                        date: payment['date'] as String,
                        amount: payment['amount'] as double,
                        method: payment['method'] as String,
                        status: payment['status'] as String,
                      ),
                      if (index < recentPayments.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            AppSpacing.verticalGapMd,

            Center(
              child: TextButton(
                onPressed: () => _showComingSoon(context),
                child: const Text('Voir tout l\'historique'),
              ),
            ),
            AppSpacing.verticalGapLg,

            // Information pédagogique
            AlertCard(
              title: 'Avantage fiscal des versements',
              message:
                  'Les versements sur votre PERIN sont déductibles de vos revenus imposables dans la limite de 10% de vos revenus professionnels (plafonné à 35 194€ en 2026).',
              type: AlertCardType.info,
            ),

            AppSpacing.verticalGapXxl,
          ],
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            AppSpacing.verticalGapSm,
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapXxs,
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledPaymentCard extends StatelessWidget {
  final String contract;
  final double amount;
  final String frequency;
  final String nextDate;
  final String status;
  final VoidCallback onModify;
  final VoidCallback onSuspend;

  const _ScheduledPaymentCard({
    required this.contract,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    required this.status,
    required this.onModify,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    frequency,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.horizontalGapXxs,
                    Text(
                      'Actif',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(amount),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      AppSpacing.horizontalGapXxs,
                      Text(
                        'Prochain versement',
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    nextDate,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
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
                  onPressed: onModify,
                ),
              ),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: AppButton(
                  label: 'Suspendre',
                  variant: AppButtonVariant.text,
                  onPressed: onSuspend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final String contract;
  final String date;
  final double amount;
  final String method;
  final String status;

  const _PaymentHistoryItem({
    required this.contract,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      date,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${currencyFormat.format(amount)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.horizontalGapXxs,
                        Text(
                          'Validé',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalGapXxs,
          Text(
            method,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
