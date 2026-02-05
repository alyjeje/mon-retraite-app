import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/beneficiary_designation_model.dart';
import '../../../widgets/widgets.dart';

/// Étape 2: Ajout des bénéficiaires nominatifs
class NominativeBeneficiariesStep extends StatefulWidget {
  final List<NominativeBeneficiary> beneficiaries;
  final Function(List<NominativeBeneficiary>) onBeneficiariesUpdated;
  final VoidCallback onNext;

  const NominativeBeneficiariesStep({
    super.key,
    required this.beneficiaries,
    required this.onBeneficiariesUpdated,
    required this.onNext,
  });

  @override
  State<NominativeBeneficiariesStep> createState() =>
      _NominativeBeneficiariesStepState();
}

class _NominativeBeneficiariesStepState
    extends State<NominativeBeneficiariesStep> {
  late List<NominativeBeneficiary> _beneficiaries;

  @override
  void initState() {
    super.initState();
    _beneficiaries = List.from(widget.beneficiaries);
  }

  void _addBeneficiary() async {
    final result = await showModalBottomSheet<NominativeBeneficiary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BeneficiaryFormSheet(
        existingBeneficiaries: _beneficiaries,
      ),
    );

    if (result != null) {
      setState(() {
        _beneficiaries.add(result);
      });
      widget.onBeneficiariesUpdated(_beneficiaries);
    }
  }

  void _editBeneficiary(int index) async {
    final result = await showModalBottomSheet<NominativeBeneficiary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BeneficiaryFormSheet(
        beneficiary: _beneficiaries[index],
        existingBeneficiaries: _beneficiaries,
      ),
    );

    if (result != null) {
      setState(() {
        _beneficiaries[index] = result;
      });
      widget.onBeneficiariesUpdated(_beneficiaries);
    }
  }

  void _deleteBeneficiary(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le bénéficiaire ?'),
        content: Text(
          'Voulez-vous vraiment supprimer ${_beneficiaries[index].fullName} de la liste ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _beneficiaries.removeAt(index);
              });
              widget.onBeneficiariesUpdated(_beneficiaries);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajoutez vos bénéficiaires',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapSm,
                Text(
                  'Identifiez précisément chaque personne que vous souhaitez désigner comme bénéficiaire.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Liste des bénéficiaires
                if (_beneficiaries.isEmpty) ...[
                  _EmptyBeneficiariesCard(onAdd: _addBeneficiary),
                ] else ...[
                  ..._beneficiaries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final beneficiary = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _BeneficiaryCard(
                        beneficiary: beneficiary,
                        onEdit: () => _editBeneficiary(index),
                        onDelete: () => _deleteBeneficiary(index),
                      ),
                    );
                  }),
                  AppSpacing.verticalGapMd,
                  AppButton(
                    label: 'Ajouter un bénéficiaire',
                    variant: AppButtonVariant.outline,
                    leadingIcon: Icons.add,
                    onPressed: _addBeneficiary,
                  ),
                ],

                AppSpacing.verticalGapLg,

                // Information sur le démembrement
                AlertCard(
                  title: 'Le démembrement',
                  message:
                      'Vous pouvez attribuer l\'usufruit à une personne (ex: conjoint) et la nue-propriété à d\'autres (ex: enfants). Cela se configure à l\'étape suivante.',
                  type: AlertCardType.info,
                ),
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
              isEnabled: _beneficiaries.isNotEmpty,
              onPressed: _beneficiaries.isNotEmpty ? widget.onNext : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte d'un bénéficiaire
class _BeneficiaryCard extends StatelessWidget {
  final NominativeBeneficiary beneficiary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BeneficiaryCard({
    required this.beneficiary,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Center(
                  child: Text(
                    '${beneficiary.firstName[0]}${beneficiary.lastName[0]}'.toUpperCase(),
                    style: AppTypography.labelLarge.copyWith(
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
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      beneficiary.relationshipLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          const Divider(height: 1),
          AppSpacing.verticalGapMd,
          _InfoRow(
            label: 'Date de naissance',
            value: dateFormat.format(beneficiary.birthDate),
          ),
          if (beneficiary.birthPlace != null) ...[
            AppSpacing.verticalGapXs,
            _InfoRow(
              label: 'Lieu de naissance',
              value: beneficiary.birthPlace!,
            ),
          ],
          if (beneficiary.address != null) ...[
            AppSpacing.verticalGapXs,
            _InfoRow(
              label: 'Adresse',
              value:
                  '${beneficiary.address}, ${beneficiary.postalCode} ${beneficiary.city}',
            ),
          ],
          if (beneficiary.dismembermentType != DismembermentType.none) ...[
            AppSpacing.verticalGapSm,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentYellowLight,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                beneficiary.dismembermentLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte vide pour ajouter le premier bénéficiaire
class _EmptyBeneficiariesCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyBeneficiariesCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onAdd,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.verticalGapMd,
          Text(
            'Ajouter un bénéficiaire',
            style: AppTypography.labelLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapXs,
          Text(
            'Appuyez ici pour désigner votre premier bénéficiaire',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Sheet pour ajouter/modifier un bénéficiaire
class _BeneficiaryFormSheet extends StatefulWidget {
  final NominativeBeneficiary? beneficiary;
  final List<NominativeBeneficiary> existingBeneficiaries;

  const _BeneficiaryFormSheet({
    this.beneficiary,
    required this.existingBeneficiaries,
  });

  @override
  State<_BeneficiaryFormSheet> createState() => _BeneficiaryFormSheetState();
}

class _BeneficiaryFormSheetState extends State<_BeneficiaryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  late TextEditingController _otherRelationshipController;

  DateTime? _birthDate;
  BeneficiaryRelationship _relationship = BeneficiaryRelationship.spouse;
  int _rank = 1;

  bool get isEditing => widget.beneficiary != null;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.beneficiary?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.beneficiary?.lastName ?? '');
    _birthPlaceController =
        TextEditingController(text: widget.beneficiary?.birthPlace ?? '');
    _addressController =
        TextEditingController(text: widget.beneficiary?.address ?? '');
    _postalCodeController =
        TextEditingController(text: widget.beneficiary?.postalCode ?? '');
    _cityController =
        TextEditingController(text: widget.beneficiary?.city ?? '');
    _otherRelationshipController =
        TextEditingController(text: widget.beneficiary?.otherRelationship ?? '');

    _birthDate = widget.beneficiary?.birthDate;
    _relationship = widget.beneficiary?.relationship ?? BeneficiaryRelationship.spouse;
    _rank = widget.beneficiary?.rank ?? 1;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthPlaceController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _otherRelationshipController.dispose();
    super.dispose();
  }

  void _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1980),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _birthDate == null) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date de naissance'),
          ),
        );
      }
      return;
    }

