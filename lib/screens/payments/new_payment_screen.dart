import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

/// Écran de nouveau versement (guidé step-by-step)
class NewPaymentScreen extends StatefulWidget {
  final bool isProgrammed;

  const NewPaymentScreen({
    super.key,
    this.isProgrammed = false,
  });

  @override
  State<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  int _currentStep = 0;
  String? _selectedContractId;
  double _amount = 0;
  PaymentMethod _paymentMethod = PaymentMethod.directDebit;
  String _frequency = 'monthly';
  int _dayOfMonth = 5;
  bool _isLoading = false;
  bool _isSuccess = false;

  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSuccess) {
      return _buildSuccessScreen(context);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.isProgrammed
            ? 'Nouveau versement programmé'
            : 'Nouveau versement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: _buildStepContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = widget.isProgrammed ? 4 : 3;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: List.generate(steps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.dividerLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textTertiaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (index < steps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.primary : AppColors.dividerLight,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildContractSelection(context);
      case 1:
        return _buildAmountInput(context);
      case 2:
        if (widget.isProgrammed) {
          return _buildFrequencySelection(context);
        }
        return _buildPaymentMethodSelection(context);
      case 3:
        return _buildRecap(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContractSelection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sur quel contrat souhaitez-vous verser ?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Sélectionnez le contrat qui recevra votre versement.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,
          ...provider.contracts.map((contract) {
            final isSelected = _selectedContractId == contract.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _selectedContractId = contract.id),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                backgroundColor: isSelected
                    ? AppColors.primarySurface
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                child: Row(
                  children: [
                    Radio<String>(
                      value: contract.id,
                      groupValue: _selectedContractId,
                      onChanged: (value) => setState(() => _selectedContractId = value),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: AppSpacing.borderRadiusSm,
                                ),
                                child: Text(
                                  contract.productType.code,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalGapSm,
                              Expanded(
                                child: Text(
                                  contract.name,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalGapXs,
                          Text(
                            'Encours : ${currencyFormat.format(contract.currentBalance)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quel montant souhaitez-vous verser ?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            widget.isProgrammed
                ? 'Ce montant sera prélevé automatiquement selon la fréquence choisie.'
                : 'Entrez le montant de votre versement ponctuel.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapXl,

          // Montant
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: AppSpacing.cardRadius,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.displayMedium.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                    suffixText: '€',
                    suffixStyle: AppTypography.displayMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amount = double.tryParse(value) ?? 0;
                    });
                  },
                ),
                AppSpacing.verticalGapMd,
                // Montants rapides
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [50, 100, 200, 500].map((amount) {
                    return _QuickAmountChip(
                      amount: amount,
                      isSelected: _amount == amount,
                      onTap: () {
                        setState(() {
                          _amount = amount.toDouble();
                          _amountController.text = amount.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Info fiscalité
          AlertCard(
            title: 'Avantage fiscal',
            message: 'Les versements sur votre PERIN sont déductibles de votre revenu imposable, dans la limite des plafonds en vigueur.',
            type: AlertCardType.info,
            actionLabel: 'En savoir plus',
            onAction: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À quelle fréquence ?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Choisissez la fréquence de prélèvement et le jour du mois.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Fréquence
          Text(
            'Fréquence',
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          ...['monthly', 'quarterly', 'annual'].map((freq) {
            final isSelected = _frequency == freq;
            String label;
            String description;
            switch (freq) {
              case 'monthly':
                label = 'Mensuel';
                description = 'Chaque mois';
                break;
              case 'quarterly':
                label = 'Trimestriel';
                description = 'Tous les 3 mois';
                break;
              case 'annual':
                label = 'Annuel';
                description = 'Une fois par an';
                break;
              default:
                label = freq;
                description = '';
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _frequency = freq),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                backgroundColor: isSelected
                    ? AppColors.primarySurface
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                child: Row(
                  children: [
                    Radio<String>(
                      value: freq,
                      groupValue: _frequency,
                      onChanged: (value) => setState(() => _frequency = value!),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            description,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          AppSpacing.verticalGapLg,

          // Jour du mois
          Text(
            'Jour du prélèvement',
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [1, 5, 10, 15, 20, 25].map((day) {
              final isSelected = _dayOfMonth == day;
              return ChoiceChip(
                label: Text('$day'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _dayOfMonth = day);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment souhaitez-vous payer ?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Sélectionnez votre moyen de paiement.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Prélèvement
          ...provider.bankAccounts.map((account) {
            final isSelected = _paymentMethod == PaymentMethod.directDebit;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _paymentMethod = PaymentMethod.directDebit),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                backgroundColor: isSelected
                    ? AppColors.primarySurface
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                child: Row(
                  children: [
                    Radio<PaymentMethod>(
                      value: PaymentMethod.directDebit,
                      groupValue: _paymentMethod,
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: const Icon(Icons.account_balance, color: AppColors.primary),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prélèvement bancaire',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            account.maskedIban,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Virement
          AppCard(
            onTap: () => setState(() => _paymentMethod = PaymentMethod.bankTransfer),
            border: Border.all(
              color: _paymentMethod == PaymentMethod.bankTransfer
                  ? AppColors.primary
                  : AppColors.borderLight,
              width: _paymentMethod == PaymentMethod.bankTransfer ? 2 : 1,
            ),
            backgroundColor: _paymentMethod == PaymentMethod.bankTransfer
                ? AppColors.primarySurface
                : (isDark ? AppColors.cardDark : AppColors.cardLight),
            child: Row(
              children: [
                Radio<PaymentMethod>(
                  value: PaymentMethod.bankTransfer,
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Icon(Icons.swap_horiz, color: AppColors.accentDark),
                ),
                AppSpacing.horizontalGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Virement bancaire',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Vous recevrez les coordonnées par email',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecap(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final contract = provider.getContractById(_selectedContractId ?? '');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Vérifiez les informations avant de confirmer.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          AppCard(
            child: Column(
              children: [
                _RecapRow(label: 'Contrat', value: contract?.name ?? '-'),
                const Divider(),
                _RecapRow(
                  label: 'Montant',
                  value: currencyFormat.format(_amount),
                  isHighlighted: true,
                ),
                if (widget.isProgrammed) ...[
                  const Divider(),
                  _RecapRow(
                    label: 'Fréquence',
                    value: _frequency == 'monthly'
                        ? 'Mensuel'
                        : _frequency == 'quarterly'
                            ? 'Trimestriel'
                            : 'Annuel',
                  ),
                  const Divider(),
                  _RecapRow(label: 'Jour', value: 'Le $_dayOfMonth du mois'),
                ],
                const Divider(),
                _RecapRow(label: 'Moyen de paiement', value: _paymentMethod.label),
              ],
            ),
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
                    'En confirmant, vous acceptez les conditions générales de versement. Un email de confirmation vous sera envoyé.',
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
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final maxStep = widget.isProgrammed ? 3 : 2;
    final canProceed = _canProceed();

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: AppButton(
                  label: 'Retour',
                  variant: AppButtonVariant.outline,
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
            if (_currentStep > 0) AppSpacing.horizontalGapMd,
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: AppButton(
                label: _currentStep == maxStep ? 'Confirmer' : 'Continuer',
                isLoading: _isLoading,
                isEnabled: canProceed,
                onPressed: canProceed ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedContractId != null;
      case 1:
        return _amount >= 50;
      default:
        return true;
    }
  }

  void _onContinue() async {
    final maxStep = widget.isProgrammed ? 3 : 2;

    if (_currentStep < maxStep) {
      setState(() => _currentStep++);
    } else {
      // Confirmer le versement
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  Widget _buildSuccessScreen(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Scaffold(
      body: SuccessView(
        title: widget.isProgrammed
            ? 'Versement programmé créé !'
            : 'Versement effectué !',
        message: widget.isProgrammed
            ? 'Votre versement de ${currencyFormat.format(_amount)} sera prélevé automatiquement.'
            : 'Votre versement de ${currencyFormat.format(_amount)} a été pris en compte.',
        actionLabel: 'Retour à l\'accueil',
        onAction: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundLight,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          '$amount €',
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _RecapRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: isHighlighted
                ? AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                  )
                : AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
          ),
        ],
      ),
    );
  }
}
