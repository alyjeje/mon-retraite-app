/// Type de transaction
enum TransactionType {
  contribution('Versement', 'versement'),
  withdrawal('Retrait', 'retrait'),
  arbitration('Arbitrage', 'arbitrage'),
  fee('Frais', 'frais'),
  interest('Intérêts', 'intérêts'),
  transfer('Transfert', 'transfert');

  final String label;
  final String slug;
  const TransactionType(this.label, this.slug);
}

/// Statut de transaction
enum TransactionStatus {
  pending('En attente', 'pending'),
  processing('En cours', 'processing'),
  completed('Validé', 'completed'),
  failed('Échoué', 'failed'),
  cancelled('Annulé', 'cancelled');

  final String label;
  final String slug;
  const TransactionStatus(this.label, this.slug);
}

/// Mode de paiement
enum PaymentMethod {
  bankTransfer('Virement bancaire', 'virement'),
  directDebit('Prélèvement', 'prelevement'),
  card('Carte bancaire', 'carte');

  final String label;
  final String slug;
  const PaymentMethod(this.label, this.slug);
}

/// Modèle Transaction
class TransactionModel {
  final String id;
  final String contractId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final DateTime date;
  final DateTime? executionDate;
  final PaymentMethod? paymentMethod;
  final String? description;
  final String? failureReason;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.contractId,
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    this.executionDate,
    this.paymentMethod,
    this.description,
    this.failureReason,
    this.receiptUrl,
  });

  bool get isPositive =>
      type == TransactionType.contribution ||
      type == TransactionType.interest;

  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  bool get canRetry => status == TransactionStatus.failed;
}

/// Modèle Versement programmé
class ScheduledPaymentModel {
  final String id;
  final String contractId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String frequency; // monthly, quarterly, annual
  final int dayOfMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? nextExecutionDate;
  final DateTime? lastExecutionDate;

  ScheduledPaymentModel({
    required this.id,
    required this.contractId,
    required this.amount,
    required this.paymentMethod,
    required this.frequency,
    required this.dayOfMonth,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.nextExecutionDate,
    this.lastExecutionDate,
  });

  String get frequencyLabel {
    switch (frequency) {
      case 'monthly':
        return 'Mensuel';
      case 'quarterly':
        return 'Trimestriel';
      case 'annual':
        return 'Annuel';
      default:
        return frequency;
    }
  }
}

/// Modèle IBAN/RIB
class BankAccountModel {
  final String id;
  final String iban;
  final String bic;
  final String bankName;
  final String accountHolder;
  final bool isDefault;
  final bool isVerified;
  final DateTime addedDate;

  BankAccountModel({
    required this.id,
    required this.iban,
    required this.bic,
    required this.bankName,
    required this.accountHolder,
    this.isDefault = false,
    this.isVerified = false,
    required this.addedDate,
  });

  String get maskedIban {
    if (iban.length < 8) return iban;
    return '${iban.substring(0, 4)} **** **** ${iban.substring(iban.length - 4)}';
  }
}
