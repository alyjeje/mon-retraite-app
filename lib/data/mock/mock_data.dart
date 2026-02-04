import '../models/models.dart';

/// Données mockées pour le prototype - synchronisées avec Figma
class MockData {
  MockData._();

  // ============================================
  // UTILISATEUR (Sophie Martin - depuis Figma)
  // ============================================
  static final UserModel user = UserModel(
    id: 'user_001',
    firstName: 'Sophie',
    lastName: 'Martin',
    email: 'sophie.martin@email.com',
    phone: '06 12 34 56 78',
    address: AddressModel(
      street: '15 rue de la Paix',
      complement: 'Appartement 3B',
      postalCode: '75002',
      city: 'Paris',
    ),
    birthDate: DateTime(1962, 5, 15), // Pour avoir 64 ans en 2026
    isProfileComplete: true,
    hasBiometricEnabled: true,
    has2FAEnabled: true, // Activée selon Figma
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    connectedDevices: ['iPhone 14 Pro', 'iPad Air'],
    memberSince: DateTime(2020, 1, 1), // Client depuis 2020
  );

  // ============================================
  // BÉNÉFICIAIRES (3 selon Figma)
  // ============================================
  static final List<BeneficiaryModel> beneficiaries = [
    BeneficiaryModel(
      id: 'ben_001',
      firstName: 'Pierre',
      lastName: 'Martin',
      relationship: 'Époux',
      percentage: 50,
      priority: 1,
      birthDate: DateTime(1960, 8, 22),
    ),
    BeneficiaryModel(
      id: 'ben_002',
      firstName: 'Emma',
      lastName: 'Martin',
      relationship: 'Fille',
      percentage: 25,
      priority: 2,
      birthDate: DateTime(1988, 3, 10),
    ),
    BeneficiaryModel(
      id: 'ben_003',
      firstName: 'Lucas',
      lastName: 'Martin',
      relationship: 'Fils',
      percentage: 25,
      priority: 2,
      birthDate: DateTime(1991, 11, 5),
    ),
  ];