    final beneficiary = NominativeBeneficiary(
      id: widget.beneficiary?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDate!,
      birthPlace: _birthPlaceController.text.trim().isNotEmpty
          ? _birthPlaceController.text.trim()
          : null,
      relationship: _relationship,
      otherRelationship: _relationship == BeneficiaryRelationship.other
          ? _otherRelationshipController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      postalCode: _postalCodeController.text.trim().isNotEmpty
          ? _postalCodeController.text.trim()
          : null,
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : null,
      rank: _rank,
      percentage: 0, // Sera défini à l'étape suivante
      dismembermentType: widget.beneficiary?.dismembermentType ?? DismembermentType.none,
    );

    Navigator.pop(context, beneficiary);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Barre de poignée
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
          ),

          // En-tête
          Padding(
            padding: AppSpacing.screenPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Modifier le bénéficiaire' : 'Nouveau bénéficiaire',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Identité
                    Text(
                      'Identité',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    AppInput(
                      label: 'Prénom *',
                      controller: _firstNameController,
                      hint: 'Ex: Jean',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prénom est requis';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.verticalGapMd,
                    AppInput(
                      label: 'Nom *',
                      controller: _lastNameController,
                      hint: 'Ex: Dupont',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.verticalGapMd,

                    // Date de naissance
                    Text(
                      'Date de naissance *',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXs,
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.inputBackgroundDark
                              : AppColors.inputBackgroundLight,
                          borderRadius: AppSpacing.inputRadius,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            AppSpacing.horizontalGapMd,
                            Text(
                              _birthDate != null
                                  ? dateFormat.format(_birthDate!)
                                  : 'Sélectionner une date',
                              style: AppTypography.bodyLarge.copyWith(
                                color: _birthDate != null
                                    ? (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight)
                                    : (isDark
                                        ? AppColors.textTertiaryDark
                                        : AppColors.textTertiaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.verticalGapMd,

                    AppInput(
                      label: 'Lieu de naissance',
                      controller: _birthPlaceController,
                      hint: 'Ex: Paris',
                    ),
                    AppSpacing.verticalGapXl,

                    // Lien de parenté
                    Text(
                      'Lien de parenté',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    AppDropdown<BeneficiaryRelationship>(
                      label: 'Relation *',
                      value: _relationship,
                      items: BeneficiaryRelationship.values
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _relationship = value);
                        }
                      },
                    ),
                    if (_relationship == BeneficiaryRelationship.other) ...[
                      AppSpacing.verticalGapMd,
                      AppInput(
                        label: 'Précisez la relation *',
                        controller: _otherRelationshipController,
                        hint: 'Ex: Ami proche',
                        validator: (value) {
                          if (_relationship == BeneficiaryRelationship.other &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Veuillez préciser la relation';
                          }
                          return null;
                        },
                      ),
                    ],
                    AppSpacing.verticalGapXl,

                    // Rang de priorité
                    Text(
                      'Rang de priorité',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapSm,
                    Text(
                      'Les bénéficiaires de rang 1 sont prioritaires. Si aucun n\'est en vie au moment du décès, le capital est versé aux bénéficiaires de rang 2, etc.',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    Row(
                      children: List.generate(3, (index) {
                        final rank = index + 1;
                        final isSelected = _rank == rank;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < 2 ? AppSpacing.sm : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _rank = rank),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.cardDark
                                          : AppColors.backgroundLight),
                                  borderRadius: AppSpacing.borderRadiusMd,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Rang $rank',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    AppSpacing.verticalGapXl,

                    // Adresse (optionnel)
                    Text(
                      'Adresse (optionnel)',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapMd,
                    AppInput(
                      label: 'Adresse',
                      controller: _addressController,
                      hint: 'Ex: 15 rue de la Paix',
                    ),
                    AppSpacing.verticalGapMd,
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppInput(
                            label: 'Code postal',
                            controller: _postalCodeController,
                            hint: 'Ex: 75001',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        AppSpacing.horizontalGapMd,
                        Expanded(
                          flex: 3,
                          child: AppInput(
                            label: 'Ville',
                            controller: _cityController,
                            hint: 'Ex: Paris',
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapXxl,
                  ],
                ),
              ),
            ),
          ),

          // Bouton valider
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
                label: isEditing ? 'Enregistrer' : 'Ajouter le bénéficiaire',
                variant: AppButtonVariant.primary,
                onPressed: _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
