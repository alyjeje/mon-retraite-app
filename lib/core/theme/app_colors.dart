import 'package:flutter/material.dart';

/// Design System - Couleurs
/// Palette GAN Assurances : BLEU (confiance) + JAUNE (énergie)
/// Synchronisé avec le Design System Figma
class AppColors {
  AppColors._();

  // ============================================
  // COULEURS PRIMAIRES - BLEU GAN (Confiance, Professionnalisme)
  // ============================================
  static const Color primary = Color(0xFF003D7A);
  static const Color primaryLight = Color(0xFF0055A5);
  static const Color primaryLighter = Color(0xFFE6F0F9);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // ============================================
  // COULEURS ACCENT - JAUNE GAN (Énergie, Action)
  // ============================================
  static const Color accentYellow = Color(0xFFFFB81C);
  static const Color accentYellowDark = Color(0xFF7A4F00); // Très foncé pour texte sur fond jaune (WCAG AA)
  static const Color accentYellowLight = Color(0xFFFFF8EB); // Fond jaune très clair

  // Texte sur fond jaune - couleur dédiée pour garantir la lisibilité
  static const Color textOnYellow = Color(0xFF5C3D00); // Marron foncé - ratio 7:1 sur jaune clair

  // ============================================
  // COULEURS SÉMANTIQUES - MODE CLAIR
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============================================
  // COULEURS NEUTRES - MODE CLAIR
  // ============================================
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color foregroundLight = Color(0xFF1A1F36);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardForegroundLight = Color(0xFF1A1F36);

  static const Color secondaryLight = Color(0xFFF3F4F6);
  static const Color secondaryForegroundLight = Color(0xFF1A1F36);

  static const Color mutedLight = Color(0xFFE5E7EB);
  static const Color mutedForegroundLight = Color(0xFF6B7280);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputLight = Color(0xFFE5E7EB);
  static const Color inputBackgroundLight = Color(0xFFFFFFFF);
  static const Color switchBackgroundLight = Color(0xFFD1D5DB);

  static const Color destructiveLight = Color(0xFFEF4444);
  static const Color destructiveForegroundLight = Color(0xFFFFFFFF);

  // Texte - Mode clair (contrastes améliorés WCAG AA)
  static const Color textPrimaryLight = Color(0xFF1A1F36);
  static const Color textSecondaryLight = Color(0xFF4B5563); // Plus foncé pour meilleur contraste
  static const Color textTertiaryLight = Color(0xFF6B7280); // Ajusté pour meilleur contraste
  static const Color textDisabledLight = Color(0xFF9CA3AF);

  // ============================================
  // COULEURS NEUTRES - MODE SOMBRE
  // ============================================
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color foregroundDark = Color(0xFFF8F9FB);
  static const Color cardDark = Color(0xFF151923);
  static const Color cardForegroundDark = Color(0xFFF8F9FB);

  static const Color secondaryDark = Color(0xFF1F2937);
  static const Color secondaryForegroundDark = Color(0xFFF8F9FB);

  static const Color mutedDark = Color(0xFF374151);
  static const Color mutedForegroundDark = Color(0xFF9CA3AF);

  static const Color borderDark = Color(0xFF374151);
  static const Color inputDark = Color(0xFF374151);
  static const Color inputBackgroundDark = Color(0xFF1F2937);
  static const Color switchBackgroundDark = Color(0xFF4B5563);

  static const Color destructiveDark = Color(0xFFF87171);
  static const Color destructiveForegroundDark = Color(0xFF0A0E1A);

  // Couleurs primaires adaptées pour le dark mode
  static const Color primaryDark = Color(0xFF60A5FA); // Plus lumineux pour meilleur contraste
  static const Color primaryLightDark = Color(0xFF93C5FD); // Encore plus clair
  static const Color primaryLighterDark = Color(0xFF1E3A5F);
  static const Color primaryForegroundDark = Color(0xFF0A0E1A);

  // Couleurs accent adaptées pour le dark mode
  static const Color accentYellowDarkMode = Color(0xFFFFC940);
  static const Color accentYellowDarkDarkMode = Color(0xFFFFD966); // Plus lumineux
  static const Color accentYellowLightDarkMode = Color(0xFF423A1F); // Fond plus clair pour contraste