  // ============================================
  // CONTRATS (Données Figma exactes)
  // Total: 125 780€ / Gain: +8 920€ / +7.63%
  // ============================================
  static final List<ContractModel> contracts = [
    ContractModel(
      id: 'contract_001',
      contractNumber: 'PERIN-2024-78542',
      productType: ProductType.perin,
      name: 'Mon PERIN GAN',
      currentBalance: 75450.00,
      totalContributions: 69600.00,
      totalGains: 5850.00,
      performancePercent: 8.2,
      performancePeriod: '1 an',
      riskProfile: RiskProfile.equilibre,
      openDate: DateTime(2020, 3, 15),
      lastContributionDate: DateTime.now().subtract(const Duration(days: 15)),
      hasScheduledPayment: true,
      scheduledPaymentAmount: 200.0,
      scheduledPaymentFrequency: 'monthly',
      allocations: [
        AllocationModel(
          id: 'alloc_001',
          name: 'Fonds Euro',
          category: 'Fonds en euros',
          percentage: 42,
          amount: 52826.00,
          performance: 2.5,
          riskLevel: RiskLevel.low,
          riskLabel: 'Prudent',
        ),
        AllocationModel(
          id: 'alloc_002',
          name: 'Actions Europe',
          category: 'Actions',
          percentage: 28,
          amount: 35218.00,
          performance: 12.3,
          riskLevel: RiskLevel.high,
          riskLabel: 'Dynamique',
        ),
        AllocationModel(
          id: 'alloc_003',
          name: 'Obligations',
          category: 'Obligations',
          percentage: 18,
          amount: 22640.00,
          performance: 4.8,
          riskLevel: RiskLevel.medium,
          riskLabel: 'Équilibré',
        ),
        AllocationModel(
          id: 'alloc_004',
          name: 'Immobilier',
          category: 'SCPI',
          percentage: 12,
          amount: 15096.00,
          performance: 6.2,
          riskLevel: RiskLevel.medium,
          riskLabel: 'Équilibré',
        ),
      ],
      performanceHistory: _generatePerformanceHistory(75450.00, 36),
    ),
    ContractModel(
      id: 'contract_002',
      contractNumber: 'PERO-2024-65231',
      productType: ProductType.pero,
      name: 'PERO Entreprise',
      currentBalance: 38200.00,
      totalContributions: 35800.00,
      totalGains: 2400.00,
      performancePercent: 6.5,
      performancePeriod: '1 an',
      riskProfile: RiskProfile.dynamique,
      openDate: DateTime(2021, 9, 1),
      lastContributionDate: DateTime.now().subtract(const Duration(days: 30)),
      hasScheduledPayment: false,
      allocations: [
        AllocationModel(
          id: 'alloc_005',
          name: 'Fonds Euro',
          category: 'Fonds en euros',
          percentage: 30,
          amount: 11460.00,
          performance: 2.5,
          riskLevel: RiskLevel.low,
          riskLabel: 'Prudent',
        ),
        AllocationModel(
          id: 'alloc_006',
          name: 'Actions Europe',
          category: 'Actions',
          percentage: 45,
          amount: 17190.00,
          performance: 10.2,
          riskLevel: RiskLevel.high,
          riskLabel: 'Dynamique',
        ),
        AllocationModel(
          id: 'alloc_007',
          name: 'Obligations',
          category: 'Obligations',
          percentage: 25,
          amount: 9550.00,
          performance: 4.1,
          riskLevel: RiskLevel.medium,
          riskLabel: 'Équilibré',
        ),
      ],
      performanceHistory: _generatePerformanceHistory(38200.00, 24),
    ),
    ContractModel(
      id: 'contract_003',
      contractNumber: 'ERE-2024-41256',
      productType: ProductType.ere,
      name: 'Épargne Salariale',
      currentBalance: 12130.00,
      totalContributions: 11100.00,
      totalGains: 1030.00,
      performancePercent: 9.1,
      performancePeriod: '1 an',
      riskProfile: RiskProfile.equilibre,
      openDate: DateTime(2022, 1, 10),
      lastContributionDate: DateTime.now().subtract(const Duration(days: 60)),
      hasScheduledPayment: false,
      allocations: [
        AllocationModel(
          id: 'alloc_008',
          name: 'Fonds Euro',
          category: 'Fonds en euros',
          percentage: 40,
          amount: 4852.00,
          performance: 2.8,
          riskLevel: RiskLevel.low,
          riskLabel: 'Prudent',
        ),
        AllocationModel(
          id: 'alloc_009',
          name: 'Actions Monde',
          category: 'Actions',
          percentage: 35,
          amount: 4245.50,
          performance: 15.2,
          riskLevel: RiskLevel.high,
          riskLabel: 'Dynamique',
        ),
        AllocationModel(
          id: 'alloc_010',
          name: 'Obligations',
          category: 'Obligations',
          percentage: 25,
          amount: 3032.50,
          performance: 3.8,
          riskLevel: RiskLevel.medium,
          riskLabel: 'Équilibré',
        ),
      ],
      performanceHistory: _generatePerformanceHistory(12130.00, 18),
    ),
  ];

