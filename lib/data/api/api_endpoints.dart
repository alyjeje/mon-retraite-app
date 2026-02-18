/// Tous les endpoints du BFF centralises ici.
/// Correspond aux routes definies dans bff/src/index.ts.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Profil
  static const String profil = '/profil';
  static const String profilAddress = '/profil/address';
  static const String profilEmail = '/profil/email';
  static const String profilPhone = '/profil/phone';

  // Contrats
  static String contratDetail(String scont, {String? codeCb}) =>
      '/contrats/$scont/detail${codeCb != null ? '?codeCb=$codeCb' : ''}';
  static String contratOperations(String scont) =>
      '/contrats/$scont/operations';
  static String contratVersement(String scont) =>
      '/contrats/$scont/versement';
  static String contratOptionsFinancieres(String scont) =>
      '/contrats/$scont/options-financieres';

  // Actions
  static const String versement = '/actions/versement';
  static const String arbitrage = '/actions/arbitrage';
  static String arbitrageInfo(String contrat) =>
      '/actions/arbitrage/$contrat';
  static const String modifierVersementProgramme =
      '/actions/modifier-versement-programme';
  static String supprimerVersementMensuel(String scont) =>
      '/actions/supprimer-versement-mensuel/$scont';
  static String modifierOptionFinanciere(String scont) =>
      '/actions/modifier-option-financiere/$scont';
  static const String modifierAgeRetraite = '/actions/modifier-age-retraite';
  static const String representationPrelevement =
      '/actions/representation-prelevement';

  // Dashboard
  static const String dashboardSynthese = '/dashboard/synthese';

  // Health
  static const String health = '/health';
}
