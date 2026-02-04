/// Type de document
enum DocumentType {
  statement('Relevé', 'releve'),
  certificate('Attestation', 'attestation'),
  contract('Contrat', 'contrat'),
  notice('Notice', 'notice'),
  tax('Document fiscal', 'fiscal'),
  correspondence('Courrier', 'courrier'),
  other('Autre', 'autre');

  final String label;
  final String slug;
  const DocumentType(this.label, this.slug);
}

/// Modèle Document
class DocumentModel {
  final String id;
  final String title;
  final DocumentType type;
  final String? contractId;
  final DateTime date;
  final DateTime? expirationDate;
  final String fileUrl;
  final String fileType; // pdf, jpg, png
  final int fileSize; // in bytes
  final bool isRead;
  final bool isFavorite;
  final bool requiresSignature;
  final bool isSigned;
  final String? year;
  final String? description;

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    this.contractId,
    required this.date,
    this.expirationDate,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    this.isRead = false,
    this.isFavorite = false,
    this.requiresSignature = false,
    this.isSigned = false,
    this.year,
    this.description,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isNew => !isRead && date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
}

/// Modèle Notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? actionUrl;
  final String? relatedId;
  final NotificationPriority priority;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.actionUrl,
    this.relatedId,
    this.priority = NotificationPriority.normal,
  });

  bool get isNew => !isRead && date.isAfter(DateTime.now().subtract(const Duration(days: 3)));
}

/// Type de notification
enum NotificationType {
  document('Document', 'document'),
  payment('Versement', 'payment'),
  performance('Performance', 'performance'),
  alert('Alerte', 'alert'),
  reminder('Rappel', 'reminder'),
  info('Information', 'info'),
  promotion('Offre', 'promotion');

  final String label;
  final String slug;
  const NotificationType(this.label, this.slug);
}

/// Priorité de notification
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Modèle Alerte
class AlertModel {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final String? actionLabel;
  final String? actionRoute;
  final bool isDismissible;
  final DateTime? expirationDate;

  AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.severity = AlertSeverity.info,
    this.actionLabel,
    this.actionRoute,
    this.isDismissible = true,
    this.expirationDate,
  });

  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());
}

/// Type d'alerte
enum AlertType {
  profileIncomplete,
  documentAvailable,
  beneficiaryCheck,
  scheduledPaymentConfirm,
  retirementGoalAtRisk,
  performanceUpdate,
  securityAlert,
}

/// Sévérité de l'alerte
enum AlertSeverity {
  info,
  warning,
  error,
  success,
}
