import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'contract_detail_screen.dart';

/// Écran liste des contrats - Design Figma
class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes contrats retraite',
                      style: AppTypography.headlineLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.verticalGapXxs,
                    Text(
                      'Vue détaillée de votre patrimoine',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalGapMd,

              // Statistiques rapides
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        iconBgColor: AppColors.primaryLighter,
                        iconColor: AppColors.primary,
                        value: currencyFormat.format(provider.totalBalance),
                        label: 'Encours total',
                        valueColor: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        iconBgColor: AppColors.successLight,
                        iconColor: AppColors.success,
                        value: '+${currencyFormat.format(provider.totalGains)}',
                        label: 'Plus-value',
                        valueColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalGapLg,

              // Tabs
              Container(
                margin: AppSpacing.screenPaddingHorizontal,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(AppColors.radiusLg),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  unselectedLabelColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                    boxShadow: AppColors.shadowSm,
                  ),
                  tabs: const [
                    Tab(text: 'Contrats'),
                    Tab(text: 'Performance'),
                    Tab(text: 'Allocation'),
                  ],
                ),
              ),

              AppSpacing.verticalGapMd,

              // Tab content
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ContractsTab(provider: provider),
                    _PerformanceTab(),
                    _AllocationTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          AppSpacing.verticalGapSm,
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractsTab extends StatelessWidget {
  final AppProvider provider;

  const _ContractsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Liste des contrats
          ...provider.contracts.map((contract) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ContractCard(
                contract: contract,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContractDetailScreen(
                        contractId: contract.id,
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          AppSpacing.verticalGapMd,

          // Opérations récentes
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      AppSpacing.horizontalGapSm,
                      Text(
                        'Opérations récentes',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...provider.transactions.take(4).map((transaction) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.description ?? transaction.type.label,
                                style: AppTypography.labelMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy', 'fr_FR')
                                    .format(transaction.date),
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${currencyFormat.format(transaction.amount)}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius:
                                    BorderRadius.circular(AppColors.radiusSm),
                              ),
                              child: Text(
                                'Validé',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        children: [
          // Performance Chart placeholder
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Évolution de l\'épargne',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Text(
                          '+7.63%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Period selector
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: ['1M', '6M', '1A', 'Max'].map((period) {
                      final isSelected = period == '1A';
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppColors.radiusSm),
                          ),
                          child: Text(
                            period,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Chart area placeholder
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _SimpleChartPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.verticalGapMd,

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  ),
                  child: Icon(
                    Icons.trending_up,
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
                        'Comprendre la performance',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalGapXxs,
                      Text(
                        'La performance est calculée en tenant compte des versements, des arbitrages et des frais de gestion. Elle est nette de frais mais brute de prélèvements sociaux et fiscaux.',
                        style: AppTypography.bodySmall.copyWith(
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
        ],
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [0.4, 0.45, 0.5, 0.48, 0.55, 0.6, 0.58, 0.65, 0.7, 0.75, 0.8];

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AllocationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 0,
    );

    final allocations = MockData.globalAllocation;
    final colors = [
      AppColors.chart1,
      AppColors.chart2,
      AppColors.chart3,
      AppColors.chart4,
    ];

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          boxShadow: AppColors.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.pie_chart, size: 20),
                  AppSpacing.horizontalGapSm,
                  Text(
                    'Répartition par supports',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Bar chart visual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppColors.radiusSm),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: allocations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final alloc = entry.value;
                      return Expanded(
                        flex: alloc['value'] as int,
                        child: Container(color: colors[index]),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            AppSpacing.verticalGapMd,

            // Allocation list
            ...allocations.asMap().entries.map((entry) {
              final index = entry.key;
              final alloc = entry.value;
              final risk = alloc['risk'] as String;

              Color badgeColor;
              Color badgeBgColor;
              if (risk == 'Prudent') {
                badgeColor = AppColors.success;
                badgeBgColor = AppColors.successLight;
              } else if (risk == 'Équilibré') {
                badgeColor = AppColors.warning;
                badgeBgColor = AppColors.warningLight;
              } else {
                badgeColor = AppColors.error;
                badgeBgColor = AppColors.errorLight;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alloc['name'] as String,
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius:
                                  BorderRadius.circular(AppColors.radiusSm),
                            ),
                            child: Text(
                              risk,
                              style: AppTypography.caption.copyWith(
                                color: badgeColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${alloc['value']}%',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currencyFormat.format(alloc['amount']),
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            AppSpacing.verticalGapMd,

            // Conseil
            Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppColors.radiusSm),
              ),
              child: Text(
                'Conseil : Votre allocation est équilibrée. Pensez à la revoir régulièrement en fonction de votre horizon de placement et de votre profil de risque.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
