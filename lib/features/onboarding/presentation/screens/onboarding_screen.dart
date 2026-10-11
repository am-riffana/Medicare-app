import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';

/// Model representing a single onboarding slide
class OnboardingItem {
  final String title;
  final String description;
  final IconData primaryIcon;
  final List<IconData> secondaryIcons;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.primaryIcon,
    required this.secondaryIcons,
    required this.accentColor,
  });
}

/// 3 Onboarding screens with PageView, progress indicator, and navigation
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Description,
      primaryIcon: Icons.medical_services_rounded,
      secondaryIcons: [
        Icons.verified_user_rounded,
        Icons.star_rounded,
        Icons.health_and_safety_rounded,
      ],
      accentColor: AppColors.primary,
    ),
    OnboardingItem(
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Description,
      primaryIcon: Icons.calendar_month_rounded,
      secondaryIcons: [
        Icons.access_time_filled_rounded,
        Icons.video_call_rounded,
        Icons.notifications_active_rounded,
      ],
      accentColor: AppColors.secondary,
    ),
    OnboardingItem(
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Description,
      primaryIcon: Icons.folder_shared_rounded,
      secondaryIcons: [
        Icons.lock_rounded,
        Icons.receipt_long_rounded,
        Icons.bloodtype_rounded,
      ],
      accentColor: Color(0xFF0D9488),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animDurationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _onSkip() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  _pageController.previousPage(
                    duration: AppConstants.animDurationNormal,
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _onSkip,
              child: Text(
                AppStrings.skip,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),
            // Bottom Area: Indicator Dots & Action Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing24,
                vertical: AppConstants.spacing24,
              ),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicatorDot(index),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  // Primary Action Button
                  AppButton(
                    text: isLastPage ? AppStrings.getStarted : AppStrings.next,
                    onPressed: _onNext,
                    icon: Icon(
                      isLastPage
                          ? Icons.arrow_forward_rounded
                          : Icons.navigate_next_rounded,
                      size: AppConstants.iconSizeMedium,
                      color: Colors.white,
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

  Widget _buildPageContent(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon Artwork Container
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow Circle
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accentColor.withValues(alpha: 0.08),
                ),
              ),
              // Inner Colored Circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accentColor.withValues(alpha: 0.15),
                ),
              ),
              // Main Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      item.accentColor,
                      item.accentColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  item.primaryIcon,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              // Secondary Floating Badges
              Positioned(
                top: 15,
                right: 25,
                child: _buildFloatingBadge(item.secondaryIcons[0], item.accentColor),
              ),
              Positioned(
                bottom: 25,
                left: 15,
                child: _buildFloatingBadge(item.secondaryIcons[1], item.accentColor),
              ),
              Positioned(
                bottom: 15,
                right: 35,
                child: _buildFloatingBadge(item.secondaryIcons[2], item.accentColor),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing40),
          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing8),
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }

  Widget _buildIndicatorDot(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: AppConstants.animDurationNormal,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 28.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].accentColor
            : AppColors.cardBorderLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
    );
  }
}
