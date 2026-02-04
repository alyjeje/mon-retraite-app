import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran des informations personnelles
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;
  bool _isSaved = false;
  bool _showOTPModal = false;
  String _otpCode = '';

  final _formData = {
    'firstName': 'Sophie',
    'lastName': 'Martin',
    'email': 'sophie.martin@email.com',
    'phone': '06 12 34 56 78',
    'address': '12 rue de la République',
    'postalCode': '75001',
    'city': 'Paris',
    'birthDate': '15/03/1981',
  };

  void _handleSave() {
    setState(() {
      _showOTPModal = true;
    });
  }

  void _handleOTPValidation() {
    if (_otpCode.length == 6) {
      setState(() {
        _showOTPModal = false;
        _isEditing = false;
        _isSaved = true;
        _otpCode = '';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showOTPModal) {
      return _buildOTPScreen(context, isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Informations personnelles'),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Modifier'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gérez vos informations de contact',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Success Alert
            if (_isSaved) ...[
              AlertCard(
                title: 'Modifications enregistrées',
                message: 'Vos informations ont été mises à jour avec succès.',
                type: AlertCardType.success,
              ),
              AppSpacing.verticalGapLg,
            ],

            // Identité
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identité',
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
                        child: _FormField(
                          label: 'Prénom',
                          value: _formData['firstName']!,
                          enabled: _isEditing,
                          onChanged: (v) => _formData['firstName'] = v,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: _FormField(
                          label: 'Nom',
                          value: _formData['lastName']!,
                          enabled: _isEditing,
                          onChanged: (v) => _formData['lastName'] = v,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMd,
                  _FormField(
                    label: 'Date de naissance',
                    value: _formData['birthDate']!,
                    enabled: false,
                    helperText: 'Non modifiable - Contactez un conseiller si besoin',
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,

            // Contact
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  _FormField(
                    label: 'Email',
                    value: _formData['email']!,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    helperText: 'Utilisé pour les notifications et documents',
                    onChanged: (v) => _formData['email'] = v,
                  ),
                  AppSpacing.verticalGapMd,
                  _FormField(
                    label: 'Téléphone mobile',
                    value: _formData['phone']!,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    helperText: 'Utilisé pour la validation sécurisée (OTP)',
                    onChanged: (v) => _formData['phone'] = v,
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,

            // Adresse
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adresse',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  _FormField(
                    label: 'Adresse',
                    value: _formData['address']!,
                    enabled: _isEditing,
                    onChanged: (v) => _formData['address'] = v,
                  ),
                  AppSpacing.verticalGapMd,
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: _FormField(
                          label: 'Code postal',
                          value: _formData['postalCode']!,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _formData['postalCode'] = v,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: _FormField(
                          label: 'Ville',
                          value: _formData['city']!,
                          enabled: _isEditing,
                          onChanged: (v) => _formData['city'] = v,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapLg,

            if (_isEditing) ...[
              AlertCard(
                title: 'Validation requise',
                message:
                    'Pour des raisons de sécurité, toute modification nécessitera une validation par code SMS.',
                type: AlertCardType.warning,
              ),
              AppSpacing.verticalGapLg,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Annuler',
                      variant: AppButtonVariant.outline,
                      onPressed: () => setState(() => _isEditing = false),
                    ),
                  ),
                  AppSpacing.horizontalGapMd,
                  Expanded(
                    child: AppButton(
                      label: 'Enregistrer',
                      variant: AppButtonVariant.primary,
                      leadingIcon: Icons.save_outlined,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalGapLg,
            ],

            // Information RGPD
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.info,
                      size: 20,
                    ),
                  ),
                  AppSpacing.horizontalGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protection de vos données',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        AppSpacing.verticalGapXxs,
                        Text(
                          'Vos données personnelles sont sécurisées et ne sont jamais partagées avec des tiers sans votre consentement.',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        AppSpacing.verticalGapSm,
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Page de confidentialité à venir'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'En savoir plus sur la protection des données',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalGapXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildOTPScreen(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _showOTPModal = false;
            _otpCode = '';
          }),
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
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            Text(
              'Un code de sécurité a été envoyé au 06 12 ** ** 78',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium.copyWith(
                      letterSpacing: 8,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _otpCode = value.replaceAll(RegExp(r'\D'), '');
                      });
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapLg,
            AppButton(
              label: 'Valider',
              variant: AppButtonVariant.primary,
              onPressed: _otpCode.length == 6 ? _handleOTPValidation : null,
            ),
            AppSpacing.verticalGapMd,
            AppButton(
              label: 'Annuler',
              variant: AppButtonVariant.text,
              onPressed: () => setState(() {
                _showOTPModal = false;
                _otpCode = '';
              }),
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
}

class _FormField extends StatefulWidget {
  final String label;
  final String value;
  final bool enabled;
  final String? helperText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.label,
    required this.value,
    this.enabled = true,
    this.helperText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_FormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          style: AppTypography.bodyMedium.copyWith(
            color: widget.enabled
                ? (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)
                : (isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.enabled
                ? (isDark ? AppColors.cardDark : AppColors.cardLight)
                : (isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: widget.onChanged,
        ),
        if (widget.helperText != null) ...[
          AppSpacing.verticalGapXxs,
          Text(
            widget.helperText!,
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
}
