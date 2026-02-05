import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/theme/theme.dart';
import '../../data/models/beneficiary_designation_model.dart';
import '../../widgets/widgets.dart';
import 'steps/designation_type_step.dart';
import 'steps/nominative_beneficiaries_step.dart';
import 'steps/distribution_step.dart';
import 'steps/summary_step.dart';
import 'steps/signature_step.dart';

/// Écran principal du parcours de désignation de bénéficiaire
class BeneficiaryDesignationFlowScreen extends StatefulWidget {
  final String contractId;
  final String contractName;

  const BeneficiaryDesignationFlowScreen({
    super.key,
    required this.contractId,
    required this.contractName,
  });

  @override
  State<BeneficiaryDesignationFlowScreen> createState() =>
      _BeneficiaryDesignationFlowScreenState();
}

class _BeneficiaryDesignationFlowScreenState
    extends State<BeneficiaryDesignationFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // État du formulaire
  DesignationType _designationType = DesignationType.nominative;
  List<NominativeBeneficiary> _beneficiaries = [];
  DistributionMode _distributionMode = DistributionMode.percentage;
  StandardClauseType? _standardClauseType;
  String? _freeClauseText;
  bool _isCompleted = false;
  String? _signatureReference;
  String? _pdfPath;

  // Nombre d'étapes selon le type de désignation
  int get _totalSteps {
    switch (_designationType) {
      case DesignationType.nominative:
        return 5; // Type -> Bénéficiaires -> Répartition -> Récap -> Signature
      case DesignationType.standardClause:
      case DesignationType.freeClause:
        return 3; // Type -> Récap -> Signature
    }
  }

  List<String> get _stepTitles {
    switch (_designationType) {
      case DesignationType.nominative:
        return [
          'Type de désignation',
          'Bénéficiaires',
          'Répartition',
          'Récapitulatif',
          'Signature',
        ];
      case DesignationType.standardClause:
      case DesignationType.freeClause:
        return [
          'Type de désignation',
          'Récapitulatif',
          'Signature',
        ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = step);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onDesignationTypeSelected(DesignationType type,
      {StandardClauseType? standardClause, String? freeClause}) {
    setState(() {
      _designationType = type;
      _standardClauseType = standardClause;
      _freeClauseText = freeClause;
    });
    _nextStep();
  }

  void _onBeneficiariesUpdated(List<NominativeBeneficiary> beneficiaries) {
    setState(() {
      _beneficiaries = beneficiaries;
    });
  }

  void _onDistributionUpdated(
      List<NominativeBeneficiary> beneficiaries, DistributionMode mode) {
    setState(() {
      _beneficiaries = beneficiaries;
      _distributionMode = mode;
    });
    _nextStep();
  }

  void _onSignatureCompleted(String reference, String pdfPath) {
    setState(() {
      _signatureReference = reference;
      _pdfPath = pdfPath;
      _isCompleted = true;
    });
  }

  /// Ouvre le PDF généré avec le visualiseur système
  Future<void> _openPdf() async {
    if (_pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun document disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final file = File(_pdfPath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'designation_beneficiaire.pdf',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le document n\'a pas été trouvé'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  BeneficiaryDesignation _buildDesignation() {
    return BeneficiaryDesignation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contractId: widget.contractId,
      contractName: widget.contractName,
      designationType: _designationType,
      nominativeBeneficiaries: _beneficiaries,
      distributionMode: _distributionMode,
      standardClauseType: _standardClauseType,
      freeClauseText: _freeClauseText,
      createdAt: DateTime.now(),
      signedAt: _signatureReference != null ? DateTime.now() : null,
      signatureReference: _signatureReference,
      isSigned: _signatureReference != null,
    );
  }

  Widget _buildCurrentStep() {
    final designation = _buildDesignation();

    if (_designationType == DesignationType.nominative) {
      switch (_currentStep) {
        case 0:
          return DesignationTypeStep(
            selectedType: _designationType,
            standardClauseType: _standardClauseType,
            freeClauseText: _freeClauseText,
            onTypeSelected: _onDesignationTypeSelected,
          );
        case 1:
          return NominativeBeneficiariesStep(
            beneficiaries: _beneficiaries,
            onBeneficiariesUpdated: _onBeneficiariesUpdated,
            onNext: () {
              if (_beneficiaries.isNotEmpty) {
                _nextStep();
              }
            },
          );
        case 2:
          return DistributionStep(
            beneficiaries: _beneficiaries,
            distributionMode: _distributionMode,
            onDistributionUpdated: _onDistributionUpdated,
          );
        case 3:
          return SummaryStep(
            designation: designation,
            onConfirm: _nextStep,
            onEdit: (step) => _goToStep(step),
          );
        case 4:
          return SignatureStep(
            designation: designation,
            onSignatureCompleted: _onSignatureCompleted,
          );
        default:
          return const SizedBox.shrink();
      }
    } else {
      switch (_currentStep) {
        case 0:
          return DesignationTypeStep(
            selectedType: _designationType,
            standardClauseType: _standardClauseType,
            freeClauseText: _freeClauseText,
            onTypeSelected: _onDesignationTypeSelected,
          );
        case 1:
          return SummaryStep(
            designation: designation,
            onConfirm: _nextStep,
            onEdit: (step) => _goToStep(step),
          );
        case 2:
          return SignatureStep(
            designation: designation,
            onSignatureCompleted: _onSignatureCompleted,
          );
        default:
          return const SizedBox.shrink();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isCompleted) {
      return _buildCompletionScreen(isDark);
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: Text(_stepTitles[_currentStep]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur de progression
          _buildProgressIndicator(isDark),

          // Contenu de l'étape
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalSteps,
              itemBuilder: (context, index) => _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _totalSteps - 1 ? AppSpacing.xs : 0,
              ),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompletionScreen(bool isDark) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              AppSpacing.verticalGapXxl,
              Text(
                'Désignation enregistrée',
                style: AppTypography.headlineLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapMd,
              Text(
                'Votre clause bénéficiaire a été mise à jour et signée électroniquement.',
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapMd,
              AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document PDF',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Disponible dans vos documents',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalGapMd,
              if (_signatureReference != null)
                Text(
                  'Référence: $_signatureReference',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              const Spacer(),
              AppButton(
                label: 'Retour à mes bénéficiaires',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              AppSpacing.verticalGapMd,
              AppButton(
                label: 'Voir le document',
                variant: AppButtonVariant.outline,
                leadingIcon: Icons.picture_as_pdf,
                onPressed: _openPdf,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
