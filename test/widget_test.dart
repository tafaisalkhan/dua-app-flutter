// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dua_app/main.dart';
import 'package:dua_app/services/notification_service.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DuaApp());

    // Verify that the splash screen shows 'Dua-ul-Anbiya'.
    expect(find.text('Dua-ul-Anbiya'), findsOneWidget);

    // Let the splash screen timers settle.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  test('NotificationService init and schedule test', () async {
    // Initialize notification service.
    await NotificationService.init();
    
    // Attempt to schedule a daily notification.
    // If it fails or throws, the test will fail.
    await NotificationService.scheduleDailyDuaNotification();
  });
}
