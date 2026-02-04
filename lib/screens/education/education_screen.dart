import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Hub pédagogique "Comprendre ma retraite"
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Comprendre ma retraite'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Text(
              'Tout savoir sur l\'épargne retraite',
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            Text(
              'Des explications simples pour comprendre vos produits et prendre les bonnes décisions.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Les produits
            _SectionTitle(title: 'Les produits d\'épargne retraite'),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Le PERIN',
              subtitle: 'Plan d\'Épargne Retraite Individuel',
              description: 'Le PERIN est un produit d\'épargne retraite individuel qui vous permet de vous constituer un complément de revenus pour la retraite tout en bénéficiant d\'avantages fiscaux.',
              icon: Icons.person_outline,
              color: AppColors.perinColor,
              highlights: [
                'Versements déductibles du revenu imposable',
                'Sortie en capital ou en rente',
                'Cas de déblocage anticipé possibles',
              ],
              onTap: () => _showDetailSheet(context, 'PERIN'),
            ),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Le PERO',
              subtitle: 'Plan d\'Épargne Retraite Obligatoire',
              description: 'Le PERO est mis en place par votre entreprise. Il peut être alimenté par des versements obligatoires de l\'employeur et du salarié.',
              icon: Icons.business_outlined,
              color: AppColors.peroColor,
              highlights: [
                'Versements de l\'employeur',
                'Abondement possible',
                'Portabilité en cas de changement d\'emploi',
              ],
              onTap: () => _showDetailSheet(context, 'PERO'),
            ),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'L\'Épargne Salariale',
              subtitle: 'PEE, PERCO, intéressement...',
              description: 'L\'épargne salariale regroupe les dispositifs permettant aux salariés de se constituer une épargne avec l\'aide de leur entreprise.',
              icon: Icons.groups_outlined,
              color: AppColors.ereColor,
              highlights: [
                'Participation et intéressement',
                'Abondement de l\'employeur',
                'Disponibilité selon le produit',
              ],
              onTap: () => _showDetailSheet(context, 'Épargne Salariale'),
            ),
            AppSpacing.verticalGapXl,

            // La fiscalité
            _SectionTitle(title: 'La fiscalité'),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Avantages fiscaux à l\'entrée',
              subtitle: 'Réduisez vos impôts',
              description: 'Vos versements volontaires sur le PERIN sont déductibles de votre revenu imposable, dans la limite d\'un plafond annuel.',
              icon: Icons.savings_outlined,
              color: AppColors.success,
              highlights: [
                'Plafond = 10% des revenus N-1',
                'Report des plafonds non utilisés',
                'Économie d\'impôt immédiate',
              ],
              onTap: () => _showDetailSheet(context, 'Fiscalité'),
            ),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Fiscalité à la sortie',
              subtitle: 'Ce que vous percevrez',
              description: 'À la retraite, votre épargne est imposée selon les modalités de sortie choisies (capital ou rente).',
              icon: Icons.exit_to_app_outlined,
              color: AppColors.warning,
              highlights: [
                'Capital : impôt sur le revenu',
                'Rente : régime des pensions',
                'Exonérations possibles sur plus-values',
              ],
              onTap: () => _showDetailSheet(context, 'Sortie'),
            ),
            AppSpacing.verticalGapXl,

            // Comment ça marche
            _SectionTitle(title: 'Comment ça marche'),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Les supports d\'investissement',
              subtitle: 'Où est placée votre épargne',
              description: 'Votre épargne est investie sur différents supports selon votre profil de risque et vos objectifs.',
              icon: Icons.pie_chart_outline,
              color: AppColors.info,
              highlights: [
                'Fonds en euros (sécurisé)',
                'Unités de compte (dynamique)',
                'Gestion pilotée ou libre',
              ],
              onTap: () => _showDetailSheet(context, 'Supports'),
            ),
            AppSpacing.verticalGapMd,

            _EducationTile(
              title: 'Les frais',
              subtitle: 'Comprendre les coûts',
              description: 'Différents types de frais s\'appliquent à votre contrat. Il est important de les connaître pour optimiser votre épargne.',
              icon: Icons.receipt_long_outlined,
              color: AppColors.primaryLight,
              highlights: [
                'Frais sur versements',
                'Frais de gestion annuels',
                'Frais d\'arbitrage',
              ],
              onTap: () => _showDetailSheet(context, 'Frais'),
            ),
            AppSpacing.verticalGapXl,

            // Glossaire
            _SectionTitle(title: 'Glossaire'),
            AppSpacing.verticalGapMd,

            AppCard(
              child: Column(
                children: [
                  _GlossaryItem(
                    term: 'Encours',
                    definition: 'Valeur totale de votre épargne à un instant donné.',
                  ),
                  const Divider(),
                  _GlossaryItem(
                    term: 'Plus-value',
                    definition: 'Gain réalisé par rapport à vos versements.',
                  ),
                  const Divider(),
                  _GlossaryItem(
                    term: 'Arbitrage',
                    definition: 'Transfert de votre épargne d\'un support vers un autre.',
                  ),
                  const Divider(),
                  _GlossaryItem(
                    term: 'Abondement',
                    definition: 'Versement complémentaire de votre employeur.',
                  ),
                  const Divider(),
                  _GlossaryItem(
                    term: 'Rente',
                    definition: 'Revenu régulier versé pendant la retraite.',
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapMd,

            AppButton(
              label: 'Voir le glossaire complet',
              variant: AppButtonVariant.outline,
              leadingIcon: Icons.menu_book,
              onPressed: () {},
            ),

            AppSpacing.verticalGapXxl,
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, String topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalGapLg,
                Text(
                  'En savoir plus sur $topic',
                  style: AppTypography.headlineMedium,
                ),
                AppSpacing.verticalGapMd,
                Text(
                  'Contenu pédagogique détaillé à venir...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapLg,
                // Placeholder pour le contenu détaillé
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: const Center(
                    child: Text('Contenu pédagogique'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _EducationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> highlights;
  final VoidCallback onTap;

  const _EducationTile({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.highlights,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(icon, color: color, size: 24),
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
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: color,
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
          AppSpacing.verticalGapMd,
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: highlights.map((h) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 12, color: color),
                    AppSpacing.horizontalGapXxs,
                    Text(
                      h,
                      style: AppTypography.caption.copyWith(
                        color: color,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GlossaryItem extends StatelessWidget {
  final String term;
  final String definition;

  const _GlossaryItem({
    required this.term,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              term,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              definition,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
