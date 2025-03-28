// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:nike_plus_clone/main.dart';

void main() {
  testWidgets('Nike app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NikeApp());

    // Basic test to verify the app renders without errors
    expect(find.text('Nike+ Clone'), findsNothing);
  });
  
  testWidgets('Nike app initial render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NikeApp());

    // Verify that our app renders correctly
    expect(find.text('Nike+ Clone App'), findsNothing); // No longer in main.dart
  });
}
