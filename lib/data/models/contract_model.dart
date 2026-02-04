/// Types de produits retraite
enum ProductType {
  perin('PERIN', 'Plan d\'Épargne Retraite Individuel'),
  pero('PERO', 'Plan d\'Épargne Retraite Obligatoire'),
  ere('ERE', 'Épargne Retraite Entreprise'),
  epargne('Épargne Salariale', 'Épargne Salariale');

  final String code;
  final String fullName;
  const ProductType(this.code, this.fullName);
}

/// Profil de risque
enum RiskProfile {
  prudent('Prudent', 'Investissement sécurisé avec rendement modéré'),
  equilibre('Équilibré', 'Balance entre sécurité et performance'),
  dynamique('Dynamique', 'Recherche de performance avec plus de risque');

  final String label;
  final String description;
  const RiskProfile(this.label, this.description);
}

/// Modèle Contrat
class ContractModel {
  final String id;
  final String contractNumber;
  final ProductType productType;
  final String name;
  final double currentBalance;
  final double totalContributions;
  final double totalGains;
  final double performancePercent;
  final String? performancePeriod;
  final RiskProfile riskProfile;
  final DateTime openDate;
  final DateTime? lastContributionDate;
  final List<AllocationModel> allocations;
  final List<PerformanceDataPoint> performanceHistory;
  final bool hasScheduledPayment;
  final double? scheduledPaymentAmount;
  final String? scheduledPaymentFrequency;

  ContractModel({
    required this.id,
    required this.contractNumber,
    required this.productType,
    required this.name,
    required this.currentBalance,
    required this.totalContributions,
    required this.totalGains,
    required this.performancePercent,
    this.performancePeriod,
    required this.riskProfile,
    required this.openDate,
    this.lastContributionDate,
    this.allocations = const [],
    this.performanceHistory = const [],
    this.hasScheduledPayment = false,
    this.scheduledPaymentAmount,
    this.scheduledPaymentFrequency,
  });

  double get gainPercentage =>
      totalContributions > 0 ? (totalGains / totalContributions) * 100 : 0;

  bool get isPositivePerformance => totalGains >= 0;
}

/// Modèle Allocation (répartition des supports)
class AllocationModel {
  final String id;
  final String name;
  final String category;
  final double percentage;
  final double amount;
  final double performance;
  final RiskLevel riskLevel;
  final String? riskLabel;

  AllocationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.percentage,
    required this.amount,
    required this.performance,
    required this.riskLevel,
    this.riskLabel,
  });
}

/// Niveau de risque
enum RiskLevel {
  low('Faible', 1),
  medium('Moyen', 2),
  high('Élevé', 3);

  final String label;
  final int value;
  const RiskLevel(this.label, this.value);
}

/// Point de données performance
class PerformanceDataPoint {
  final DateTime date;
  final double value;
  final double performancePercent;

  PerformanceDataPoint({
    required this.date,
    required this.value,
    required this.performancePercent,
  });
}

/// Période de performance
enum PerformancePeriod {
  oneMonth('1M', '1 mois'),
  sixMonths('6M', '6 mois'),
  oneYear('1A', '1 an'),
  threeYears('3A', '3 ans'),
  max('Max', 'Depuis l\'origine');

  final String code;
  final String label;
  const PerformancePeriod(this.code, this.label);
}
