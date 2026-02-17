import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/contract_model.dart';
import '../models/transaction_model.dart';

/// Detail complet d'un contrat (agrege par le BFF)
class ContratDetailData {
  final double scont;
  final String contractNumber;
  final String productType;
  final String name;
  final String? employer;
  final String startDate;
  final String? endDate;
  final String status;
  final double currentBalance;
  final List<AllocationData> allocations;
  final ManagementModeData managementMode;
  final EligibilityData eligibility;

  ContratDetailData({
    required this.scont,
    required this.contractNumber,
    required this.productType,
    required this.name,
    this.employer,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.currentBalance,
    required this.allocations,
    required this.managementMode,
    required this.eligibility,
  });

  factory ContratDetailData.fromJson(Map<String, dynamic> json) {
    return ContratDetailData(
      scont: (json['scont'] as num).toDouble(),
      contractNumber: json['contractNumber'] ?? '',
      productType: json['productType'] ?? '',
      name: json['name'] ?? '',
      employer: json['employer'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      status: json['status'] ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      allocations: (json['allocations'] as List? ?? [])
          .map((a) => AllocationData.fromJson(a))
          .toList(),
      managementMode: ManagementModeData.fromJson(json['managementMode'] ?? {}),
      eligibility: EligibilityData.fromJson(json['eligibility'] ?? {}),
    );
  }

  /// Convertit en ContractModel Flutter existant
  ContractModel toContractModel() {
    final pt = productType == 'PERIN'
        ? ProductType.perin
        : productType == 'PERO'
            ? ProductType.pero
            : productType == 'ERE'
                ? ProductType.ere
                : ProductType.epargne;

    return ContractModel(
      id: scont.toStringAsFixed(0),
      contractNumber: contractNumber,
      productType: pt,
      name: name,
      currentBalance: currentBalance,
      totalContributions: currentBalance * 0.92, // Approximation
      totalGains: currentBalance * 0.08,
      performancePercent: 7.63,
      riskProfile: managementMode.profile == 'Dynamique'
          ? RiskProfile.dynamique
          : managementMode.profile == 'Prudent'
              ? RiskProfile.prudent
              : RiskProfile.equilibre,
      openDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      allocations: allocations.map((a) => a.toAllocationModel()).toList(),
    );
  }
}

class AllocationData {
  final String id;
  final String name;
  final String category;
  final double percentage;
  final double amount;
  final double performance;
  final String riskLevel;
  final String? codeISIN;
  final String? codeSupport;
  final bool? deductible;

  AllocationData({
    required this.id,
    required this.name,
    required this.category,
    required this.percentage,
    required this.amount,
    required this.performance,
    required this.riskLevel,
    this.codeISIN,
    this.codeSupport,
    this.deductible,
  });

  factory AllocationData.fromJson(Map<String, dynamic> json) {
    return AllocationData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      performance: (json['performance'] as num?)?.toDouble() ?? 0,
      riskLevel: json['riskLevel'] ?? 'medium',
      codeISIN: json['codeISIN'],
      codeSupport: json['codeSupport'],
      deductible: json['deductible'],
    );
  }

  AllocationModel toAllocationModel() {
    return AllocationModel(
      id: id,
      name: name,
      category: category,
      percentage: percentage,
      amount: amount,
      performance: performance,
      riskLevel: riskLevel == 'low'
          ? RiskLevel.low
          : riskLevel == 'high'
              ? RiskLevel.high
              : RiskLevel.medium,
    );
  }
}

class ManagementModeData {
  final String mode;
  final String type;
  final String? profile;
  final int retirementAge;
  final String? retirementDate;

  ManagementModeData({
    required this.mode,
    required this.type,
    this.profile,
    required this.retirementAge,
    this.retirementDate,
  });

  factory ManagementModeData.fromJson(Map<String, dynamic> json) {
    return ManagementModeData(
      mode: json['mode'] ?? 'Libre',
      type: json['type'] ?? 'Gestion Libre',
      profile: json['profile'],
      retirementAge: json['retirementAge'] ?? 64,
      retirementDate: json['retirementDate'],
    );
  }
}

class EligibilityData {
  final bool versement;
  final bool arbitrage;
  final bool rente;

  EligibilityData({
    required this.versement,
    required this.arbitrage,
    required this.rente,
  });

  factory EligibilityData.fromJson(Map<String, dynamic> json) {
    return EligibilityData(
      versement: json['versement'] ?? false,
      arbitrage: json['arbitrage'] ?? false,
      rente: json['rente'] ?? false,
    );
  }
}

class OperationData {
  final int id;
  final String label;
  final String type;
  final String? subType;
  final String? paymentMethod;
  final String date;
  final double amountGross;
  final double amountNet;
  final String status;
  final bool isCancellation;

  OperationData({
    required this.id,
    required this.label,
    required this.type,
    this.subType,
    this.paymentMethod,
    required this.date,
    required this.amountGross,
    required this.amountNet,
    required this.status,
    required this.isCancellation,
  });

  factory OperationData.fromJson(Map<String, dynamic> json) {
    return OperationData(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      subType: json['subType'],
      paymentMethod: json['paymentMethod'],
      date: json['date'] ?? '',
      amountGross: (json['amountGross'] as num?)?.toDouble() ?? 0,
      amountNet: (json['amountNet'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      isCancellation: json['isCancellation'] ?? false,
    );
  }

  /// Convertit en TransactionModel Flutter existant
  TransactionModel toTransactionModel(String contractId) {
    return TransactionModel(
      id: 'trans_$id',
      contractId: contractId,
      type: type == 'Versement'
          ? TransactionType.contribution
          : TransactionType.contribution,
      status: status == 'Traite'
          ? TransactionStatus.completed
          : TransactionStatus.pending,
      amount: amountGross,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      executionDate: DateTime.tryParse(date),
      paymentMethod: paymentMethod == 'Prelevement'
          ? PaymentMethod.directDebit
          : PaymentMethod.bankTransfer,
      description: label,
    );
  }
}

class ContratRepository {
  final ApiClient _api;

  ContratRepository(this._api);

  Future<ContratDetailData> getContratDetail(String scont, {String? codeCb}) async {
    final path = codeCb != null
        ? '/contrats/$scont/detail?codeCb=$codeCb'
        : '/contrats/$scont/detail';
    final data = await _api.get(path);
    return ContratDetailData.fromJson(data);
  }

  Future<List<OperationData>> getOperations(String scont) async {
    final data = await _api.get(ApiEndpoints.contratOperations(scont));
    return (data as List).map((e) => OperationData.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getVersement(String scont) async {
    return await _api.get(ApiEndpoints.contratVersement(scont));
  }

  Future<List<dynamic>> getOptionsFinancieres(String scont) async {
    return await _api.get(ApiEndpoints.contratOptionsFinancieres(scont));
  }
}
