import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api/api_client.dart';
import '../data/mock/mock_data.dart';
import '../data/models/models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profil_repository.dart';
import '../data/repositories/contrat_repository.dart';
import '../data/services/biometric_service.dart';
import '../data/services/inactivity_service.dart';

/// Provider principal de l'application.
/// Appelle le BFF pour les donnees reelles, fallback sur MockData si indisponible.
class AppProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _tokenKey = 'bff_token';
  static const String _timeoutKey = 'inactivity_timeout_minutes';

  // API layer
  final ApiClient _api = ApiClient();
  late final AuthRepository _authRepo = AuthRepository(_api);
  late final ProfilRepository _profilRepo = ProfilRepository(_api);
  late final ContratRepository _contratRepo = ContratRepository(_api);

  // Biometric
  final BiometricService _biometricService = BiometricService();
  BiometricService get biometricService => _biometricService;

  // Inactivity
  final InactivityService _inactivityService = InactivityService();

  // Theme
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Auth state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String? _authError;
  String? get authError => _authError;

  // Biometric auth state
  bool _requiresBiometricAuth = false;
  bool get requiresBiometricAuth => _requiresBiometricAuth;
  bool _pendingBiometricPrompt = false;
  bool get pendingBiometricPrompt => _pendingBiometricPrompt;

  // Temporary storage for biometric setup after first login
  String? _pendingBioIdentifiant;
  String? _pendingBioMotDePasse;

  // Inactivity timeout (from BFF config)
  int _inactivityTimeoutMinutes = 60;
  int get inactivityTimeoutMinutes => _inactivityTimeoutMinutes;

  /// Reset le timer d'inactivite (appele par le Listener dans main.dart)
  void resetInactivityTimer() {
    _inactivityService.resetTimer();
  }

  void _startInactivityService() {
    _inactivityService.start(
      timeoutMinutes: _inactivityTimeoutMinutes,
      onTimeout: () => softLogout(),
      onAppDetached: () => softLogout(),
    );
  }

  void _stopInactivityService() {
    _inactivityService.stop();
  }

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

  /// Tente de restaurer la session depuis un token sauvegarde.
  /// Si un token existe et est valide, on est connecte.
  /// Sinon, si des credentials biometriques existent, on propose la biometrie.
  Future<void> _tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    final savedTimeout = prefs.getInt(_timeoutKey);
    if (savedTimeout != null) _inactivityTimeoutMinutes = savedTimeout;

    if (savedToken != null) {
      _api.setToken(savedToken);
      final refreshed = await _authRepo.refresh();
      if (refreshed) {
        _isAuthenticated = true;
        _startInactivityService();
        notifyListeners();
        await loadAllData();
        return;
      }
      // Token expire, on nettoie
      await prefs.remove(_tokenKey);
      _api.clearToken();
    }

    // Pas de session valide : check biometric credentials
    final hasBio = await _biometricService.hasStoredCredentials();
    final bioAvailable = await _biometricService.isAvailable();
    if (hasBio && bioAvailable) {
      _requiresBiometricAuth = true;
      notifyListeners();
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
        _requiresBiometricAuth = false;

        // Save timeout from BFF
        if (result.inactivityTimeoutMinutes != null) {
          _inactivityTimeoutMinutes = result.inactivityTimeoutMinutes!;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_timeoutKey, _inactivityTimeoutMinutes);
        }

        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, result.token!);

        // Check if we should prompt for biometric setup
        final bioAvailable = await _biometricService.isAvailable();
        if (bioAvailable) {
          final storedId = await _biometricService.getStoredIdentifiant();
          // Prompt biometric if: no stored creds, or different account
          if (storedId == null || storedId != identifiant) {
            _pendingBiometricPrompt = true;
            _pendingBioIdentifiant = identifiant;
            _pendingBioMotDePasse = motDePasse;
          }
        }

        // Start inactivity monitoring
        _startInactivityService();

        _isLoading = false;
        notifyListeners();
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

  /// Login via biometrie (cold start)
  Future<bool> loginWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return false;

    final credentials = await _biometricService.getCredentials();
    if (credentials == null) return false;

    return await login(credentials.identifiant, credentials.motDePasse);
  }

  /// Sauvegarde les credentials biometriques apres acceptation
  Future<void> enableBiometric(String identifiant, String motDePasse) async {
    await _biometricService.saveCredentials(identifiant, motDePasse);
    _pendingBiometricPrompt = false;
    _pendingBioIdentifiant = null;
    _pendingBioMotDePasse = null;
    notifyListeners();
  }

  /// Sauvegarde les credentials biometriques depuis l'ecran de setup.
  /// Declenche d'abord l'authentification biometrique reelle (Face ID / Touch ID)
  /// puis sauvegarde les credentials si l'utilisateur s'authentifie avec succes.
  /// Retourne true si l'activation a reussi, false sinon.
  Future<bool> enableBiometricFromPending() async {
    if (_pendingBioIdentifiant == null || _pendingBioMotDePasse == null) {
      return false;
    }

    // Declencher la vraie authentification biometrique
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      return false;
    }

    // Authentification reussie → sauvegarder les credentials
    await enableBiometric(_pendingBioIdentifiant!, _pendingBioMotDePasse!);
    return true;
  }

  /// Refuse la biometrie (ne pas sauvegarder)
  void declineBiometric() {
    _pendingBiometricPrompt = false;
    _pendingBioIdentifiant = null;
    _pendingBioMotDePasse = null;
    notifyListeners();
  }

  /// Verifie si la biometrie est activee pour un compte
  Future<bool> isBiometricEnabled() async {
    return await _biometricService.hasStoredCredentials();
  }

  /// Desactive la biometrie
  Future<void> disableBiometric() async {
    await _biometricService.clearCredentials();
    notifyListeners();
  }

  /// Deconnexion manuelle (hard logout) - efface TOUT y compris la biometrie
  Future<void> logout() async {
    _stopInactivityService();
    await _authRepo.logout();
    await _biometricService.clearCredentials();
    _isAuthenticated = false;
    _requiresBiometricAuth = false;
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

  /// Soft logout (timeout / app killed) - garde les credentials biometriques
  Future<void> softLogout() async {
    _stopInactivityService();
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
    _api.clearToken();

    // Check if biometric creds exist -> show biometric prompt
    final hasBio = await _biometricService.hasStoredCredentials();
    final bioAvailable = await _biometricService.isAvailable();
    _requiresBiometricAuth = hasBio && bioAvailable;
    notifyListeners();
  }

  /// Switch to full login (from biometric screen)
  void switchToFullLogin() {
    _requiresBiometricAuth = false;
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
    _inactivityService.dispose();
    _api.dispose();
    super.dispose();
  }
}
