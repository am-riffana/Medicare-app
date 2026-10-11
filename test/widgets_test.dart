import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/core/widgets/app_button.dart';
import 'package:medicare/core/widgets/app_text_field.dart';
import 'package:medicare/core/widgets/empty_state_view.dart';
import 'package:medicare/core/widgets/error_view.dart';
import 'package:medicare/core/widgets/loading_indicator.dart';

void main() {
  group('Core Reusable Widgets Tests', () {
    testWidgets('AppButton renders and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Confirm',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      expect(tapped, isTrue);
    });

    testWidgets('AppButton shows loading spinner when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Save',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('AppTextField handles input and password toggle',
        (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              labelText: 'Password',
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'secret123');
      expect(controller.text, 'secret123');

      // Toggle visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('AppLoadingIndicator displays spinner and optional text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingIndicator(message: 'Fetching clinics...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fetching clinics...'), findsOneWidget);
    });

    testWidgets('AppErrorView renders error details and handles retry',
        (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              title: 'Connection Lost',
              message: 'Check your internet connection',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Check your internet connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('AppEmptyState renders title, description, and action button',
        (WidgetTester tester) async {
      bool actionClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Appointments',
              description: 'You have no scheduled doctor visits.',
              actionText: 'Book Now',
              onAction: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No Appointments'), findsOneWidget);
      expect(find.text('You have no scheduled doctor visits.'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);

      await tester.tap(find.text('Book Now'));
      expect(actionClicked, isTrue);
    });
  });
}
