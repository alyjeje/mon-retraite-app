import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/beneficiary_designation_model.dart';
import '../../../widgets/widgets.dart';

/// Étape 3: Répartition des parts entre bénéficiaires
class DistributionStep extends StatefulWidget {
  final List<NominativeBeneficiary> beneficiaries;
  final DistributionMode distributionMode;
  final Function(List<NominativeBeneficiary>, DistributionMode) onDistributionUpdated;

  const DistributionStep({
    super.key,
    required this.beneficiaries,
    required this.distributionMode,
    required this.onDistributionUpdated,
  });

  @override
  State<DistributionStep> createState() => _DistributionStepState();
}

class _DistributionStepState extends State<DistributionStep> {
  late DistributionMode _distributionMode;
  late List<NominativeBeneficiary> _beneficiaries;
  final Map<String, TextEditingController> _percentageControllers = {};
  bool _showDismembermentOptions = false;

  @override
  void initState() {
    super.initState();
    _distributionMode = widget.distributionMode;
    _beneficiaries = widget.beneficiaries.map((b) {
      // Initialiser les pourcentages si pas encore définis
      if (b.percentage == 0) {
        return b.copyWith(percentage: _calculateEqualPercentage(b.rank));
      }
      return b;
    }).toList();

    // Créer les controllers pour chaque bénéficiaire
    for (final b in _beneficiaries) {
      _percentageControllers[b.id] = TextEditingController(
        text: b.percentage.toStringAsFixed(0),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _calculateEqualPercentage(int rank) {
    final sameRankCount = _beneficiaries.where((b) => b.rank == rank).length;
    if (sameRankCount == 0) return 100;
    return 100 / sameRankCount;
  }

  Map<int, double> get _totalByRank {
    final Map<int, double> totals = {};
    for (final b in _beneficiaries) {
      totals[b.rank] = (totals[b.rank] ?? 0) + b.percentage;
    }
    return totals;
  }

  bool get _isValid {
    if (_distributionMode == DistributionMode.equalParts) return true;
    return _totalByRank.values.every((total) => (total - 100).abs() < 0.01);
  }

  void _setEqualParts() {
    setState(() {
      _distributionMode = DistributionMode.equalParts;
      // Calculer les parts égales par rang
      final Map<int, int> countByRank = {};
      for (final b in _beneficiaries) {
        countByRank[b.rank] = (countByRank[b.rank] ?? 0) + 1;
      }

      _beneficiaries = _beneficiaries.map((b) {
        final equalPct = 100 / countByRank[b.rank]!;
        _percentageControllers[b.id]?.text = equalPct.toStringAsFixed(0);
        return b.copyWith(percentage: equalPct);
      }).toList();
    });
  }

  void _setPercentageMode() {
    setState(() {
      _distributionMode = DistributionMode.percentage;
    });
  }

  void _updatePercentage(String beneficiaryId, String value) {
    final percentage = double.tryParse(value) ?? 0;
    setState(() {
      final index = _beneficiaries.indexWhere((b) => b.id == beneficiaryId);
      if (index != -1) {
        _beneficiaries[index] = _beneficiaries[index].copyWith(
          percentage: percentage.clamp(0, 100),
        );
      }
    });
  }

  void _toggleDismemberment(String beneficiaryId, DismembermentType type) {
    setState(() {
      final index = _beneficiaries.indexWhere((b) => b.id == beneficiaryId);
      if (index != -1) {
        _beneficiaries[index] = _beneficiaries[index].copyWith(
          dismembermentType: type,
        );
      }
    });
  }

  void _onContinue() {
    widget.onDistributionUpdated(_beneficiaries, _distributionMode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final beneficiariesByRank = <int, List<NominativeBeneficiary>>{};
    for (final b in _beneficiaries) {
      beneficiariesByRank.putIfAbsent(b.rank, () => []);
      beneficiariesByRank[b.rank]!.add(b);
    }
    final sortedRanks = beneficiariesByRank.keys.toList()..sort();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Répartition du capital',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapSm,
                Text(
                  'Définissez comment le capital sera réparti entre vos bénéficiaires.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Mode de répartition
                Text(
                  'Mode de répartition',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapMd,
                Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        title: 'Parts égales',
                        icon: Icons.balance,
                        isSelected: _distributionMode == DistributionMode.equalParts,
                        onTap: _setEqualParts,
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: _ModeCard(
                        title: 'Pourcentages',
                        icon: Icons.pie_chart_outline,
                        isSelected: _distributionMode == DistributionMode.percentage,
                        onTap: _setPercentageMode,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapXl,

                // Répartition par rang
                ...sortedRanks.map((rank) {
                  final rankBeneficiaries = beneficiariesByRank[rank]!;
                  final rankTotal = _totalByRank[rank] ?? 0;
                  final isRankValid = (rankTotal - 100).abs() < 0.01;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalGapSm,
                              if (rank > 1)
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
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: isRankValid
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Text(
                              '${rankTotal.toStringAsFixed(0)}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: isRankValid
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalGapMd,
                      ...rankBeneficiaries.map((beneficiary) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _BeneficiaryDistributionCard(
                              beneficiary: beneficiary,
                              controller: _percentageControllers[beneficiary.id]!,
                              distributionMode: _distributionMode,
                              onPercentageChanged: (value) =>
                                  _updatePercentage(beneficiary.id, value),
                              onDismembermentChanged: (type) =>
                                  _toggleDismemberment(beneficiary.id, type),
                              showDismemberment: _showDismembermentOptions,
                            ),
                          )),
                      if (!isRankValid && _distributionMode == DistributionMode.percentage)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              AppSpacing.horizontalGapXs,
                              Expanded(
                                child: Text(
                                  'Le total du rang $rank doit être de 100% (actuellement ${rankTotal.toStringAsFixed(0)}%)',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      AppSpacing.verticalGapMd,
                    ],
                  );
                }),

                // Option démembrement
                AppSpacing.verticalGapMd,
                AppCard(
                  onTap: () =>
                      setState(() => _showDismembermentOptions = !_showDismembermentOptions),
                  child: Row(
                    children: [
                      Icon(
                        _showDismembermentOptions
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Démembrement de propriété',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              'Séparer usufruit et nue-propriété',
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showDismembermentOptions,
                        onChanged: (value) =>
                            setState(() => _showDismembermentOptions = value),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                if (_showDismembermentOptions) ...[
                  AppSpacing.verticalGapMd,
                  AlertCard(
                    title: 'Qu\'est-ce que le démembrement ?',
                    message:
                        'L\'usufruit permet de percevoir les revenus du capital. La nue-propriété donne la propriété du capital mais sans les revenus. Par exemple, vous pouvez attribuer l\'usufruit à votre conjoint et la nue-propriété à vos enfants.',
                    type: AlertCardType.info,
                  ),
                ],

                AppSpacing.verticalGapXxl,
              ],
            ),
          ),
        ),

        // Bouton continuer
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
              label: 'Continuer',
              variant: AppButtonVariant.primary,
              isEnabled: _isValid,
              onPressed: _isValid ? _onContinue : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte pour le mode de répartition
class _ModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              size: 28,
            ),
            AppSpacing.verticalGapSm,
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'un bénéficiaire avec répartition
class _BeneficiaryDistributionCard extends StatelessWidget {
  final NominativeBeneficiary beneficiary;
  final TextEditingController controller;
  final DistributionMode distributionMode;
  final Function(String) onPercentageChanged;
  final Function(DismembermentType) onDismembermentChanged;
  final bool showDismemberment;

  const _BeneficiaryDistributionCard({
    required this.beneficiary,
    required this.controller,
    required this.distributionMode,
    required this.onPercentageChanged,
    required this.onDismembermentChanged,
    required this.showDismemberment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Center(
                  child: Text(
                    '${beneficiary.firstName[0]}${beneficiary.lastName[0]}'.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
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
                      beneficiary.fullName,
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      beneficiary.relationshipLabel,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Champ pourcentage
              if (distributionMode == DistributionMode.percentage)
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: onPercentageChanged,
                    decoration: InputDecoration(
                      suffixText: '%',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    '${beneficiary.percentage.toStringAsFixed(0)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Options de démembrement
          if (showDismemberment) ...[
            AppSpacing.verticalGapMd,
            const Divider(height: 1),
            AppSpacing.verticalGapMd,
            Text(
              'Type de propriété',
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            Row(
              children: [
                _DismembermentChip(
                  label: 'Pleine propriété',
                  isSelected: beneficiary.dismembermentType == DismembermentType.none,
                  onTap: () => onDismembermentChanged(DismembermentType.none),
                ),
                AppSpacing.horizontalGapSm,
                _DismembermentChip(
                  label: 'Usufruit',
                  isSelected: beneficiary.dismembermentType == DismembermentType.usufruct,
                  onTap: () => onDismembermentChanged(DismembermentType.usufruct),
                ),
                AppSpacing.horizontalGapSm,
                _DismembermentChip(
                  label: 'Nue-propriété',
                  isSelected: beneficiary.dismembermentType == DismembermentType.bareOwnership,
                  onTap: () => onDismembermentChanged(DismembermentType.bareOwnership),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip pour le type de démembrement
class _DismembermentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DismembermentChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentYellow.withValues(alpha: 0.2)
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected
                ? AppColors.accentYellow
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected
                ? AppColors.textOnYellow
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
