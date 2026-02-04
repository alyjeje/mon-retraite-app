import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'new_payment_screen.dart';

/// Écran des versements
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Versements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Verser'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewPaymentTab(context),
          _buildHistoryTab(context),
        ],
      ),
    );
  }

  Widget _buildNewPaymentTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction pédagogique
          AlertCard(
            title: 'Pourquoi verser régulièrement ?',
            message: 'Les versements réguliers permettent de lisser les effets des variations de marché et d\'optimiser votre épargne retraite.',
            type: AlertCardType.info,
          ),
          AppSpacing.verticalGapLg,

          // Types de versement
          Text(
            'Choisissez votre type de versement',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,

          // Versement ponctuel
          _PaymentTypeCard(
            title: 'Versement ponctuel',
            description: 'Effectuez un versement unique sur le contrat de votre choix',
            icon: Icons.payments_outlined,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewPaymentScreen(isProgrammed: false),
                ),
              );
            },
          ),
          AppSpacing.verticalGapMd,

          // Versement programmé
          _PaymentTypeCard(
            title: 'Versement programmé',
            description: 'Mettez en place un versement automatique mensuel, trimestriel ou annuel',
            icon: Icons.autorenew,
            color: AppColors.accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewPaymentScreen(isProgrammed: true),
                ),
              );
            },
          ),
          AppSpacing.verticalGapLg,

          // Versements programmés actifs
          if (provider.scheduledPayments.isNotEmpty) ...[
            Text(
              'Vos versements programmés',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalGapMd,
            ...provider.scheduledPayments.map((payment) {
              final contract = provider.getContractById(payment.contractId);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: payment.isActive
                              ? AppColors.successLight
                              : AppColors.dividerLight,
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        child: Icon(
                          Icons.autorenew,
                          color: payment.isActive
                              ? AppColors.success
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      AppSpacing.horizontalGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract?.name ?? 'Contrat',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(payment.amount)} / ${payment.frequencyLabel.toLowerCase()}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            if (payment.nextExecutionDate != null)
                              Text(
                                'Prochain : ${DateFormat('dd/MM/yyyy').format(payment.nextExecutionDate!)}',
                                style: AppTypography.caption,
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                          PopupMenuItem(
                            value: payment.isActive ? 'suspend' : 'resume',
                            child: Text(payment.isActive ? 'Suspendre' : 'Reprendre'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                        onSelected: (value) {
                          // Actions
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          // Moyens de paiement
          AppSpacing.verticalGapLg,
          Text(
            'Vos moyens de paiement',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.verticalGapMd,
          ...provider.bankAccounts.map((account) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                account.bankName,
                                style: AppTypography.labelMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              if (account.isDefault) ...[
                                AppSpacing.horizontalGapSm,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: AppSpacing.borderRadiusSm,
                                  ),
                                  child: Text(
                                    'Principal',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            account.maskedIban,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (account.isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          AppSpacing.verticalGapMd,
          AppButton(
            label: 'Ajouter un compte bancaire',
            variant: AppButtonVariant.outline,
            leadingIcon: Icons.add,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    if (provider.transactions.isEmpty) {
      return const EmptyView(
        title: 'Aucune opération',
        message: 'Vous n\'avez pas encore effectué de versement.',
        icon: Icons.receipt_long_outlined,
      );
    }

    // Grouper par mois
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (final transaction in provider.transactions) {
      final key = DateFormat('MMMM yyyy', 'fr_FR').format(transaction.date);
      groupedTransactions.putIfAbsent(key, () => []).add(transaction);
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final month = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              month.substring(0, 1).toUpperCase() + month.substring(1),
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalGapSm,
            ...transactions.map((transaction) {
              final contract = provider.getContractById(transaction.contractId);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () {
                    _showTransactionDetails(context, transaction);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Icon(
                          _getTransactionIcon(transaction.type),
                          color: _getStatusColor(transaction.status),
                          size: 20,
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
                              contract?.name ?? 'Contrat',
                              style: AppTypography.caption,
                            ),
                            Text(
                              dateFormat.format(transaction.date),
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${transaction.isPositive ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                            style: AppTypography.labelMedium.copyWith(
                              color: transaction.isPositive
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                            ),
                          ),
                          _TransactionStatusChip(status: transaction.status),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            AppSpacing.verticalGapMd,
          ],
        );
      },
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.warning;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.contribution:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.arbitration:
        return Icons.swap_horiz;
      case TransactionType.fee:
        return Icons.receipt_outlined;
      case TransactionType.interest:
        return Icons.trending_up;
      case TransactionType.transfer:
        return Icons.compare_arrows;
    }
  }

  void _showTransactionDetails(BuildContext context, TransactionModel transaction) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dateFormat = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTransactionIcon(transaction.type),
                      color: _getStatusColor(transaction.status),
                      size: 32,
                    ),
                  ),
                ),
                AppSpacing.verticalGapMd,
                Center(
                  child: Text(
                    transaction.type.label,
                    style: AppTypography.headlineMedium,
                  ),
                ),
                Center(
                  child: Text(
                    '${transaction.isPositive ? '+' : ''}${currencyFormat.format(transaction.amount)}',
                    style: AppTypography.displaySmall.copyWith(
                      color: transaction.isPositive
                          ? AppColors.success
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                Center(
                  child: _TransactionStatusChip(status: transaction.status),
                ),
                AppSpacing.verticalGapLg,
                const Divider(),
                AppSpacing.verticalGapMd,
                _DetailRow(label: 'Date', value: dateFormat.format(transaction.date)),
                if (transaction.executionDate != null)
                  _DetailRow(label: 'Exécution', value: dateFormat.format(transaction.executionDate!)),
                if (transaction.paymentMethod != null)
                  _DetailRow(label: 'Moyen', value: transaction.paymentMethod!.label),
                if (transaction.description != null)
                  _DetailRow(label: 'Description', value: transaction.description!),
                _DetailRow(label: 'Référence', value: transaction.id),
                if (transaction.failureReason != null) ...[
                  AppSpacing.verticalGapMd,
                  AlertCard(
                    title: 'Échec du versement',
                    message: transaction.failureReason!,
                    type: AlertCardType.error,
                    actionLabel: 'Réessayer',
                    onAction: () {},
                  ),
                ],
                AppSpacing.verticalGapLg,
                if (transaction.status == TransactionStatus.completed)
                  AppButton(
                    label: 'Télécharger le reçu',
                    variant: AppButtonVariant.outline,
                    leadingIcon: Icons.download,
                    onPressed: () {},
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PaymentTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(icon, color: color, size: 28),
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
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }
}

class _TransactionStatusChip extends StatelessWidget {
  final TransactionStatus status;

  const _TransactionStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TransactionStatus.completed:
        color = AppColors.success;
        break;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        color = AppColors.warning;
        break;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        status.label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
