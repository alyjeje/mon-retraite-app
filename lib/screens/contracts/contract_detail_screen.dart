import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

/// Écran détail d'un contrat
class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({
    super.key,
    required this.contractId,
  });

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PerformancePeriod _selectedPeriod = PerformancePeriod.oneYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final contract = provider.getContractById(widget.contractId);

    if (contract == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contrat')),
        body: const ErrorView(
          title: 'Contrat introuvable',
          message: 'Ce contrat n\'existe pas ou a été supprimé.',
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xxxxl,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProductTypeBadge(productType: contract.productType),
                          AppSpacing.verticalGapSm,
                          Text(
                            contract.name,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.verticalGapXs,
                          Text(
                            contract.contractNumber,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currencyFormat.format(contract.currentBalance),
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showContractOptions(context);
                  },
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                child: Container(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Synthèse'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Répartition'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSynthesisTab(context, contract, provider),
            _buildPerformanceTab(context, contract),
            _buildAllocationTab(context, contract),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Verser',
                  onPressed: () {
                    // Navigation vers versement
                  },
                  leadingIcon: Icons.add,
                ),
              ),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: AppButton(
                  label: 'Arbitrer',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    // Navigation vers arbitrage
                  },
                  leadingIcon: Icons.swap_horiz,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSynthesisTab(
    BuildContext context,
    ContractModel contract,
    AppProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé performance
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Plus-value',
                  value: currencyFormat.format(contract.totalGains),
                  isPositive: contract.isPositivePerformance,
                  icon: Icons.trending_up,
                ),
              ),
              AppSpacing.horizontalGapMd,
              Expanded(
                child: _StatCard(
                  label: 'Performance',
                  value: '${contract.isPositivePerformance ? '+' : ''}${contract.performancePercent.toStringAsFixed(2)}%',
                  isPositive: contract.isPositivePerformance,
                  icon: Icons.show_chart,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapLg,

          // Informations du contrat
          Text(
            'Informations',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  label: 'Date d\'ouverture',
                  value: dateFormat.format(contract.openDate),
                ),
                const Divider(),
                _InfoRow(
                  label: 'Versements totaux',
                  value: currencyFormat.format(contract.totalContributions),
                ),
                const Divider(),
                _InfoRow(
                  label: 'Profil de gestion',
                  value: contract.riskProfile.label,
                  trailing: _RiskBadge(profile: contract.riskProfile),
                ),
                if (contract.lastContributionDate != null) ...[
                  const Divider(),
                  _InfoRow(
                    label: 'Dernier versement',
                    value: dateFormat.format(contract.lastContributionDate!),
                  ),
                ],
              ],
            ),
          ),

          // Versement programmé
          if (contract.hasScheduledPayment) ...[
            AppSpacing.verticalGapLg,
            Text(
              'Versement programmé',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapMd,
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.accentSurface,
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: const Icon(
                      Icons.autorenew,
                      color: AppColors.accentDark,
                    ),
                  ),
                  AppSpacing.horizontalGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currencyFormat.format(contract.scheduledPaymentAmount)} / mois',
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Prélèvement le 5 de chaque mois',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Modifier'),
                  ),
                ],
              ),
            ),
          ],

          // Dernières opérations
          AppSpacing.verticalGapLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dernières opérations',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout'),
              ),
            ],
          ),
          AppSpacing.verticalGapMd,
          ...provider.getTransactionsForContract(contract.id).take(3).map(
            (transaction) => _TransactionTile(transaction: transaction),
          ),

          AppSpacing.verticalGapXxl,
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(BuildContext context, ContractModel contract) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de période
          Row(
            children: PerformancePeriod.values.map((period) {
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text(period.code),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = period);
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.verticalGapLg,

          // Graphique de performance
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Évolution de l\'encours',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapMd,
                SizedBox(
                  height: 200,
                  child: _buildPerformanceChart(contract),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Explication pédagogique
          AlertCard(
            title: 'Comment lire ce graphique ?',
            message: 'La courbe montre l\'évolution de la valeur de votre épargne au fil du temps. Les variations dépendent des marchés financiers et de vos versements.',
            type: AlertCardType.info,
          ),
          AppSpacing.verticalGapLg,

          // Performance par période
          Text(
            'Performance par période',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          AppCard(
            child: Column(
              children: [
                _PerformanceRow(label: '1 mois', value: '+1.2%', isPositive: true),
                const Divider(),
                _PerformanceRow(label: '6 mois', value: '+4.5%', isPositive: true),
                const Divider(),
                _PerformanceRow(label: '1 an', value: '+8.76%', isPositive: true),
                const Divider(),
                _PerformanceRow(label: 'Depuis l\'origine', value: '+${contract.performancePercent.toStringAsFixed(2)}%', isPositive: contract.isPositivePerformance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(ContractModel contract) {
    final history = contract.performanceHistory;
    if (history.isEmpty) {
      return const Center(child: Text('Données non disponibles'));
    }

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final value = NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                    .format(spot.y);
                return LineTooltipItem(
                  value,
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationTab(BuildContext context, ContractModel contract) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphique circulaire
          AppCard(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: contract.allocations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final allocation = entry.value;
                        return PieChartSectionData(
                          value: allocation.percentage,
                          title: '${allocation.percentage.toInt()}%',
                          color: AppColors.chartColors[index % AppColors.chartColors.length],
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                AppSpacing.verticalGapMd,
                // Légende
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: contract.allocations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final allocation = entry.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.chartColors[index % AppColors.chartColors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AppSpacing.horizontalGapXs,
                        Text(
                          allocation.name,
                          style: AppTypography.caption,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapLg,

          // Liste des supports
          Text(
            'Détail des supports',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          ...contract.allocations.asMap().entries.map((entry) {
            final index = entry.key;
            final allocation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.chartColors[index % AppColors.chartColors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allocation.name,
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          AppSpacing.verticalGapXxs,
                          Row(
                            children: [
                              Text(
                                allocation.category,
                                style: AppTypography.caption,
                              ),
                              AppSpacing.horizontalGapSm,
                              _RiskLevelIndicator(level: allocation.riskLevel),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(allocation.amount),
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${allocation.performance >= 0 ? '+' : ''}${allocation.performance.toStringAsFixed(1)}%',
                          style: AppTypography.caption.copyWith(
                            color: allocation.performance >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Note pédagogique
          AppSpacing.verticalGapLg,
          AlertCard(
            title: 'Qu\'est-ce que la répartition ?',
            message: 'Votre épargne est investie sur différents supports selon votre profil de risque. Chaque support a ses propres caractéristiques de rendement et de risque.',
            type: AlertCardType.info,
            actionLabel: 'En savoir plus',
            onAction: () {},
          ),
        ],
      ),
    );
  }

  void _showContractOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Voir les documents'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique des opérations'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Gérer les bénéficiaires'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Informations du contrat'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets privés

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

class _ProductTypeBadge extends StatelessWidget {
  final ProductType productType;

  const _ProductTypeBadge({required this.productType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        productType.code,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              AppSpacing.horizontalGapXs,
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapSm,
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            AppSpacing.horizontalGapSm,
          ],
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
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

class _RiskBadge extends StatelessWidget {
  final RiskProfile profile;

  const _RiskBadge({required this.profile});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (profile) {
      case RiskProfile.prudent:
        color = AppColors.success;
        break;
      case RiskProfile.equilibre:
        color = AppColors.warning;
        break;
      case RiskProfile.dynamique:
        color = AppColors.error;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RiskLevelIndicator extends StatelessWidget {
  final RiskLevel level;

  const _RiskLevelIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < level.value;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: isActive
                ? (level.value == 3
                    ? AppColors.error
                    : level.value == 2
                        ? AppColors.warning
                        : AppColors.success)
                : AppColors.dividerLight,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dateFormat = DateFormat('dd MMM', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: transaction.isPositive
                    ? AppColors.successLight
                    : AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                transaction.isPositive
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.isPositive
                    ? AppColors.success
                    : AppColors.primary,
                size: 16,
              ),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.type.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    dateFormat.format(transaction.date),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.isPositive ? '+' : ''}${currencyFormat.format(transaction.amount)}',
              style: AppTypography.labelMedium.copyWith(
                color: transaction.isPositive
                    ? AppColors.success
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _PerformanceRow({
    required this.label,
    required this.value,
    required this.isPositive,
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
            style: AppTypography.labelMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
