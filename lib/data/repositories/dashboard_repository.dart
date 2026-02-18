import '../api/api_client.dart';
import '../api/api_endpoints.dart';

/// Allocation globale agregee depuis tous les contrats
class GlobalAllocationItem {
  final String code;
  final String label;
  final double amount;
  final double percentage;
  final String category;

  GlobalAllocationItem({
    required this.code,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.category,
  });

  factory GlobalAllocationItem.fromJson(Map<String, dynamic> json) {
    return GlobalAllocationItem(
      code: json['code'] ?? '',
      label: json['label'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      category: json['category'] ?? 'Autre',
    );
  }
}

/// Alerte personnalisee generee par le backend
class DashboardAlert {
  final String type;
  final String title;
  final String message;
  final int priority;

  DashboardAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    return DashboardAlert(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 99,
    );
  }
}

/// Synthese du dashboard (allocation globale + alertes)
class DashboardSynthese {
  final double totalSavings;
  final int contractCount;
  final List<GlobalAllocationItem> globalAllocation;
  final List<DashboardAlert> alerts;
  final String? lastUpdated;

  DashboardSynthese({
    required this.totalSavings,
    required this.contractCount,
    required this.globalAllocation,
    required this.alerts,
    this.lastUpdated,
  });

  factory DashboardSynthese.fromJson(Map<String, dynamic> json) {
    return DashboardSynthese(
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
      contractCount: json['contractCount'] ?? 0,
      globalAllocation: (json['globalAllocation'] as List? ?? [])
          .map((a) => GlobalAllocationItem.fromJson(a))
          .toList(),
      alerts: (json['alerts'] as List? ?? [])
          .map((a) => DashboardAlert.fromJson(a))
          .toList(),
      lastUpdated: json['lastUpdated'],
    );
  }

  /// Alerte la plus prioritaire (priorite la plus basse = la plus importante)
  DashboardAlert? get topAlert => alerts.isNotEmpty ? alerts.first : null;
}

class DashboardRepository {
  final ApiClient _api;

  DashboardRepository(this._api);

  Future<DashboardSynthese> getSynthese() async {
    final data = await _api.get(ApiEndpoints.dashboardSynthese);
    return DashboardSynthese.fromJson(data);
  }
}
