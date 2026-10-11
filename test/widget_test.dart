import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/app/app.dart';
import 'package:medicare/core/constants/app_strings.dart';

void main() {
  testWidgets('MediCare app launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());

    // Verify that MediCare brand name and tagline appear on the splash screen
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
  });
}
