// TEMPORARY diagnostic only. Delete after the muhurat find.text failure is understood.
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
// material.dart is deprecated in Flutter 3.50; migrate to package:material_ui as a separate task.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('debug muhurat texts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PanchangScreen()),
    );
    await tester.pumpAndSettle();
    for (final Element e in find.byType(Text).evaluate()) {
      final Text t = e.widget as Text;
      // ignore: avoid_print
      print('DEBUG TEXT: ${t.data}');
    }
    // ignore: avoid_print
    print(
      'DEBUG FIND 09:42: ${find.text('09:42 AM to 11:15 AM').evaluate().length}',
    );
  });
}
