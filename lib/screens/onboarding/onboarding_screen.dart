import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran d'onboarding pour les nouveaux utilisateurs
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Bienvenue dans votre espace retraite',
      description:
          'Suivez l\'évolution de votre épargne retraite en temps réel et prenez les bonnes décisions pour votre avenir.',
      icon: Icons.savings_outlined,
      color: AppColors.primary,
    ),
    _OnboardingPage(
      title: 'Comprenez vos produits',
      description:
          'PERIN, PERO, épargne salariale... Découvrez des explications simples et pédagogiques sur vos contrats.',
      icon: Icons.school_outlined,
      color: AppColors.info,
    ),
    _OnboardingPage(
      title: 'Gérez en autonomie',
      description:
          'Effectuez vos versements, consultez vos documents et modifiez vos informations en toute simplicité.',
      icon: Icons.touch_app_outlined,
      color: AppColors.success,
    ),
    _OnboardingPage(
      title: 'Simulez votre retraite',
      description:
          'Projetez-vous dans l\'avenir avec nos simulateurs et ajustez votre stratégie d\'épargne.',
      icon: Icons.calculate_outlined,
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    'Passer',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(context, page);
                },
              ),
            ),

            // Indicators and button
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: AppSpacing.animationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalGapXl,

                  // Button
                  AppButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        widget.onComplete();
                      } else {
                        _pageController.nextPage(
                          duration: AppSpacing.animationNormal,
                          curve: AppSpacing.animationCurve,
                        );
                      }
                    },
                    trailingIcon: _currentPage == _pages.length - 1
                        ? null
                        : Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, _OnboardingPage page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          AppSpacing.verticalGapXxl,

          // Title
          Text(
            page.title,
            style: AppTypography.headlineLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalGapMd,

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
