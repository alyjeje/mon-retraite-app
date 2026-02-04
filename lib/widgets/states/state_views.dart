import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/theme.dart';
import '../buttons/app_button.dart';

/// Vue de chargement avec shimmer
class LoadingView extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const LoadingView({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 120,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding ?? AppSpacing.screenPadding,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Shimmer.fromColors(
              baseColor: isDark ? AppColors.cardDark : Colors.grey.shade300,
              highlightColor:
                  isDark ? AppColors.borderDark : Colors.grey.shade100,
              child: Container(
                height: itemHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.cardRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer pour une carte
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : Colors.grey.shade300,
      highlightColor: isDark ? AppColors.borderDark : Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.cardRadius,
        ),
      ),
    );
  }
}

/// Vue vide (aucune donnée)
class EmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryDark.withValues(alpha: 0.3)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            AppSpacing.verticalGapXl,
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapSm,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalGapXl,
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vue d'erreur
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    this.title = 'Une erreur est survenue',
    this.message = 'Nous n\'avons pas pu charger les données. Veuillez réessayer.',
    this.retryLabel = 'Réessayer',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalGapXl,
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapSm,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalGapXl,
              AppButton(
                label: retryLabel!,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
                isFullWidth: false,
                leadingIcon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vue de succès
class SuccessView extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SuccessView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
            ),
            AppSpacing.verticalGapXl,
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapSm,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalGapXl,
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Indicateur de chargement en ligne
class InlineLoader extends StatelessWidget {
  final String? message;
  final double size;

  const InlineLoader({
    super.key,
    this.message,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          AppSpacing.horizontalGapSm,
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
