import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design System - Typographie
/// Police: Inter (moderne, lisible, accessible)
class AppTypography {
  AppTypography._();

  // ============================================
  // FAMILLE DE POLICE
  // ============================================
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // ============================================
  // TAILLES DE POLICE (Tokens)
  // ============================================
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 17.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 30.0;
  static const double fontSize4xl = 36.0;

  // ============================================
  // HAUTEURS DE LIGNE (Tokens)
  // ============================================
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // ============================================
  // POIDS DE POLICE (Tokens)
  // ============================================
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ============================================
  // STYLES - MODE CLAIR
  // ============================================

  // Titres
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: fontSize4xl,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: fontSize3xl,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: fontSize2xl,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: fontSizeXl,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightNormal,
  );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: fontSizeLg,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightNormal,
  );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightNormal,
  );

  // Corps de texte
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightRegular,
    color: AppColors.textPrimaryLight,
    height: lineHeightRelaxed,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: fontWeightRegular,
    color: AppColors.textPrimaryLight,
    height: lineHeightRelaxed,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: fontWeightRegular,
    color: AppColors.textSecondaryLight,
    height: lineHeightRelaxed,
  );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightMedium,
    color: AppColors.textPrimaryLight,
    height: lineHeightNormal,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    color: AppColors.textPrimaryLight,
    height: lineHeightNormal,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    color: AppColors.textSecondaryLight,
    height: lineHeightNormal,
    letterSpacing: 0.5,
  );

  // Montants / Chiffres
  static TextStyle get amountLarge => GoogleFonts.inter(
    fontSize: fontSize3xl,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  static TextStyle get amountMedium => GoogleFonts.inter(
    fontSize: fontSize2xl,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  static TextStyle get amountSmall => GoogleFonts.inter(
    fontSize: fontSizeLg,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: lineHeightTight,
  );

  // Performance (positif/négatif)
  static TextStyle get performancePositive => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightSemiBold,
    color: AppColors.performancePositive,
    height: lineHeightNormal,
  );

  static TextStyle get performanceNegative => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightSemiBold,
    color: AppColors.performanceNegative,
    height: lineHeightNormal,
  );

  // Boutons
  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
  );

  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
  );

  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );

  // Liens
  static TextStyle get link => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: lineHeightNormal,
  );

  // Caption / Notes
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: fontWeightRegular,
    color: AppColors.textTertiaryLight,
    height: lineHeightRelaxed,
  );

  // Overline
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    color: AppColors.textSecondaryLight,
    letterSpacing: 1.0,
    height: lineHeightNormal,
  );
}
