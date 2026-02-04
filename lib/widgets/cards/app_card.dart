import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Carte de base réutilisable
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight))
            : null,
        gradient: gradient,
        borderRadius: borderRadius ?? AppSpacing.cardRadius,
        border: border ??
            Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: padding ?? AppSpacing.paddingMd,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppSpacing.cardRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Carte avec gradient premium (style Gan)
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.cardGradient,
      padding: padding ?? AppSpacing.paddingLg,
      border: Border.all(color: Colors.transparent),
      boxShadow: AppColors.elevationMedium,
      onTap: onTap,
      child: child,
    );
  }
}

/// Carte de résumé avec titre et valeur
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: AppSpacing.iconSizeMd,
              ),
            ),
            AppSpacing.horizontalGapMd,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: valueColor ??
                        (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalGapXxs,
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
        ],
      ),
    );
  }
}

/// Carte d'alerte/notification
class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final AlertCardType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    this.type = AlertCardType.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: _getBackgroundColor(),
      border: Border.all(color: _getBorderColor(), width: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: AppSpacing.iconSizeMd,
          ),
          AppSpacing.horizontalGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: _getTextColor(),
                  ),
                ),
                AppSpacing.verticalGapXxs,
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: _getTextColor().withValues(alpha: 0.8),
                  ),
                ),
                if (actionLabel != null) ...[
                  AppSpacing.verticalGapSm,
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: AppTypography.labelMedium.copyWith(
                        color: _getIconColor(),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 18,
                color: _getTextColor().withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AlertCardType.info:
        return AppColors.infoLight;
      case AlertCardType.success:
        return AppColors.successLight;
      case AlertCardType.warning:
        return AppColors.warningLight;
      case AlertCardType.error:
        return AppColors.errorLight;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case AlertCardType.info:
        return AppColors.info.withValues(alpha: 0.3);
      case AlertCardType.success:
        return AppColors.success.withValues(alpha: 0.3);
      case AlertCardType.warning:
        return AppColors.warning.withValues(alpha: 0.3);
      case AlertCardType.error:
        return AppColors.error.withValues(alpha: 0.3);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AlertCardType.info:
        return AppColors.infoTextOnLight;
      case AlertCardType.success:
        return AppColors.successTextOnLight;
      case AlertCardType.warning:
        return AppColors.warningTextOnLight;
      case AlertCardType.error:
        return AppColors.errorTextOnLight;
    }
  }

  Color _getTextColor() {
    // Couleurs de texte avec bon contraste sur fonds clairs (WCAG AA)
    switch (type) {
      case AlertCardType.info:
        return AppColors.infoTextOnLight;
      case AlertCardType.success:
        return AppColors.successTextOnLight;
      case AlertCardType.warning:
        return AppColors.warningTextOnLight;
      case AlertCardType.error:
        return AppColors.errorTextOnLight;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AlertCardType.info:
        return Icons.info_outline;
      case AlertCardType.success:
        return Icons.check_circle_outline;
      case AlertCardType.warning:
        return Icons.warning_amber_outlined;
      case AlertCardType.error:
        return Icons.error_outline;
    }
  }
}

enum AlertCardType { info, success, warning, error }
