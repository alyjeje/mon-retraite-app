import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';
import 'beneficiary_designation_flow_screen.dart';

/// Écran de gestion des bénéficiaires
class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  // Simule si une désignation existe déjà
  bool _hasExistingDesignation = true;
  String? _lastDesignationDate = '15/01/2025';
  String? _lastDesignationType = 'Bénéficiaires nominatifs';

  // Données mock des bénéficiaires actuels
  final List<Map<String, dynamic>> _beneficiaries = [
    {
      'id': '1',
      'name': 'Pierre Martin',
      'relationship': 'Conjoint',
      'percentage': 50,
      'order': 1,
      'contract': 'Mon PERIN GAN',
    },
    {
      'id': '2',
      'name': 'Léa Martin',
      'relationship': 'Enfant',
      'percentage': 25,
      'order': 2,
      'contract': 'Mon PERIN GAN',
    },
    {
      'id': '3',
      'name': 'Hugo Martin',
      'relationship': 'Enfant',
      'percentage': 25,
      'order': 2,
      'contract': 'Mon PERIN GAN',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalPercentage = _beneficiaries.fold<int>(
      0,
      (sum, b) => sum + (b['percentage'] as int),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mes bénéficiaires'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bénéficiaires en cas de décès',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapXs,
            Text(
              'Gérez les bénéficiaires de vos contrats retraite',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapLg,

            // Bouton principal TRÈS visible pour nouvelle désignation
            _buildMainActionCard(context, isDark),
            AppSpacing.verticalGapLg,

            // Alerte pédagogique
            AlertCard(
              title: 'Pourquoi désigner des bénéficiaires ?',
              message:
                  'En cas de décès, le capital de vos contrats retraite sera versé aux bénéficiaires que vous avez désignés, en dehors de votre succession. C\'est important pour protéger vos proches.',
              type: AlertCardType.info,
            ),
            AppSpacing.verticalGapLg,

            // Désignation actuelle (si existe)
            if (_hasExistingDesignation) ...[
              _buildCurrentDesignationCard(isDark, totalPercentage),
              AppSpacing.verticalGapLg,
            ],

            // Information pédagogique
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bon à savoir',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.verticalGapMd,
                  _InfoSection(
                    title: 'Ordre de priorité',
                    description:
                        'Les bénéficiaires de rang 1 sont prioritaires. Si aucun n\'est en vie, le capital est versé au rang 2, etc.',
                  ),
                  AppSpacing.verticalGapSm,
                  _InfoSection(
                    title: 'Répartition',
                    description:
                        'Vous pouvez répartir le capital entre plusieurs bénéficiaires d\'un même rang en pourcentage.',
                  ),
                  AppSpacing.verticalGapSm,
                  _InfoSection(
                    title: 'Annulation et remplacement',
                    description:
                        'Toute nouvelle désignation annule et remplace automatiquement la précédente.',
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

  /// Carte principale avec le bouton d'action pour nouvelle désignation
  Widget _buildMainActionCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: AppColors.shadowMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDesignationFlow(context),
          borderRadius: AppSpacing.cardRadius,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                AppSpacing.horizontalGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasExistingDesignation
                            ? 'Modifier ma désignation'
                            : 'Désigner mes bénéficiaires',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalGapXxs,
                      Text(
                        _hasExistingDesignation
                            ? 'Annule et remplace la désignation actuelle'
                            : 'Protégez vos proches en cas de décès',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Carte affichant la désignation actuelle
  Widget _buildCurrentDesignationCard(bool isDark, int totalPercentage) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: AppColors.success,
                    size: 20,
                  ),
                  AppSpacing.horizontalGapSm,
                  Text(
                    'Désignation en cours',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  'Active',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,

          // Informations sur la désignation
          _DesignationInfoRow(
            label: 'Type',
            value: _lastDesignationType ?? 'Non défini',
          ),
          AppSpacing.verticalGapXs,
          _DesignationInfoRow(
            label: 'Date de signature',
            value: _lastDesignationDate ?? 'Non défini',
          ),
          AppSpacing.verticalGapXs,
          _DesignationInfoRow(
            label: 'Contrat',
            value: 'Mon PERIN GAN',
          ),

          AppSpacing.verticalGapMd,
          const Divider(),
          AppSpacing.verticalGapMd,

          // Statistiques répartition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition totale',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: totalPercentage == 100
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '$totalPercentage%',
                  style: AppTypography.labelMedium.copyWith(
                    color: totalPercentage == 100
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.verticalGapMd,

          // Liste des bénéficiaires
          Text(
            'Bénéficiaires (${_beneficiaries.length})',
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapSm,

          ..._beneficiaries.map((beneficiary) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _BeneficiaryRow(
              name: beneficiary['name'] as String,
              relationship: beneficiary['relationship'] as String,
              percentage: beneficiary['percentage'] as int,
              order: beneficiary['order'] as int,
            ),
          )),

          AppSpacing.verticalGapMd,

          // Bouton voir le document
          AppButton(
            label: 'Voir le document signé',
            variant: AppButtonVariant.outline,
            leadingIcon: Icons.picture_as_pdf,
            onPressed: () => _showDocumentPreview(context),
          ),
        ],
      ),
    );
  }

  void _navigateToDesignationFlow(BuildContext context) {
    // Afficher un dialogue de confirmation si une désignation existe
    if (_hasExistingDesignation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nouvelle désignation'),
          content: const Text(
            'Toute nouvelle désignation annulera et remplacera votre désignation actuelle. Voulez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.pop(context);
                _startDesignationFlow(context);
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
    } else {
      _startDesignationFlow(context);
    }
  }

  void _startDesignationFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BeneficiaryDesignationFlowScreen(
          contractId: 'PERIN-2024-001',
          contractName: 'Mon PERIN GAN',
        ),
      ),
    );
  }

  void _showDocumentPreview(BuildContext context) {
    // Dans une vraie app, on récupèrerait le document depuis le stockage
    // Pour l'instant, afficher un message informatif
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Document'),
          ],
        ),
        content: const Text(
          'Dans cette version de démonstration, le document signé serait stocké sur un serveur sécurisé et accessible depuis votre espace client.\n\nPour visualiser un nouveau document, effectuez une nouvelle désignation.',
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
}

/// Ligne d'information sur la désignation
class _DesignationInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DesignationInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Ligne résumant un bénéficiaire
class _BeneficiaryRow extends StatelessWidget {
  final String name;
  final String relationship;
  final int percentage;
  final int order;

  const _BeneficiaryRow({
    required this.name,
    required this.relationship,
    required this.percentage,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: Text(
                name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '$relationship • Rang $order',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String description;

  const _InfoSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        AppSpacing.verticalGapXxs,
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
