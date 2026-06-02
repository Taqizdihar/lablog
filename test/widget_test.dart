// Basic Flutter widget test for LabLog app.

import 'package:flutter_test/flutter_test.dart';

import 'package:tubes_ppbl/main.dart';

void main() {
  testWidgets('LabLog app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LabLogApp());

    // Verify that the app title is displayed.
    expect(find.text('LabLog'), findsOneWidget);
  });
}
