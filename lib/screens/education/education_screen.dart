import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Hub pédagogique "Comprendre mes produits" - Design Figma
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Product> _products = [
    _Product(
      id: 'perin',
      name: 'PERIN',
      fullName: 'Plan d\'Épargne Retraite Individuel',
      icon: Icons.shield_outlined,
      color: AppColors.primary,
      bgColor: AppColors.primaryLighter,
      textColor: AppColors.primary, // Texte bleu foncé sur fond bleu clair
      description: 'Épargne individuelle avec avantages fiscaux',
      features: [
        'Versements déductibles des impôts',
        'Sortie en capital ou en rente',
        'Déblocage anticipé possible dans certains cas',
        'Transférable vers un autre établissement',
      ],
      fiscality:
          'Les versements sont déductibles du revenu imposable dans la limite de 10% des revenus professionnels.',
      unlocking: [
        'Achat de la résidence principale',
        'Accident de la vie (invalidité, décès du conjoint)',
        'Fin des droits au chômage',
        'Cessation d\'activité non salariée suite à liquidation judiciaire',
        'Surendettement',
      ],
    ),
    _Product(
      id: 'pero',
      name: 'PERO',
      fullName: 'Plan d\'Épargne Retraite Obligatoire',
      icon: Icons.business_outlined,
      color: AppColors.info,
      bgColor: AppColors.infoLight,
      textColor: AppColors.infoTextOnLight, // Texte bleu foncé sur fond bleu clair
      description: 'Épargne retraite mise en place par l\'employeur',
      features: [
        'Abondement de l\'employeur possible',
        'Versements volontaires + obligatoires',
        'Transférable en cas de changement d\'employeur',
        'Fiscalité avantageuse',
      ],
      fiscality:
          'Les versements volontaires sont déductibles du revenu imposable. L\'abondement employeur est exonéré de cotisations sociales.',
      unlocking: [
        'Départ à la retraite',
        'Achat de la résidence principale',
        'Accident de la vie',
        'Fin de droits au chômage',
      ],
    ),
    _Product(
      id: 'ere',
      name: 'ERE',
      fullName: 'Épargne Retraite Entreprise / Épargne Salariale',
      icon: Icons.groups_outlined,
      color: AppColors.accentYellowDark,
      bgColor: AppColors.accentYellowLight,
      textColor: AppColors.textOnYellow, // Texte marron foncé sur fond jaune clair
      description:
          'Dispositif d\'épargne salariale (participation, intéressement)',
      features: [
        'Abondement de l\'entreprise',
        'Disponibilité après 5 ans',
        'Déblocage anticipé possible',
        'Exonération de cotisations sociales',
      ],
      fiscality:
          'Les sommes versées sont exonérées de cotisations sociales mais soumises à la CSG-CRDS.',
      unlocking: [
        'Après 5 ans de détention',
        'Mariage ou PACS',
        'Naissance du 3ème enfant',
        'Achat ou agrandissement de la résidence principale',
        'Création d\'entreprise',
      ],
    ),
  ];

  final List<Map<String, String>> _glossary = [
    {
      'term': 'Encours',
      'definition': 'Montant total de votre épargne à un instant T'
    },
    {
      'term': 'Plus-value',
      'definition':
          'Gain réalisé sur votre épargne (différence entre la valeur actuelle et vos versements)'
    },
    {
      'term': 'Abondement',
      'definition':
          'Contribution de votre employeur qui vient compléter vos versements'
    },
    {
      'term': 'Arbitrage',
      'definition': 'Action de transférer votre épargne d\'un support à un autre'
    },
    {
      'term': 'Support',
      'definition':
          'Produit financier dans lequel votre épargne est investie (fonds euro, actions, obligations...)'
    },
    {
      'term': 'Rente',
      'definition': 'Revenu régulier versé à vie lors de votre départ à la retraite'
    },
    {
      'term': 'TMI',
      'definition':
          'Tranche Marginale d\'Imposition - votre taux d\'imposition le plus élevé'
    },
  ];

  final List<Map<String, String>> _comparisons = [
    {
      'criteria': 'Versements',
      'perin': 'Libres et volontaires',
      'pero': 'Volontaires + obligatoires',
      'ere': 'Participation + intéressement',
    },
    {
      'criteria': 'Abondement',
      'perin': 'Non',
      'pero': 'Oui (employeur)',
      'ere': 'Oui (entreprise)',
    },
    {
      'criteria': 'Fiscalité',
      'perin': 'Déduction d\'impôts',
      'pero': 'Déduction + exonération',
      'ere': 'Exonération cotisations',
    },
    {
      'criteria': 'Disponibilité',
      'perin': 'Retraite + cas exceptionnels',
      'pero': 'Retraite + cas exceptionnels',
      'ere': 'Après 5 ans + cas exceptionnels',
    },
    {
      'criteria': 'Sortie',
      'perin': 'Capital ou rente',
      'pero': 'Capital ou rente',
      'ere': 'Capital',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Comprendre mes produits'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sous-titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Tout savoir sur votre épargne retraite',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          AppSpacing.verticalGapMd,

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: AppTypography.labelSmall,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'PERIN'),
                Tab(text: 'PERO'),
                Tab(text: 'ERE'),
                Tab(text: 'Comparer'),
              ],
            ),
          ),
          AppSpacing.verticalGapMd,

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // PERIN tab
                _buildProductTab(_products[0], isDark),
                // PERO tab
                _buildProductTab(_products[1], isDark),
                // ERE tab
                _buildProductTab(_products[2], isDark),
                // Compare tab
                _buildCompareTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab(_Product product, bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête produit
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: product.bgColor,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border(
                left: BorderSide(color: product.color, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: product.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(product.icon, color: product.textColor, size: 24),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTypography.headlineSmall.copyWith(
                              color: product.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product.fullName,
                            style: AppTypography.caption.copyWith(
                              color: product.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapSm,
                Text(
                  product.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: product.textColor,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapMd,

          // Caractéristiques
          _buildSectionCard(
            isDark,
            icon: Icons.shield_outlined,
            title: 'Caractéristiques principales',
            child: Column(
              children: product.features
                  .map((f) => _buildFeatureItem(f, isDark))
                  .toList(),
            ),
          ),
          AppSpacing.verticalGapMd,

          // Fiscalité
          _buildFiscalityCard(product, isDark),
          AppSpacing.verticalGapMd,

          // Cas de déblocage
          _buildSectionCard(
            isDark,
            icon: Icons.savings_outlined,
            title: 'Cas de déblocage anticipé',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre épargne peut être débloquée avant la retraite dans ces situations :',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapSm,
                ...product.unlocking.map((u) => _buildUnlockingItem(u, isDark)),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Glossaire
          _buildGlossaryCard(isDark),
          AppSpacing.verticalGapLg,

          // Help card
          _buildHelpCard(isDark),
          AppSpacing.verticalGapXxl,
        ],
      ),
    );
  }

  Widget _buildCompareTab(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tableau comparatif
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau comparatif',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  'Comparez les 3 dispositifs d\'épargne retraite',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapMd,

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowHeight: 48,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 60,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Critère',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: _buildBadge('PERIN', AppColors.primary),
                      ),
                      DataColumn(
                        label: _buildBadge('PERO', AppColors.info),
                      ),
                      DataColumn(
                        label: _buildBadge('ERE', AppColors.accentYellow),
                      ),
                    ],
                    rows: _comparisons.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            row['criteria']!,
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          )),
                          DataCell(Text(
                            row['perin']!,
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          )),
                          DataCell(Text(
                            row['pero']!,
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          )),
                          DataCell(Text(
                            row['ere']!,
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Glossaire
          _buildGlossaryCard(isDark),
          AppSpacing.verticalGapLg,

          // Help card
          _buildHelpCard(isDark),
          AppSpacing.verticalGapXxl,
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          child,
        ],
      ),
    );
  }

  Widget _buildFiscalityCard(_Product product, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.accentYellowDark, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Avantages fiscaux',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          Text(
            product.fiscality,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentYellowLight,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Text(
              '💰 Exemple : Pour 1 000€ versés avec un TMI de 30%, vous économisez 300€ d\'impôts.',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textOnYellow, // Texte contrasté sur fond jaune
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✓ ', style: TextStyle(color: AppColors.success)),
          Expanded(
            child: Text(
              feature,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockingItem(String item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('→ ',
              style: TextStyle(color: AppColors.primary, fontSize: 12)),
          Expanded(
            child: Text(
              item,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossaryCard(bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
              AppSpacing.horizontalGapSm,
              Text(
                'Glossaire',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          ..._glossary.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['term']!,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  item['definition']!,
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (index < _glossary.length - 1) ...[
                  AppSpacing.verticalGapSm,
                  Divider(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  AppSpacing.verticalGapSm,
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHelpCard(bool isDark) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'D\'autres questions ?',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  'Consultez notre FAQ complète ou contactez un conseiller',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapMd,
                Row(
                  children: [
                    AppButton(
                      label: 'Voir la FAQ',
                      variant: AppButtonVariant.outline,
                      onPressed: () => _showComingSoon(context),
                    ),
                    AppSpacing.horizontalGapSm,
                    AppButton(
                      label: 'Contacter',
                      variant: AppButtonVariant.text,
                      onPressed: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

class _Product {
  final String id;
  final String name;
  final String fullName;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color textColor; // Couleur du texte sur fond bgColor (WCAG AA)
  final String description;
  final List<String> features;
  final String fiscality;
  final List<String> unlocking;

  const _Product({
    required this.id,
    required this.name,
    required this.fullName,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.textColor,
    required this.description,
    required this.features,
    required this.fiscality,
    required this.unlocking,
  });
}
