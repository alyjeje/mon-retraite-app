import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/beneficiary_designation_model.dart';
import '../../../widgets/widgets.dart';
import '../services/pdf_generator_service.dart';

/// Étape 5: Signature électronique avec OTP
class SignatureStep extends StatefulWidget {
  final BeneficiaryDesignation designation;
  final Function(String reference) onSignatureCompleted;

  const SignatureStep({
    super.key,
    required this.designation,
    required this.onSignatureCompleted,
  });

  @override
  State<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends State<SignatureStep> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isOtpSent = false;
  bool _isVerifying = false;
  bool _isGeneratingPdf = false;
  bool _hasError = false;
  String? _errorMessage;
  int _resendTimer = 0;
  Timer? _timer;
  String _simulatedOtp = '';

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    // Simuler l'envoi d'un OTP
    setState(() {
      _simulatedOtp = _generateOtp();
      _isOtpSent = true;
      _hasError = false;
      _errorMessage = null;
      _resendTimer = 60;
    });

    // Afficher le code simulé (en production, ceci serait envoyé par SMS/email)
    _showOtpSimulationDialog();

    // Démarrer le timer de renvoi
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });

    // Focus sur le premier champ
    _focusNodes[0].requestFocus();
  }

  String _generateOtp() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  void _showOtpSimulationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone_android, color: AppColors.primary),
            AppSpacing.horizontalGapSm,
            const Text('Code de vérification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Simulation: En production, ce code serait envoyé par SMS au numéro se terminant par **42.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.verticalGapMd,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Text(
                _simulatedOtp,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Vérifier si tous les champs sont remplis
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }

    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
  }

  void _onOtpKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isVerifying = true);

    // Simuler une vérification
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp == _simulatedOtp) {
      // OTP correct - générer le PDF
      await _generatePdfAndSign();
    } else {
      setState(() {
        _isVerifying = false;
        _hasError = true;
        _errorMessage = 'Code incorrect. Veuillez réessayer.';
        // Vider les champs
        for (final controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _generatePdfAndSign() async {
    setState(() {
      _isVerifying = false;
      _isGeneratingPdf = true;
    });

    try {
      // Générer le PDF
      await PdfGeneratorService.generateBeneficiaryDesignationPdf(
        widget.designation,
      );

      // Générer une référence unique de signature
      final dateFormat = DateFormat('yyyyMMddHHmmss');
      final reference = 'SIG-${dateFormat.format(DateTime.now())}-${Random().nextInt(9999).toString().padLeft(4, '0')}';

      // Appeler le callback avec la référence
      widget.onSignatureCompleted(reference);
    } catch (e) {
      setState(() {
        _isGeneratingPdf = false;
        _hasError = true;
        _errorMessage = 'Erreur lors de la génération du document: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signature électronique',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Pour valider votre désignation de bénéficiaire, confirmez votre identité avec un code de vérification.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapXl,

          // Étapes de signature
          _SignatureTimeline(
            currentStep: _isOtpSent
                ? (_isGeneratingPdf ? 2 : 1)
                : 0,
          ),
          AppSpacing.verticalGapXl,

          if (!_isOtpSent) ...[
            // Avant envoi du code
            AppCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.verticalGapLg,
                  Text(
                    'Vérification par code SMS',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapSm,
                  Text(
                    'Un code à 6 chiffres sera envoyé au numéro se terminant par **42',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalGapXl,
                  AppButton(
                    label: 'Recevoir le code',
                    variant: AppButtonVariant.primary,
                    leadingIcon: Icons.sms_outlined,
                    onPressed: _sendOtp,
                  ),
                ],
              ),
            ),
          ] else if (_isGeneratingPdf) ...[
            // Génération du PDF en cours
            AppCard(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  AppSpacing.verticalGapLg,
                  Text(
                    'Génération du document...',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapSm,
                  Text(
                    'Votre document de désignation de bénéficiaire est en cours de création.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Saisie du code OTP
            AppCard(
              child: Column(
                children: [
                  Text(
                    'Entrez le code reçu',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapXl,

                  // Champs OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 45,
                        height: 56,
                        margin: EdgeInsets.only(
                          right: index < 5 ? AppSpacing.xs : 0,
                        ),
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onOtpKeyPressed(index, event),
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTypography.headlineMedium.copyWith(
                              color: _hasError
                                  ? AppColors.error
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMd,
                                borderSide: BorderSide(
                                  color: _hasError
                                      ? AppColors.error
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMd,
                                borderSide: BorderSide(
                                  color: _hasError
                                      ? AppColors.error
                                      : AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _onOtpChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_hasError && _errorMessage != null) ...[
                    AppSpacing.verticalGapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                        AppSpacing.horizontalGapXs,
                        Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_isVerifying) ...[
                    AppSpacing.verticalGapMd,
                    const CircularProgressIndicator(),
                  ],

                  AppSpacing.verticalGapXl,

                  // Renvoyer le code
                  if (_resendTimer > 0)
                    Text(
                      'Renvoyer le code dans $_resendTimer s',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _sendOtp,
                      child: Text(
                        'Renvoyer le code',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          AppSpacing.verticalGapLg,

          // Informations légales
          AlertCard(
            title: 'Valeur juridique',
            message:
                'La signature électronique a la même valeur juridique qu\'une signature manuscrite conformément au règlement eIDAS et à l\'article 1367 du Code civil.',
            type: AlertCardType.info,
          ),

          AppSpacing.verticalGapXxl,
        ],
      ),
    );
  }
}

/// Timeline des étapes de signature
class _SignatureTimeline extends StatelessWidget {
  final int currentStep;

  const _SignatureTimeline({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      ('Envoi du code', Icons.send_outlined),
      ('Vérification', Icons.verified_outlined),
      ('Signature', Icons.draw_outlined),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Ligne de connexion
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? AppColors.success
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          );
        }

        // Étape
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final step = steps[stepIndex];

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : (isCurrent
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.cardDark
                            : AppColors.backgroundLight)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? Colors.transparent
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Icon(
                        step.$2,
                        color: isCurrent
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        size: 20,
                      ),
              ),
            ),
            AppSpacing.verticalGapXs,
            Text(
              step.$1,
              style: AppTypography.caption.copyWith(
                color: isCompleted || isCurrent
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
                fontWeight:
                    isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}
