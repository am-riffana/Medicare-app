import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/app/app.dart';
import 'package:medicare/core/constants/app_strings.dart';
import 'package:medicare/core/widgets/app_button.dart';
import 'package:medicare/core/widgets/app_text_field.dart';

void main() {
  testWidgets('Full flow test: Splash -> Onboarding -> Login navigation works',
      (WidgetTester tester) async {
    // 1. Launch App
    await tester.pumpWidget(const MediCareApp());
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    // 2. Allow splash timer (2200ms) to trigger navigation to Onboarding
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen 1
    expect(find.text(AppStrings.onboarding1Title), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);
    expect(find.text(AppStrings.next), findsOneWidget);

    // 3. Tap Next to go to Onboarding Screen 2
    await tester.tap(find.widgetWithText(AppButton, AppStrings.next));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboarding2Title), findsOneWidget);

    // 4. Tap Next to go to Onboarding Screen 3
    await tester.tap(find.widgetWithText(AppButton, AppStrings.next));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboarding3Title), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);

    // 5. Tap "Get Started" to navigate to Login Screen
    await tester.tap(find.widgetWithText(AppButton, AppStrings.getStarted));
    await tester.pumpAndSettle();

    // Verify Login Screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.welcomeBackSubtitle), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(find.widgetWithText(AppButton, AppStrings.signIn), findsOneWidget);

    // Test password visibility toggle
    final Finder toggleFinder = find.byIcon(Icons.visibility_outlined);
    expect(toggleFinder, findsOneWidget);
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('Skip button on Onboarding leads directly to Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboarding1Title), findsOneWidget);

    // Tap Skip
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Directly in Login screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.widgetWithText(AppButton, AppStrings.signIn), findsOneWidget);
  });
}
