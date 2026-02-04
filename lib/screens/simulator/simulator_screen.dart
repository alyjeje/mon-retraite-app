import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran du simulateur de retraite
class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  int _retirementAge = 64;
  double _monthlyContribution = 200;
  double _currentSavings = 89359.25; // Total actuel
  double _targetAmount = 150000;
  bool _showResults = false;

  double get _estimatedCapital {
    final yearsUntilRetirement = _retirementAge - 59; // Age actuel supposé
    final monthsUntilRetirement = yearsUntilRetirement * 12;
    final futureValue = _currentSavings * 1.03 + // 3% rendement annuel moyen
        _monthlyContribution * monthsUntilRetirement * 1.015; // Avec intérêts
    return futureValue;
  }

  double get _estimatedMonthlyRent {
    // Estimation simplifiée : capital / 20 ans / 12 mois
    return _estimatedCapital / 240;
  }

  double get _progressPercent {
    return (_estimatedCapital / _targetAmount).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Simulateur retraite'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            AlertCard(
              title: 'Simulez votre future retraite',
              message:
                  'Cet outil vous permet d\'estimer votre capital et votre rente à la retraite selon différents scénarios.',
              type: AlertCardType.info,
            ),
            AppSpacing.verticalGapLg,

            // Paramètres
            Text(
              'Vos paramètres',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapMd,

            // Âge de départ
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: AppColors.primary),
                      AppSpacing.horizontalGapSm,
                      Text(
                        'Âge de départ à la retraite',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMd,
                  Row(
                    children: [
                      Text(
                        '62',
                        style: AppTypography.caption,
                      ),
                      Expanded(
                        child: Slider(
                          value: _retirementAge.toDouble(),
                          min: 62,
                          max: 67,
                          divisions: 5,
                          label: '$_retirementAge ans',
                          onChanged: (value) {
                            setState(() => _retirementAge = value.toInt());
                          },
                        ),
                      ),
                      Text(
                        '67',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        '$_retirementAge ans',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,

            // Versement mensuel
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: AppColors.accent),
                      AppSpacing.horizontalGapSm,
                      Text(
                        'Versement mensuel',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMd,
                  Row(
                    children: [
                      Text(
                        '50€',
                        style: AppTypography.caption,
                      ),
                      Expanded(
                        child: Slider(
                          value: _monthlyContribution,
                          min: 50,
                          max: 1000,
                          divisions: 19,
                          label: '${_monthlyContribution.toInt()}€',
                          onChanged: (value) {
                            setState(() => _monthlyContribution = value);
                          },
                        ),
                      ),
                      Text(
                        '1000€',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        '${_monthlyContribution.toInt()}€ / mois',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,

            // Objectif
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: AppColors.success),
                      AppSpacing.horizontalGapSm,
                      Text(
                        'Votre objectif de capital',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [100000.0, 150000.0, 200000.0, 300000.0].map((amount) {
                      final isSelected = _targetAmount == amount;
                      return GestureDetector(
                        onTap: () => setState(() => _targetAmount = amount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.success
                                : AppColors.backgroundLight,
                            borderRadius: AppSpacing.borderRadiusFull,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.success
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            '${(amount / 1000).toInt()}k€',
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapLg,

            // Bouton simuler
            AppButton(
              label: 'Voir ma projection',
              onPressed: () {
                setState(() => _showResults = true);
              },
              leadingIcon: Icons.calculate,
            ),
            AppSpacing.verticalGapLg,

            // Résultats
            if (_showResults) ...[
              Text(
                'Votre projection',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              AppSpacing.verticalGapMd,

              // Progression vers l'objectif
              AppCard(
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 80,
                      lineWidth: 12,
                      percent: _progressPercent,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_progressPercent * 100).toInt()}%',
                            style: AppTypography.headlineLarge.copyWith(
                              color: _progressPercent >= 1
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            'de l\'objectif',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      progressColor: _progressPercent >= 1
                          ? AppColors.success
                          : AppColors.primary,
                      backgroundColor: AppColors.dividerLight,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    AppSpacing.verticalGapLg,
                    Row(
                      children: [
                        Expanded(
                          child: _ResultItem(
                            label: 'Capital estimé',
                            value: currencyFormat.format(_estimatedCapital),
                            icon: Icons.account_balance_wallet,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSpacing.horizontalGapMd,
                        Expanded(
                          child: _ResultItem(
                            label: 'Rente mensuelle',
                            value: currencyFormat.format(_estimatedMonthlyRent),
                            icon: Icons.payments,
                            color: AppColors.accent,
                            subtitle: 'estimation',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalGapMd,

              // Scénarios
              Text(
                'Scénarios alternatifs',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              AppSpacing.verticalGapSm,

              _ScenarioCard(
                title: 'Si vous versez 100€ de plus par mois',
                additionalCapital: (_monthlyContribution + 100) * (_retirementAge - 59) * 12 * 1.015 - _monthlyContribution * (_retirementAge - 59) * 12 * 1.015,
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
              AppSpacing.verticalGapSm,

              _ScenarioCard(
                title: 'Si vous faites un versement de 5 000€ maintenant',
                additionalCapital: 5000 * 1.15, // 15% de gains estimés
                icon: Icons.bolt,
                color: AppColors.accent,
              ),
              AppSpacing.verticalGapLg,

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.textTertiaryLight,
                    ),
                    AppSpacing.horizontalGapSm,
                    Expanded(
                      child: Text(
                        'Cette simulation est donnée à titre indicatif et ne constitue pas un engagement contractuel. Les performances passées ne préjugent pas des performances futures.',
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
              AppSpacing.verticalGapLg,

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Verser maintenant',
                      onPressed: () {},
                      leadingIcon: Icons.add,
                    ),
                  ),
                  AppSpacing.horizontalGapMd,
                  Expanded(
                    child: AppButton(
                      label: 'Partager',
                      variant: AppButtonVariant.outline,
                      onPressed: () {},
                      leadingIcon: Icons.share,
                    ),
                  ),
                ],
              ),
            ],

            AppSpacing.verticalGapXxl,
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        AppSpacing.verticalGapSm,
        Text(
          label,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalGapXxs,
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: AppColors.textTertiaryLight,
            ),
          ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final double additionalCapital;
  final IconData icon;
  final Color color;

  const _ScenarioCard({
    required this.title,
    required this.additionalCapital,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '+${currencyFormat.format(additionalCapital)} de capital',
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
