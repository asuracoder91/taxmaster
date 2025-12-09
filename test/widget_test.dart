// This is a basic Flutter widget test for Tax Master app.

import 'package:flutter_test/flutter_test.dart';

import 'package:tax_master/app.dart';

void main() {
  testWidgets('TaxMasterApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaxMasterApp());

    // Verify that the app loads (basic smoke test)
    expect(find.text('Tax Master'), findsAny);
  });
}