  // Couleurs de texte sur fonds colorés (dark mode) - pour meilleur contraste
  static const Color textOnPrimaryDark = Color(0xFFFFFFFF);
  static const Color textOnAccentDark = Color(0xFF1A1F36); // Texte sombre sur jaune
  static const Color textOnInfoDark = Color(0xFFFFFFFF);
  static const Color textOnSuccessDark = Color(0xFFFFFFFF);
  static const Color textOnWarningDark = Color(0xFF1A1F36); // Texte sombre sur warning

  // Couleurs sémantiques dark mode - ajustées pour meilleur contraste
  static const Color successDark = Color(0xFF4ADE80); // Plus lumineux
  static const Color successLightDark = Color(0xFF14532D); // Fond plus foncé pour contraste

  static const Color errorDarkMode = Color(0xFFFCA5A5); // Plus lumineux
  static const Color errorLightDark = Color(0xFF450A0A); // Fond plus foncé

  static const Color warningDark = Color(0xFFFDE047); // Plus lumineux
  static const Color warningLightDark = Color(0xFF422006); // Fond plus foncé

  static const Color infoDark = Color(0xFF93C5FD); // Plus lumineux
  static const Color infoLightDark = Color(0xFF172554); // Fond plus foncé pour contraste

  // Texte - Mode sombre
  static const Color textPrimaryDark = Color(0xFFF8F9FB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color textDisabledDark = Color(0xFF4B5563);

  // ============================================
  // COULEURS PERFORMANCE
  // ============================================
  static const Color performancePositive = Color(0xFF10B981);
  static const Color performanceNegative = Color(0xFFEF4444);
  static const Color performanceNeutral = Color(0xFF6B7280);

  // ============================================
  // COULEURS GRAPHIQUES (Charts)
  // ============================================
  static const Color chart1 = Color(0xFF003D7A);
  static const Color chart2 = Color(0xFFFFB81C);
  static const Color chart3 = Color(0xFF10B981);
  static const Color chart4 = Color(0xFF3B82F6);
  static const Color chart5 = Color(0xFF8B5CF6);

  static const List<Color> chartColors = [chart1, chart2, chart3, chart4, chart5];

  // Couleurs charts dark mode
  static const Color chart1Dark = Color(0xFF4A9EFF);
  static const Color chart2Dark = Color(0xFFFFC940);
  static const Color chart3Dark = Color(0xFF34D399);
  static const Color chart4Dark = Color(0xFF60A5FA);
  static const Color chart5Dark = Color(0xFFA78BFA);

  static const List<Color> chartColorsDark = [
    chart1Dark,
    chart2Dark,
    chart3Dark,
    chart4Dark,
    chart5Dark
  ];

  // ============================================
  // COULEURS PRODUITS RETRAITE
  // ============================================
  static const Color perinColor = Color(0xFF003D7A);
  static const Color peroColor = Color(0xFF0055A5);
  static const Color ereColor = Color(0xFF10B981);
  static const Color epargneColor = Color(0xFFFFB81C);

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentYellow, accentYellowDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  // ============================================
  // RADIUS (basé sur Figma)
  // ============================================
  static const double radiusSm = 8.0; // 0.5rem
  static const double radiusMd = 10.0; // 0.625rem
  static const double radiusLg = 12.0; // 0.75rem
  static const double radiusXl = 16.0; // 1rem

  // ============================================
  // OMBRES
  // ============================================
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 15,
          offset: const Offset(0, 10),
        ),
      ];

  // Aliases pour compatibilité
  static const Color accent = accentYellow;
  static const Color accentLight = accentYellowLight;
  static const Color accentDark = accentYellowDark;
  static const Color accentSurface = accentYellowLight;
  static const Color surfaceLight = cardLight;
  static const Color surfaceDark = cardDark;
  static const Color dividerLight = borderLight;
  static const Color dividerDark = borderDark;
  static const Color primarySurface = primaryLighter;
  static const Color errorDark = errorDarkMode;
  static const Color infoDarkMode = infoDark;

  // Aliases anciens
  static List<BoxShadow> get elevationSmall => shadowSm;
  static List<BoxShadow> get elevationMedium => shadowMd;
  static List<BoxShadow> get elevationLarge => shadowLg;
}
