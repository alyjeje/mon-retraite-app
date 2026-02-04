import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

/// Écran de changement de coordonnées bancaires (RIB)
/// Flow: RIB actuel → Nouveau RIB → Upload justificatif → Récap → OTP → Succès
class ChangeBankDetailsScreen extends StatefulWidget {
  const ChangeBankDetailsScreen({super.key});

  @override
  State<ChangeBankDetailsScreen> createState() => _ChangeBankDetailsScreenState();
}

class _ChangeBankDetailsScreenState extends State<ChangeBankDetailsScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSuccess = false;

  // Données du nouveau RIB
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();

  // Document justificatif
  File? _ribDocument;
  String? _ribDocumentName;

  // OTP
  String _otpCode = '';

  // Validation
  String? _ibanError;
  String? _bicError;

  @override
  void initState() {
    super.initState();
    // Pré-remplir le titulaire avec le nom de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      _accountHolderController.text = provider.user.fullName;
    });
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _bicController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  // Validation IBAN français simplifié
  bool _isValidIban(String iban) {
    final cleanIban = iban.replaceAll(' ', '').toUpperCase();
    if (!cleanIban.startsWith('FR')) return false;
    if (cleanIban.length != 27) return false;
    return RegExp(r'^FR\d{2}\d{10}[A-Z0-9]{11}\d{2}$').hasMatch(cleanIban);
  }

  // Validation BIC
  bool _isValidBic(String bic) {
    final cleanBic = bic.replaceAll(' ', '').toUpperCase();
    return RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(cleanBic);
  }

  // Formater l'IBAN avec espaces
  String _formatIban(String iban) {
    final clean = iban.replaceAll(' ', '').toUpperCase();
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  void _validateIban(String value) {
    setState(() {
      if (value.isEmpty) {
        _ibanError = null;
      } else if (!_isValidIban(value)) {
        _ibanError = 'IBAN invalide. Format attendu: FR76 XXXX XXXX XXXX XXXX XXXX XXX';
      } else {
        _ibanError = null;
      }
    });
  }

  void _validateBic(String value) {
    setState(() {
      if (value.isEmpty) {
        _bicError = null;
      } else if (!_isValidBic(value)) {
        _bicError = 'BIC invalide. Format attendu: BNPAFRPP ou BNPAFRPPXXX';
      } else {
        _bicError = null;
      }
    });
  }

  Future<void> _pickDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _ribDocument = File(image.path);
          _ribDocumentName = image.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection du document'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _ribDocument = File(image.path);
          _ribDocumentName = 'photo_rib.jpg';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la prise de photo'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleOTPValidation() {
    if (_otpCode.length == 6) {
      setState(() => _isLoading = true);

      // Simulation de la validation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });
        }
      });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // RIB actuel - toujours OK
        return true;
      case 1: // Nouveau RIB
        return _isValidIban(_ibanController.text) &&
            _isValidBic(_bicController.text) &&
            _accountHolderController.text.isNotEmpty;
      case 2: // Upload document
        return _ribDocument != null;
      case 3: // Récap
        return true;
      default:
        return true;
    }
  }

  void _onContinue() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Passer à l'écran OTP
      setState(() => _currentStep = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSuccess) {
      return _buildSuccessScreen(context);
    }

    if (_currentStep == 4) {
      return _buildOTPScreen(context, isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Modifier mon RIB'),
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
    const steps = 4;
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
        return _buildCurrentRibStep(context);
      case 1:
        return _buildNewRibStep(context);
      case 2:
        return _buildUploadDocumentStep(context);
      case 3:
        return _buildRecapStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCurrentRibStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final defaultAccount = provider.bankAccounts.firstWhere(
      (a) => a.isDefault,
      orElse: () => provider.bankAccounts.first,
    );

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre RIB actuel',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Voici les coordonnées bancaires actuellement enregistrées pour vos prélèvements.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Carte RIB actuel
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            defaultAccount.bankName,
                            style: AppTypography.labelLarge.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (defaultAccount.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Text(
                                'Principal',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapLg,
                _buildInfoRow('Titulaire', defaultAccount.accountHolder, isDark),
                AppSpacing.verticalGapSm,
                _buildInfoRow('IBAN', defaultAccount.maskedIban, isDark),
                AppSpacing.verticalGapSm,
                _buildInfoRow('BIC', defaultAccount.bic, isDark),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Autres RIB si présents
          if (provider.bankAccounts.length > 1) ...[
            Text(
              'Autres RIB enregistrés',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            ...provider.bankAccounts.where((a) => !a.isDefault).map((account) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.textTertiaryLight,
                        size: 20,
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.bankName,
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              account.maskedIban,
                              style: AppTypography.caption.copyWith(
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
        ],
      ),
    );
  }

  Widget _buildNewRibStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouveau RIB',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Saisissez les coordonnées de votre nouveau compte bancaire.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Formulaire
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titulaire
                _buildTextField(
                  label: 'Titulaire du compte',
                  controller: _accountHolderController,
                  hint: 'Nom et prénom',
                  prefixIcon: Icons.person_outline,
                  isDark: isDark,
                ),
                AppSpacing.verticalGapMd,

                // IBAN
                _buildTextField(
                  label: 'IBAN',
                  controller: _ibanController,
                  hint: 'FR76 XXXX XXXX XXXX XXXX XXXX XXX',
                  prefixIcon: Icons.credit_card,
                  errorText: _ibanError,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                    LengthLimitingTextInputFormatter(34),
                  ],
                  onChanged: (value) {
                    _validateIban(value);
                  },
                  isDark: isDark,
                ),
                AppSpacing.verticalGapMd,

                // BIC
                _buildTextField(
                  label: 'BIC',
                  controller: _bicController,
                  hint: 'BNPAFRPP',
                  prefixIcon: Icons.business,
                  errorText: _bicError,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (value) {
                    _validateBic(value);
                  },
                  isDark: isDark,
                ),
                AppSpacing.verticalGapMd,

                // Nom de la banque
                _buildTextField(
                  label: 'Nom de la banque (optionnel)',
                  controller: _bankNameController,
                  hint: 'Ex: BNP Paribas',
                  prefixIcon: Icons.account_balance,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Info sécurité
          AlertCard(
            title: 'Compte à votre nom',
            message:
                'Le compte bancaire doit être à votre nom. Tout changement de titulaire nécessite des justificatifs supplémentaires.',
            type: AlertCardType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Justificatif de RIB',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Pour valider votre changement de RIB, veuillez fournir un justificatif.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Zone de téléchargement
          if (_ribDocument == null) ...[
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  Text(
                    'Télécharger votre RIB',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapXs,
                  Text(
                    'Photo ou scan de votre RIB bancaire',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Galerie',
                          variant: AppButtonVariant.outline,
                          leadingIcon: Icons.photo_library_outlined,
                          onPressed: _pickDocument,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: AppButton(
                          label: 'Caméra',
                          variant: AppButtonVariant.outline,
                          leadingIcon: Icons.camera_alt_outlined,
                          onPressed: _takePhoto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Document sélectionné
            AppCard(
              border: Border.all(color: AppColors.success, width: 2),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _ribDocument!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ribDocumentName ?? 'Document',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.verticalGapXxs,
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                                AppSpacing.horizontalGapXs,
                                Text(
                                  'Document prêt',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondaryLight,
                        onPressed: () {
                          setState(() {
                            _ribDocument = null;
                            _ribDocumentName = null;
                          });
                        },
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMd,
                  AppButton(
                    label: 'Changer de document',
                    variant: AppButtonVariant.text,
                    onPressed: _pickDocument,
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.verticalGapLg,

          // Conseils
          AlertCard(
            title: 'Conseils pour un bon document',
            message:
                '• Le document doit être lisible et non flou\n• Les informations bancaires doivent être visibles\n• Formats acceptés: photo ou scan',
            type: AlertCardType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final currentAccount = provider.bankAccounts.firstWhere(
      (a) => a.isDefault,
      orElse: () => provider.bankAccounts.first,
    );

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Vérifiez les informations avant de valider.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapLg,

          // Ancien RIB
          Text(
            'RIB ACTUEL',
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.verticalGapSm,
          AppCard(
            backgroundColor: isDark
                ? AppColors.cardDark.withValues(alpha: 0.5)
                : AppColors.backgroundLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppColors.textTertiaryLight, size: 20),
                    AppSpacing.horizontalGapSm,
                    Text(
                      currentAccount.bankName,
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapSm,
                Text(
                  currentAccount.maskedIban,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapMd,

          // Flèche de transition
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_downward,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          AppSpacing.verticalGapMd,

          // Nouveau RIB
          Text(
            'NOUVEAU RIB',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalGapSm,
          AppCard(
            border: Border.all(color: AppColors.primary, width: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                    AppSpacing.horizontalGapSm,
                    Text(
                      _bankNameController.text.isNotEmpty
                          ? _bankNameController.text
                          : 'Nouvelle banque',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapMd,
                _buildRecapRow('Titulaire', _accountHolderController.text, isDark),
                AppSpacing.verticalGapXs,
                _buildRecapRow('IBAN', _formatIban(_ibanController.text), isDark),
                AppSpacing.verticalGapXs,
                _buildRecapRow('BIC', _bicController.text.toUpperCase(), isDark),
              ],
            ),
          ),
          AppSpacing.verticalGapMd,

          // Document
          Text(
            'JUSTIFICATIF',
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.verticalGapSm,
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                AppSpacing.horizontalGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ribDocumentName ?? 'RIB',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 14,
                          ),
                          AppSpacing.horizontalGapXxs,
                          Text(
                            'Document joint',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Avertissement
          AlertCard(
            title: 'Validation requise',
            message:
                'Pour des raisons de sécurité, vous devrez confirmer ce changement par un code SMS envoyé sur votre téléphone.',
            type: AlertCardType.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildOTPScreen(BuildContext context, bool isDark) {
    final provider = context.watch<AppProvider>();
    final phone = provider.user.phone;
    final maskedPhone = phone.replaceRange(3, phone.length - 2, ' ** ** ');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentStep = 3),
        ),
        title: const Text('Validation'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            AppSpacing.verticalGapLg,
            Text(
              'Validation sécurisée',
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            Text(
              'Un code de sécurité a été envoyé au $maskedPhone',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapXl,
            AppCard(
              child: Column(
                children: [
                  Text(
                    'Code de sécurité (6 chiffres)',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium.copyWith(
                      letterSpacing: 8,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      setState(() {
                        _otpCode = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapLg,
            AppButton(
              label: 'Valider le changement',
              variant: AppButtonVariant.primary,
              isLoading: _isLoading,
              onPressed: _otpCode.length == 6 ? _handleOTPValidation : null,
            ),
            AppSpacing.verticalGapMd,
            AppButton(
              label: 'Annuler',
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.pop(context),
            ),
            AppSpacing.verticalGapLg,
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code renvoyé'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      body: SuccessView(
        title: 'RIB modifié avec succès !',
        message:
            'Vos nouvelles coordonnées bancaires ont été enregistrées. Elles seront utilisées pour vos prochains prélèvements.',
        actionLabel: 'Retour au profil',
        onAction: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
              child: AppButton(
                label: _currentStep == 3 ? 'Valider' : 'Continuer',
                isEnabled: canProceed,
                onPressed: canProceed ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRecapRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool isDark,
    String? errorText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20),
            errorText: errorText,
            filled: true,
            fillColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