  // ============================================
  // TRANSACTIONS (Opérations récentes Figma)
  // ============================================
  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'trans_001',
      contractId: 'contract_001',
      type: TransactionType.contribution,
      status: TransactionStatus.completed,
      amount: 200.00,
      date: DateTime(2026, 1, 15),
      executionDate: DateTime(2026, 1, 15),
      paymentMethod: PaymentMethod.directDebit,
      description: 'Versement programmé',
    ),
    TransactionModel(
      id: 'trans_002',
      contractId: 'contract_001',
      type: TransactionType.contribution,
      status: TransactionStatus.completed,
      amount: 5000.00,
      date: DateTime(2026, 1, 1),
      executionDate: DateTime(2026, 1, 1),
      paymentMethod: PaymentMethod.bankTransfer,
      description: 'Versement exceptionnel',
    ),
    TransactionModel(
      id: 'trans_003',
      contractId: 'contract_001',
      type: TransactionType.contribution,
      status: TransactionStatus.completed,
      amount: 200.00,
      date: DateTime(2025, 12, 15),
      executionDate: DateTime(2025, 12, 15),
      paymentMethod: PaymentMethod.directDebit,
      description: 'Versement programmé',
    ),
    TransactionModel(
      id: 'trans_004',
      contractId: 'contract_002',
      type: TransactionType.contribution,
      status: TransactionStatus.completed,
      amount: 1500.00,
      date: DateTime(2025, 11, 20),
      executionDate: DateTime(2025, 11, 20),
      paymentMethod: PaymentMethod.bankTransfer,
      description: 'Abondement employeur',
    ),
    TransactionModel(
      id: 'trans_005',
      contractId: 'contract_001',
      type: TransactionType.contribution,
      status: TransactionStatus.pending,
      amount: 200.00,
      date: DateTime.now(),
      paymentMethod: PaymentMethod.directDebit,
      description: 'Versement programmé mensuel',
    ),
  ];

  // ============================================
  // VERSEMENTS PROGRAMMÉS
  // ============================================
  static final List<ScheduledPaymentModel> scheduledPayments = [
    ScheduledPaymentModel(
      id: 'sched_001',
      contractId: 'contract_001',
      amount: 200.00,
      paymentMethod: PaymentMethod.directDebit,
      frequency: 'monthly',
      dayOfMonth: 15,
      startDate: DateTime(2024, 1, 15),
      isActive: true,
      nextExecutionDate: DateTime.now().add(const Duration(days: 15)),
      lastExecutionDate: DateTime(2026, 1, 15),
    ),
  ];

  // ============================================
  // COMPTES BANCAIRES (2 RIB selon Figma)
  // ============================================
  static final List<BankAccountModel> bankAccounts = [
    BankAccountModel(
      id: 'bank_001',
      iban: 'FR76 1234 5678 9012 3456 7890 123',
      bic: 'BNPAFRPP',
      bankName: 'BNP Paribas',
      accountHolder: 'Sophie Martin',
      isDefault: true,
      isVerified: true,
      addedDate: DateTime(2020, 1, 15),
    ),
    BankAccountModel(
      id: 'bank_002',
      iban: 'FR76 9876 5432 1098 7654 3210 987',
      bic: 'CEPAFRPP',
      bankName: 'Caisse d\'Épargne',
      accountHolder: 'Sophie Martin',
      isDefault: false,
      isVerified: true,
      addedDate: DateTime(2022, 6, 20),
    ),
  ];

  // ============================================
  // DOCUMENTS
  // ============================================
  static final List<DocumentModel> documents = [
    DocumentModel(
      id: 'doc_001',
      title: 'Relevé annuel 2025',
      type: DocumentType.statement,
      contractId: 'contract_001',
      date: DateTime.now().subtract(const Duration(days: 5)),
      fileUrl: '/documents/releve_2025.pdf',
      fileType: 'pdf',
      fileSize: 245000,
      isRead: false,
      year: '2025',
      description: 'Récapitulatif de votre épargne pour l\'année 2025',
    ),
    DocumentModel(
      id: 'doc_002',
      title: 'Attestation fiscale 2025',
      type: DocumentType.tax,
      contractId: 'contract_001',
      date: DateTime.now().subtract(const Duration(days: 30)),
      fileUrl: '/documents/attestation_fiscale_2025.pdf',
      fileType: 'pdf',
      fileSize: 128000,
      isRead: true,
      year: '2025',
      description: 'Attestation pour votre déclaration d\'impôts',
    ),
    DocumentModel(
      id: 'doc_003',
      title: 'Conditions générales PERIN',
      type: DocumentType.contract,
      contractId: 'contract_001',
      date: DateTime(2020, 3, 15),
      fileUrl: '/documents/cg_perin.pdf',
      fileType: 'pdf',
      fileSize: 1250000,
      isRead: true,
      description: 'Conditions générales de votre contrat PERIN',
    ),
    DocumentModel(
      id: 'doc_004',
      title: 'Notice d\'information',
      type: DocumentType.notice,
      contractId: 'contract_001',
      date: DateTime(2020, 3, 15),
      fileUrl: '/documents/notice_info.pdf',
      fileType: 'pdf',
      fileSize: 890000,
      isRead: true,
      description: 'Notice d\'information de votre produit',
    ),
    DocumentModel(
      id: 'doc_005',
      title: 'Relevé trimestriel T4 2025',
      type: DocumentType.statement,
      contractId: 'contract_001',
      date: DateTime(2026, 1, 1),
      fileUrl: '/documents/releve_t4_2025.pdf',
      fileType: 'pdf',
      fileSize: 156000,
      isRead: true,
      year: '2025',
    ),
    DocumentModel(
      id: 'doc_006',
      title: 'Avenant au contrat PERO',
      type: DocumentType.contract,
      contractId: 'contract_002',
      date: DateTime.now().subtract(const Duration(days: 10)),
      fileUrl: '/documents/avenant_pero.pdf',
      fileType: 'pdf',
      fileSize: 340000,
      isRead: false,
      requiresSignature: true,
      isSigned: false,
      description: 'Avenant à signer pour mise à jour des conditions',
    ),
  ];

  // ============================================
  // NOTIFICATIONS
  // ============================================
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif_001',
      title: 'Nouveau document disponible',
      message: 'Votre relevé annuel 2025 est disponible dans votre coffre-fort.',
      type: NotificationType.document,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      actionUrl: '/documents/doc_001',
      relatedId: 'doc_001',
    ),
    NotificationModel(
      id: 'notif_002',
      title: 'Versement programmé exécuté',
      message: 'Votre versement mensuel de 200€ a été effectué avec succès.',
      type: NotificationType.payment,
      date: DateTime(2026, 1, 15),
      isRead: true,
      relatedId: 'trans_001',
    ),
    NotificationModel(
      id: 'notif_003',
      title: 'Performance mensuelle',
      message: 'Votre épargne a progressé de +1,2% ce mois-ci. Découvrez le détail.',
      type: NotificationType.performance,
      date: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      actionUrl: '/contracts/contract_001/performance',
    ),
    NotificationModel(
      id: 'notif_004',
      title: 'Document à signer',
      message: 'Un avenant à votre contrat PERO nécessite votre signature.',
      type: NotificationType.alert,
      date: DateTime.now().subtract(const Duration(days: 10)),
      isRead: false,
      priority: NotificationPriority.high,
      actionUrl: '/documents/doc_006',
      relatedId: 'doc_006',
    ),
    NotificationModel(
      id: 'notif_005',
      title: 'Rappel : vérifiez vos bénéficiaires',
      message: 'Il est recommandé de vérifier régulièrement la clause bénéficiaire de vos contrats.',
      type: NotificationType.reminder,
      date: DateTime.now().subtract(const Duration(days: 60)),
      isRead: true,
      actionUrl: '/profile/beneficiaries',
    ),
  ];

  // ============================================
  // ALERTES
  // ============================================
  static final List<AlertModel> alerts = [
    AlertModel(
      id: 'alert_001',
      title: 'Action recommandée',
      message: 'Pensez à mettre à jour vos bénéficiaires pour sécuriser votre succession.',
      type: AlertType.documentAvailable,
      severity: AlertSeverity.warning,
      actionLabel: 'Mettre à jour',
      actionRoute: '/profile/beneficiaries',
    ),
    AlertModel(
      id: 'alert_002',
      title: 'Document à signer',
      message: 'Un avenant à votre contrat PERO nécessite votre signature électronique.',
      type: AlertType.documentAvailable,
      severity: AlertSeverity.warning,
      actionLabel: 'Signer',
      actionRoute: '/documents/doc_006',
    ),
  ];

  // ============================================
  // DONNÉES PERFORMANCE CHART (depuis Figma)
  // ============================================
  static final Map<String, List<Map<String, dynamic>>> performanceChartData = {
    'oneMonth': [
      {'date': '4 Jan', 'value': 120000},
      {'date': '11 Jan', 'value': 121500},
      {'date': '18 Jan', 'value': 122800},
      {'date': '25 Jan', 'value': 123400},
      {'date': '1 Fév', 'value': 125780},
    ],
    'sixMonths': [
      {'date': 'Sep', 'value': 110000},
      {'date': 'Oct', 'value': 114000},
      {'date': 'Nov', 'value': 117500},
      {'date': 'Déc', 'value': 120000},
      {'date': 'Jan', 'value': 123000},
      {'date': 'Fév', 'value': 125780},
    ],
    'oneYear': [
      {'date': 'Fév 25', 'value': 105000},
      {'date': 'Avr', 'value': 108000},
      {'date': 'Juin', 'value': 112000},
      {'date': 'Août', 'value': 115000},
      {'date': 'Oct', 'value': 119000},
      {'date': 'Déc', 'value': 122000},
      {'date': 'Fév 26', 'value': 125780},
    ],
    'max': [
      {'date': '2020', 'value': 45000},
      {'date': '2021', 'value': 62000},
      {'date': '2022', 'value': 78000},
      {'date': '2023', 'value': 95000},
      {'date': '2024', 'value': 112000},
      {'date': '2025', 'value': 120000},
      {'date': '2026', 'value': 125780},
    ],
  };

  // ============================================
  // ALLOCATION GLOBALE (depuis Figma)
  // ============================================
  static final List<Map<String, dynamic>> globalAllocation = [
    {'name': 'Fonds Euro', 'value': 42, 'amount': 52826, 'risk': 'Prudent'},
    {'name': 'Actions Europe', 'value': 28, 'amount': 35218, 'risk': 'Dynamique'},
    {'name': 'Obligations', 'value': 18, 'amount': 22640, 'risk': 'Équilibré'},
    {'name': 'Immobilier', 'value': 12, 'amount': 15096, 'risk': 'Équilibré'},
  ];

  // ============================================
  // HELPERS
  // ============================================
  static List<PerformanceDataPoint> _generatePerformanceHistory(
    double currentValue,
    int months,
  ) {
    final List<PerformanceDataPoint> history = [];
    final now = DateTime.now();
    double value = currentValue * 0.75;

    for (int i = months; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final growth = 1 + (0.005 + (i % 3 == 0 ? 0.01 : -0.005));
      value = value * growth;

      history.add(PerformanceDataPoint(
        date: date,
        value: value,
        performancePercent: ((value / (currentValue * 0.75)) - 1) * 100,
      ));
    }

    if (history.isNotEmpty) {
      history[history.length - 1] = PerformanceDataPoint(
        date: now,
        value: currentValue,
        performancePercent: ((currentValue / (currentValue * 0.75)) - 1) * 100,
      );
    }

    return history;
  }

  // ============================================
  // CALCULS GLOBAUX (Valeurs Figma)
  // Total: 125 780€ / Gain: 8 920€ / +7.63%
  // ============================================
  static double get totalBalance => 125780.00;

  static double get totalContributions => 116500.00;

  static double get totalGains => 8920.00;

  static double get overallPerformance => 7.63;

  static int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  static int get unreadDocumentsCount =>
      documents.where((d) => !d.isRead).length;

  static int get pendingSignaturesCount =>
      documents.where((d) => d.requiresSignature && !d.isSigned).length;
}
