import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Variantes de bouton
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  accent,
}

/// Tailles de bouton
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Bouton personnalisé réutilisable
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isEnabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark),
    );
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: _buildChild(Colors.white),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.cardDark : AppColors.primarySurface,
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
            elevation: 0,
          ),
          child: _buildChild(AppColors.primary),
        );

      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: _buildChild(AppColors.primary),
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: _buildChild(AppColors.primary),
        );

      case AppButtonVariant.accent:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimaryLight,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: _buildChild(AppColors.textPrimaryLight),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _getIconSize()),
          SizedBox(width: AppSpacing.xs),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          SizedBox(width: AppSpacing.xs),
          Icon(trailingIcon, size: _getIconSize()),
        ],
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case AppButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case AppButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}

/// Bouton icône
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool hasBadge;
  final int badgeCount;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.tooltip,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor = backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.backgroundLight);
    final effectiveIconColor = iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    Widget button = Material(
      color: effectiveBgColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: effectiveIconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );

    if (hasBadge && badgeCount > 0) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
