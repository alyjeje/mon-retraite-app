import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/beneficiary_designation_model.dart';
import '../../../widgets/widgets.dart';

/// Étape 1: Choix du type de désignation
class DesignationTypeStep extends StatefulWidget {
  final DesignationType selectedType;
  final StandardClauseType? standardClauseType;
  final String? freeClauseText;
  final Function(DesignationType type,
      {StandardClauseType? standardClause, String? freeClause}) onTypeSelected;

  const DesignationTypeStep({
    super.key,
    required this.selectedType,
    this.standardClauseType,
    this.freeClauseText,
    required this.onTypeSelected,
  });

  @override
  State<DesignationTypeStep> createState() => _DesignationTypeStepState();
}

class _DesignationTypeStepState extends State<DesignationTypeStep> {
  late DesignationType _selectedType;
  StandardClauseType? _selectedStandardClause;
  final TextEditingController _freeClauseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStandardClause = widget.standardClauseType;
    _freeClauseController.text = widget.freeClauseText ?? '';
  }

  @override
  void dispose() {
    _freeClauseController.dispose();
    super.dispose();
  }

  void _onContinue() {
    switch (_selectedType) {
      case DesignationType.nominative:
        widget.onTypeSelected(_selectedType);
        break;
      case DesignationType.standardClause:
        if (_selectedStandardClause != null) {
          widget.onTypeSelected(_selectedType,
              standardClause: _selectedStandardClause);
        }
        break;
      case DesignationType.freeClause:
        if (_freeClauseController.text.trim().isNotEmpty) {
          widget.onTypeSelected(_selectedType,
              freeClause: _freeClauseController.text.trim());
        }
        break;
    }
  }

  bool get _canContinue {
    switch (_selectedType) {
      case DesignationType.nominative:
        return true;
      case DesignationType.standardClause:
        return _selectedStandardClause != null;
      case DesignationType.freeClause:
        return _freeClauseController.text.trim().isNotEmpty;
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
            'Comment souhaitez-vous désigner vos bénéficiaires ?',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          Text(
            'En cas de décès, le capital de votre contrat retraite sera versé aux bénéficiaires que vous désignez.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapXl,

          // Option 1: Bénéficiaires nominatifs
          _DesignationTypeCard(
            title: 'Bénéficiaires nominatifs',
            description:
                'Désignez précisément vos bénéficiaires avec leurs nom, prénom et date de naissance.',
            icon: Icons.people_alt_outlined,
            isSelected: _selectedType == DesignationType.nominative,
            onTap: () => setState(() => _selectedType = DesignationType.nominative),
            features: const [
              'Identification précise des bénéficiaires',
              'Répartition par pourcentages ou parts égales',
              'Possibilité de démembrement (usufruit/nue-propriété)',
              'Définition de rangs de priorité',
            ],
          ),
          AppSpacing.verticalGapMd,

          // Option 2: Clause type
          _DesignationTypeCard(
            title: 'Clause type',
            description:
                'Utilisez une formulation standard prédéfinie.',
            icon: Icons.description_outlined,
            isSelected: _selectedType == DesignationType.standardClause,
            onTap: () => setState(() => _selectedType = DesignationType.standardClause),
            features: const [
              'Formulations juridiques validées',
              'Simplicité et rapidité',
              'Adaptation automatique à votre situation familiale',
            ],
          ),

          // Afficher les options de clause type si sélectionné
          if (_selectedType == DesignationType.standardClause) ...[
            AppSpacing.verticalGapMd,
            _buildStandardClauseOptions(isDark),
          ],
          AppSpacing.verticalGapMd,

          // Option 3: Clause libre
          _DesignationTypeCard(
            title: 'Clause libre',
            description:
                'Rédigez vous-même votre clause bénéficiaire.',
            icon: Icons.edit_note_outlined,
            isSelected: _selectedType == DesignationType.freeClause,
            onTap: () => setState(() => _selectedType = DesignationType.freeClause),
            features: const [
              'Liberté totale de rédaction',
              'Personnalisation complète',
              'Idéal pour les situations particulières',
            ],
          ),

          // Afficher le champ de texte si clause libre sélectionnée
          if (_selectedType == DesignationType.freeClause) ...[
            AppSpacing.verticalGapMd,
            _buildFreeClauseInput(isDark),
          ],

          AppSpacing.verticalGapXxl,

          // Bouton continuer
          AppButton(
            label: 'Continuer',
            variant: AppButtonVariant.primary,
            isEnabled: _canContinue,
            onPressed: _canContinue ? _onContinue : null,
          ),

          AppSpacing.verticalGapXl,
        ],
      ),
    );
  }

  Widget _buildStandardClauseOptions(bool isDark) {
    return AppCard(
      backgroundColor:
          isDark ? AppColors.cardDark : AppColors.primaryLighter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez une clause type',
            style: AppTypography.labelLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          ...StandardClauseType.values.map((clause) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _StandardClauseOption(
                  clause: clause,
                  isSelected: _selectedStandardClause == clause,
                  onTap: () =>
                      setState(() => _selectedStandardClause = clause),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFreeClauseInput(bool isDark) {
    return AppCard(
      backgroundColor:
          isDark ? AppColors.cardDark : AppColors.primaryLighter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rédigez votre clause',
            style: AppTypography.labelLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,
          Text(
            'Soyez le plus précis possible pour éviter toute ambiguïté.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          TextFormField(
            controller: _freeClauseController,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Ex: Je désigne comme bénéficiaire mon conjoint, Madame/Monsieur [Nom Prénom], né(e) le [date] à [lieu]...',
              filled: true,
              fillColor: isDark ? AppColors.inputBackgroundDark : AppColors.inputBackgroundLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          AlertCard(
            title: 'Conseil',
            message:
                'Pour une clause libre, nous vous recommandons de préciser : nom, prénom, date et lieu de naissance de chaque bénéficiaire.',
            type: AlertCardType.info,
          ),
        ],
      ),
    );
  }
}

/// Carte pour chaque type de désignation
class _DesignationTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final List<String> features;

  const _DesignationTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.shadowMd : null,
        ),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.backgroundLight),
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                  AppSpacing.horizontalGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        AppSpacing.verticalGapXxs,
                        Text(
                          description,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    onChanged: (_) => onTap(),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              if (isSelected) ...[
                AppSpacing.verticalGapMd,
                const Divider(),
                AppSpacing.verticalGapSm,
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          AppSpacing.horizontalGapSm,
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Option de clause type
class _StandardClauseOption extends StatelessWidget {
  final StandardClauseType clause;
  final bool isSelected;
  final VoidCallback onTap;

  const _StandardClauseOption({
    required this.clause,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clause.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                  AppSpacing.verticalGapXxs,
                  Text(
                    clause.description,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
