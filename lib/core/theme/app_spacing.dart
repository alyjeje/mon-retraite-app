import 'package:flutter/material.dart';

/// Design System - Spacing & Dimensions
/// Système de spacing cohérent basé sur une grille de 4px
class AppSpacing {
  AppSpacing._();

  // ============================================
  // SPACING (Base: 4px)
  // ============================================
  static const double xxxs = 2.0;   // 0.5x
  static const double xxs = 4.0;    // 1x
  static const double xs = 8.0;     // 2x
  static const double sm = 12.0;    // 3x
  static const double md = 16.0;    // 4x
  static const double lg = 20.0;    // 5x
  static const double xl = 24.0;    // 6x
  static const double xxl = 32.0;   // 8x
  static const double xxxl = 40.0;  // 10x
  static const double xxxxl = 48.0; // 12x
  static const double xxxxxl = 64.0; // 16x

  // ============================================
  // PADDING PRÉDÉFINIS
  // ============================================
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Padding horizontal
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Padding vertical
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Padding écran standard
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  // ============================================
  // BORDER RADIUS
  // ============================================
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;

  // BorderRadius prédéfinis
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Card radius
  static BorderRadius get cardRadius => borderRadiusLg;

  // Button radius
  static BorderRadius get buttonRadius => borderRadiusMd;

  // Input radius
  static BorderRadius get inputRadius => borderRadiusMd;

  // ============================================
  // TAILLES DE COMPOSANTS
  // ============================================

  // Boutons
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Inputs
  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 52.0;
  static const double inputHeightLg = 60.0;

  // Icons
  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;
  static const double iconSizeXxl = 48.0;

  // Avatars
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 40.0;
  static const double avatarSizeLg = 56.0;
  static const double avatarSizeXl = 80.0;

  // Bottom Navigation
  static const double bottomNavHeight = 80.0;

  // App Bar
  static const double appBarHeight = 56.0;

  // Cards
  static const double cardMinHeight = 80.0;

  // ============================================
  // GAP / ESPACEMENT ENTRE ÉLÉMENTS
  // ============================================
  static const SizedBox gapXxs = SizedBox(height: xxs, width: xxs);
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);

  // Gaps verticaux
  static const SizedBox verticalGapXxs = SizedBox(height: xxs);
  static const SizedBox verticalGapXs = SizedBox(height: xs);
  static const SizedBox verticalGapSm = SizedBox(height: sm);
  static const SizedBox verticalGapMd = SizedBox(height: md);
  static const SizedBox verticalGapLg = SizedBox(height: lg);
  static const SizedBox verticalGapXl = SizedBox(height: xl);
  static const SizedBox verticalGapXxl = SizedBox(height: xxl);

  // Gaps horizontaux
  static const SizedBox horizontalGapXxs = SizedBox(width: xxs);
  static const SizedBox horizontalGapXs = SizedBox(width: xs);
  static const SizedBox horizontalGapSm = SizedBox(width: sm);
  static const SizedBox horizontalGapMd = SizedBox(width: md);
  static const SizedBox horizontalGapLg = SizedBox(width: lg);
  static const SizedBox horizontalGapXl = SizedBox(width: xl);
  static const SizedBox horizontalGapXxl = SizedBox(width: xxl);

  // ============================================
  // ANIMATIONS
  // ============================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveIn = Curves.easeIn;
  static const Curve animationCurveOut = Curves.easeOut;
}
