import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran du simulateur de retraite - Design Figma
class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final _retirementAgeController = TextEditingController(text: '64');
  final _monthlyContributionController = TextEditingController(text: '200');
  final _oneTimePaymentController = TextEditingController(text: '0');

  static const int _currentAge = 45;
  static const double _currentBalance = 125780;
  static const double _targetPension = 2500;

  int get _retirementAge => int.tryParse(_retirementAgeController.text) ?? 64;
  double get _monthlyContribution =>
      double.tryParse(_monthlyContributionController.text) ?? 200;
  double get _oneTimePayment =>
      double.tryParse(_oneTimePaymentController.text) ?? 0;
  int get _yearsUntilRetirement => _retirementAge - _currentAge;

  double get _totalContributions =>
      (_monthlyContribution * 12 * _yearsUntilRetirement) + _oneTimePayment;

  double get _estimatedGrowth =>
      (_currentBalance + _totalContributions) * 0.04 * _yearsUntilRetirement;

  double get _estimatedTotal =>
      _currentBalance + _totalContributions + _estimatedGrowth;

  double get _estimatedMonthlyPension => _estimatedTotal * 0.004;

  double get _progressToTarget =>
      ((_estimatedMonthlyPension / _targetPension) * 100).clamp(0, 100);

  @override
  void dispose() {
    _retirementAgeController.dispose();
    _monthlyContributionController.dispose();
    _oneTimePaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Simulateur retraite'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sous-titre
            Text(
              'Estimez votre future rente mensuelle',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Alerte info
            AlertCard(
              title: 'Simulation indicative',
              message:
                  'Cette simulation est une estimation indicative basée sur vos données actuelles. Elle ne constitue pas un engagement contractuel.',
              type: AlertCardType.info,
            ),
            AppSpacing.verticalGapLg,

            // Paramètres de simulation
            _buildParametersCard(context, isDark, currencyFormat),
            AppSpacing.verticalGapLg,

            // Résultats de la simulation (carte gradient)
            _buildResultsCard(context, currencyFormat),
            AppSpacing.verticalGapLg,

            // Progression vers l'objectif
            _buildProgressionCard(context, isDark),
            AppSpacing.verticalGapLg,

            // Recommandations
            _buildRecommendationsCard(context, isDark),
            AppSpacing.verticalGapLg,

            // Actions
            AppButton(
              label: 'Faire un versement maintenant',
              variant: AppButtonVariant.accent,
              leadingIcon: Icons.euro,
              onPressed: () => _showComingSoon(context),
            ),
            AppSpacing.verticalGapMd,
            AppButton(
              label: 'Programmer des versements réguliers',
              variant: AppButtonVariant.outline,
              onPressed: () => _showComingSoon(context),
            ),
            AppSpacing.verticalGapLg,

            // Disclaimer
            _buildDisclaimer(context, isDark),
            AppSpacing.verticalGapXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildParametersCard(
      BuildContext context, bool isDark, NumberFormat currencyFormat) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Vos paramètres',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Info actuelle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre âge actuel',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      '$_currentAge ans',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Épargne actuelle',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      currencyFormat.format(_currentBalance),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Champs de saisie
          _buildInputField(
            context,
            isDark,
            label: 'Âge de départ souhaité',
            controller: _retirementAgeController,
            helperText: 'Dans $_yearsUntilRetirement ans',
            keyboardType: TextInputType.number,
          ),
          AppSpacing.verticalGapMd,
          _buildInputField(
            context,
            isDark,
            label: 'Versement mensuel prévu',
            controller: _monthlyContributionController,
            helperText: 'Montant que vous prévoyez de verser chaque mois',
            keyboardType: TextInputType.number,
            suffix: '€',
          ),
          AppSpacing.verticalGapMd,
          _buildInputField(
            context,
            isDark,
            label: 'Versement exceptionnel prévu (optionnel)',
            controller: _oneTimePaymentController,
            helperText: 'Versement ponctuel que vous prévoyez d\'effectuer',
            keyboardType: TextInputType.number,
            suffix: '€',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    bool isDark, {
    required String label,
    required TextEditingController controller,
    String? helperText,
    TextInputType? keyboardType,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.inputBackgroundDark : AppColors.inputBackgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            suffixText: suffix,
            suffixStyle: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (helperText != null) ...[
          AppSpacing.verticalGapXxs,
          Text(
            helperText,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultsCard(BuildContext context, NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: AppColors.shadowMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.white, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Votre projection à $_retirementAge ans',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,

          // Capital estimé
          Text(
            'Capital estimé',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          AppSpacing.verticalGapXxs,
          Text(
            currencyFormat.format(_estimatedTotal),
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalGapSm,
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white70, size: 16),
              AppSpacing.horizontalGapXxs,
              Text(
                '+${currencyFormat.format(_estimatedGrowth)} de gains estimés',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,

          // Séparateur
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          AppSpacing.verticalGapLg,

          // Rente mensuelle
          Text(
            'Rente mensuelle estimée',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          AppSpacing.verticalGapXxs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(_estimatedMonthlyPension),
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.accentYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  '/mois',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionCard(BuildContext context, bool isDark) {
    String alertMessage;
    AlertCardType alertType;

    if (_progressToTarget >= 100) {
      alertMessage =
          '🎉 Félicitations ! Vous êtes en bonne voie pour atteindre votre objectif.';
      alertType = AlertCardType.success;
    } else if (_progressToTarget >= 80) {
      alertMessage = '✅ Très bien ! Vous êtes proche de votre objectif.';
      alertType = AlertCardType.success;
    } else if (_progressToTarget >= 50) {
      alertMessage =
          '💪 Bon début ! Augmentez vos versements pour vous rapprocher de votre objectif.';
      alertType = AlertCardType.warning;
    } else {
      alertMessage =
          '📈 Augmentez vos versements pour atteindre votre objectif plus rapidement.';
      alertType = AlertCardType.info;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: AppColors.primary, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Progression vers votre objectif',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Objectif visé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objectif visé',
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${_targetPension.toInt()}€/mois',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressToTarget / 100,
              minHeight: 12,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressToTarget >= 80
                    ? AppColors.success
                    : _progressToTarget >= 50
                        ? AppColors.warning
                        : AppColors.primary,
              ),
            ),
          ),
          AppSpacing.verticalGapXxs,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_progressToTarget.toInt()}%',
              style: AppTypography.labelSmall.copyWith(
                color: _progressToTarget >= 80
                    ? AppColors.success
                    : _progressToTarget >= 50
                        ? AppColors.warning
                        : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.verticalGapMd,

          // Alert
          AlertCard(
            title: '',
            message: alertMessage,
            type: alertType,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, bool isDark) {
    final monthlyIncreaseNeeded =
        ((_targetPension - _estimatedMonthlyPension) / (_yearsUntilRetirement * 0.004 * 12))
            .ceil();
    final taxSavings = (_monthlyContribution * 12 * 0.3).toInt();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: AppColors.accentYellowDark, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Recommandations personnalisées',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Recommandation objectif
          if (_progressToTarget < 100)
            _buildRecommendationTile(
              context,
              isDark,
              icon: '💡',
              title: 'Pour atteindre ${_targetPension.toInt()}€/mois',
              description:
                  'Augmentez vos versements mensuels de $monthlyIncreaseNeeded€',
              bgColor: AppColors.accentYellowLight,
              textColor: AppColors.warningTextOnLight,
            ),
          if (_progressToTarget < 100) AppSpacing.verticalGapSm,

          // Recommandation fiscalité
          _buildRecommendationTile(
            context,
            isDark,
            icon: '📊',
            title: 'Optimisez votre fiscalité',
            description:
                'Vos versements PERIN vous font économiser environ $taxSavings€ d\'impôts par an.',
            bgColor: AppColors.primaryLighter,
            textColor: AppColors.primary,
          ),
          AppSpacing.verticalGapSm,

          // Recommandation temps
          _buildRecommendationTile(
            context,
            isDark,
            icon: '⏰',
            title: 'Le temps joue pour vous',
            description:
                'Plus vous épargnez tôt, plus vous bénéficiez de l\'effet des intérêts composés.',
            bgColor: AppColors.infoLight,
            textColor: AppColors.infoTextOnLight,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(
    BuildContext context,
    bool isDark, {
    required String icon,
    required String title,
    required String description,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon $title',
            style: AppTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalGapXxs,
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        'Avertissement : Cette simulation est réalisée à titre indicatif et ne constitue pas un engagement contractuel. Les performances passées ne préjugent pas des performances futures. Le montant final dépendra de nombreux facteurs incluant les performances des marchés financiers, vos versements réels et votre choix de sortie (rente ou capital).',
        style: AppTypography.caption.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontSize: 11,
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
