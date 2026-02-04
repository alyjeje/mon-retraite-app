import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock/mock_data.dart';
import '../data/models/models.dart';

/// Provider principal de l'application
class AppProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  // État du thème - par défaut en mode clair
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  AppProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    if (savedMode != null) {
      switch (savedMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.light;
      }
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String modeString;
    switch (_themeMode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await prefs.setString(_themeModeKey, modeString);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

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
