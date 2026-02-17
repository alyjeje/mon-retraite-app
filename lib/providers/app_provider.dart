import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api/api_client.dart';
import '../data/mock/mock_data.dart';
import '../data/models/models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profil_repository.dart';
import '../data/repositories/contrat_repository.dart';

/// Provider principal de l'application.
/// Appelle le BFF pour les donnees reelles, fallback sur MockData si indisponible.
class AppProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _tokenKey = 'bff_token';

  // API layer
  final ApiClient _api = ApiClient();
  late final AuthRepository _authRepo = AuthRepository(_api);
  late final ProfilRepository _profilRepo = ProfilRepository(_api);
  late final ContratRepository _contratRepo = ContratRepository(_api);

  // Theme
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Auth state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String? _authError;
  String? get authError => _authError;

  // Data state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _dataLoaded = false;
  bool get dataLoaded => _dataLoaded;
  bool _useMock = false;
  bool get useMock => _useMock;

  // Donnees chargees depuis le BFF (ou mock en fallback)
  UserModel? _user;
  List<ContractModel> _contracts = [];
  List<TransactionModel> _transactions = [];
  double _totalBalance = 0;
  double _totalGains = 0;
  double _overallPerformance = 0;

  AppProvider() {
    _loadThemePreference();
    _tryRestoreSession();
  }

  // ============================================
  // THEME
  // ============================================

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
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================
  // NAVIGATION
  // ============================================

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // ============================================
  // AUTH
  // ============================================

  /// Tente de restaurer la session depuis un token sauvegarde
  Future<void> _tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);

    if (savedToken != null) {
      _api.setToken(savedToken);
      // Verifier que le token est encore valide via refresh
      final refreshed = await _authRepo.refresh();
      if (refreshed) {
        _isAuthenticated = true;
        notifyListeners();
        await loadAllData();
      } else {
        // Token expire, on nettoie
        await prefs.remove(_tokenKey);
        _api.clearToken();
      }
    }
  }

  /// Login via BFF
  Future<bool> login(String identifiant, String motDePasse) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _authRepo.login(identifiant, motDePasse);

      if (result.success && result.token != null) {
        _isAuthenticated = true;
        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, result.token!);
        _isLoading = false;
        notifyListeners();
        // Charger les donnees
        await loadAllData();
        return true;
      }

      _authError = result.message ?? 'Erreur de connexion';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _authError = 'Impossible de se connecter au serveur.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deconnexion
  Future<void> logout() async {
    _authRepo.logout();
    _isAuthenticated = false;
    _dataLoaded = false;
    _user = null;
    _contracts = [];
    _transactions = [];
    _totalBalance = 0;
    _totalGains = 0;
    _overallPerformance = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  // ============================================
  // DATA LOADING
  // ============================================

  /// Charge toutes les donnees depuis le BFF.
  /// Fallback sur MockData si le BFF est injoignable.
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Charger le profil (contient la liste des contrats)
      final profil = await _profilRepo.getProfil();
      _user = profil.user;

      // 2. Charger le detail de chaque contrat en parallele
      final detailFutures = profil.contracts
          .where((c) => c.isActive)
          .map((c) => _contratRepo.getContratDetail(
                c.scont.toStringAsFixed(0),
                codeCb: c.codeCb > 0 ? c.codeCb.toString() : null,
              ));

      final details = await Future.wait(detailFutures);
      _contracts = details.map((d) => d.toContractModel()).toList();

      // 3. Charger les operations pour chaque contrat en parallele
      final opsFutures = profil.contracts.where((c) => c.isActive).map((c) =>
          _contratRepo
              .getOperations(c.scont.toStringAsFixed(0))
              .then((ops) => ops
                  .map((o) => o.toTransactionModel(
                      c.scont.toStringAsFixed(0)))
                  .toList()));

      final opsResults = await Future.wait(opsFutures);
      _transactions = opsResults.expand((ops) => ops).toList();

      // 4. Calculer les totaux
      _totalBalance =
          _contracts.fold(0, (sum, c) => sum + c.currentBalance);
      _totalGains = _contracts.fold(0, (sum, c) => sum + c.totalGains);
      _overallPerformance = _totalBalance > 0 && (_totalBalance - _totalGains) > 0
          ? (_totalGains / (_totalBalance - _totalGains)) * 100
          : 0;

      _useMock = false;
      _dataLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[AppProvider] BFF indisponible, fallback MockData: $e');
      _fallbackToMock();
    }
  }

  /// Fallback: charge les donnees mock quand le BFF est injoignable
  void _fallbackToMock() {
    _user = MockData.user;
    _contracts = MockData.contracts;
    _transactions = MockData.transactions;
    _totalBalance = MockData.totalBalance;
    _totalGains = MockData.totalGains;
    _overallPerformance = MockData.overallPerformance;
    _useMock = true;
    _dataLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================
  // GETTERS (meme interface que avant pour les ecrans)
  // ============================================

  UserModel get user => _user ?? MockData.user;
  List<ContractModel> get contracts => _contracts;
  double get totalBalance => _totalBalance;
  double get totalGains => _totalGains;
  double get overallPerformance => _overallPerformance;

  ContractModel? getContractById(String id) {
    try {
      return contracts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Transactions depuis BFF ou mock
  List<TransactionModel> get transactions => _transactions.isNotEmpty
      ? _transactions
      : MockData.transactions;

  List<TransactionModel> getTransactionsForContract(String contractId) {
    return transactions.where((t) => t.contractId == contractId).toList();
  }

  // Donnees encore sur mock (pas dans le Swagger)
  List<BeneficiaryModel> get beneficiaries => MockData.beneficiaries;
  List<ScheduledPaymentModel> get scheduledPayments =>
      MockData.scheduledPayments;
  List<BankAccountModel> get bankAccounts => MockData.bankAccounts;
  List<DocumentModel> get documents => MockData.documents;
  int get unreadDocumentsCount => MockData.unreadDocumentsCount;
  int get pendingSignaturesCount => MockData.pendingSignaturesCount;
  List<NotificationModel> get notifications => MockData.notifications;
  int get unreadNotificationsCount => MockData.unreadNotificationsCount;
  List<AlertModel> get alerts => MockData.alerts;

  List<DocumentModel> getDocumentsForContract(String contractId) {
    return documents.where((d) => d.contractId == contractId).toList();
  }

  // ============================================
  // ACTIONS (via BFF)
  // ============================================

  Future<bool> makePayment({
    required String contractId,
    required double amount,
    required PaymentMethod method,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.post('/actions/versement', body: {
        'scont': contractId,
        'montant': amount,
      });
      _isLoading = false;
      notifyListeners();
      // Recharger les donnees apres versement
      await loadAllData();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? email,
    String? phone,
    AddressModel? address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email != null) {
        await _profilRepo.updateEmail(email);
      }
      if (phone != null) {
        await _profilRepo.updatePhone(phone);
      }
      if (address != null) {
        await _profilRepo.updateAddress(
          street: address.street,
          complement: address.complement,
          postalCode: address.postalCode,
          city: address.city,
        );
      }
      _isLoading = false;
      notifyListeners();
      // Recharger le profil
      await loadAllData();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void markNotificationAsRead(String id) {
    notifyListeners();
  }

  void markDocumentAsRead(String id) {
    notifyListeners();
  }

  Future<void> simulateLoading(
      {Duration duration = const Duration(seconds: 1)}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(duration);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
