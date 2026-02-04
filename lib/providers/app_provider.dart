import 'package:flutter/material.dart';
import '../data/mock/mock_data.dart';
import '../data/models/models.dart';

/// Provider principal de l'application
class AppProvider extends ChangeNotifier {
  // État du thème
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  // Navigation
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // Données utilisateur
  UserModel get user => MockData.user;
  List<BeneficiaryModel> get beneficiaries => MockData.beneficiaries;

  // Données contrats
  List<ContractModel> get contracts => MockData.contracts;
  double get totalBalance => MockData.totalBalance;
  double get totalGains => MockData.totalGains;
  double get overallPerformance => MockData.overallPerformance;

  ContractModel? getContractById(String id) {
    try {
      return contracts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Données transactions
  List<TransactionModel> get transactions => MockData.transactions;
  List<ScheduledPaymentModel> get scheduledPayments => MockData.scheduledPayments;
  List<BankAccountModel> get bankAccounts => MockData.bankAccounts;

  List<TransactionModel> getTransactionsForContract(String contractId) {
    return transactions.where((t) => t.contractId == contractId).toList();
  }

  // Données documents
  List<DocumentModel> get documents => MockData.documents;
  int get unreadDocumentsCount => MockData.unreadDocumentsCount;
  int get pendingSignaturesCount => MockData.pendingSignaturesCount;

  List<DocumentModel> getDocumentsForContract(String contractId) {
    return documents.where((d) => d.contractId == contractId).toList();
  }

  // Données notifications
  List<NotificationModel> get notifications => MockData.notifications;
  int get unreadNotificationsCount => MockData.unreadNotificationsCount;
  List<AlertModel> get alerts => MockData.alerts;

  // États de chargement simulés
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> simulateLoading({Duration duration = const Duration(seconds: 1)}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(duration);
    _isLoading = false;
    notifyListeners();
  }

  // Actions simulées
  Future<bool> makePayment({
    required String contractId,
    required double amount,
    required PaymentMethod method,
  }) async {
    await simulateLoading(duration: const Duration(seconds: 2));
    // Simulation d'un paiement réussi
    return true;
  }

  Future<bool> updateProfile({
    String? email,
    String? phone,
    AddressModel? address,
  }) async {
    await simulateLoading();
    return true;
  }

  void markNotificationAsRead(String id) {
    // Dans un vrai cas, on mettrait à jour la notification
    notifyListeners();
  }

  void markDocumentAsRead(String id) {
    // Dans un vrai cas, on mettrait à jour le document
    notifyListeners();
  }
}
