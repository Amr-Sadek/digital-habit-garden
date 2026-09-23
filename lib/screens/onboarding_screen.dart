import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await AppController.instance.completeOnboarding();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _toggleLanguage() {
    final controller = AppController.instance;
    final currentLang = controller.locale.languageCode;
    final nextLocale = currentLang == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    controller.setLanguage(nextLocale);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isArabic = strings.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final slides = [
      _OnboardingSlideData(
        title: strings.onboardingTitle1,
        description: strings.onboardingDesc1,
        visualBuilder: (context) => _buildSlide1Visual(isDark),
      ),
      _OnboardingSlideData(
        title: strings.onboardingTitle2,
        description: strings.onboardingDesc2,
        visualBuilder: (context) => _buildSlide2Visual(isDark),
      ),
      _OnboardingSlideData(
        title: strings.onboardingTitle3,
        description: strings.onboardingDesc3,
        visualBuilder: (context) => _buildSlide3Visual(isDark),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR (LANGUAGE TOGGLE & SKIP)
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Toggle Button
                  InkWell(
                    onTap: _toggleLanguage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(
                          alpha: isDark ? .20 : .10,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(
                            alpha: isDark ? .30 : .20,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Skip Button
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        strings.skip,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkSecondaryText
                              : Colors.grey.shade700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // ==================================================
            // SLIDES PAGE VIEW
            // ==================================================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Visual Graphics
                        SizedBox(
                          height: 240,
                          child: Center(child: slide.visualBuilder(context)),
                        ),

                        const SizedBox(height: 36),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppTheme.darkText
                                : AppTheme.textColor,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==================================================
            // BOTTOM CONTROLS & PAGE INDICATOR
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  // Page Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : (isDark
                                    ? const Color(0xFF344035)
                                    : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Main Action Button (Next / Get Started)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2
                                ? strings.getStarted
                                : strings.next,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_currentPage < 2) ...[
                            const SizedBox(width: 8),
                            Icon(
                              isArabic
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SLIDE 1 VISUAL
  // ============================================================

  Widget _buildSlide1Visual(bool isDark) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: isDark ? .22 : .12),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? .25 : .12),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ============================================================
  // SLIDE 2 VISUAL
  // ============================================================

  Widget _buildSlide2Visual(bool isDark) {
    return Container(
      width: 240,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: isDark ? .30 : .18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .25 : .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppStringsScope.of(context).isArabic
                          ? '7 أيام سلسلة متواصلة 🔥'
                          : '7 Day Streak 🔥',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SLIDE 3 VISUAL
  // ============================================================

  Widget _buildSlide3Visual(bool isDark) {
    return Container(
      width: 240,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: isDark ? .30 : .18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .25 : .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFA000), width: 2),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFFFFA000),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF263238),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF2B84B), width: 2),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFF2B84B),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.palette_outlined,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppStringsScope.of(context).isArabic
                          ? 'نهار / ليل & فاتح / داكن'
                          : 'Day/Night & Light/Dark',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String description;
  final WidgetBuilder visualBuilder;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.visualBuilder,
  });
}
