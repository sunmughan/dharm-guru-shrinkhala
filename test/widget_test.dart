import 'package:dharm_guru_shrinkhala/core/navigation/app_shell.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/widgets/kundli_chart.dart';
// material.dart is deprecated in Flutter 3.50; migrate to package:material_ui as a separate task.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shows onboarding when splash is skipped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const DharmGuruApp(showSplash: false, firebaseReady: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter birth details'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('Chart shows lagna rashi and all nine planets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: KundliChart()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Meena'), findsOneWidget);
    expect(find.text('Lagna'), findsOneWidget);
    expect(find.text('As'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('Ma'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('Ju'), findsOneWidget);
    expect(find.text('Ve'), findsOneWidget);
    expect(find.text('Ra'), findsOneWidget);
    expect(find.text('Ke'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('Panchang shows the exact spec values on Saturday',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PanchangScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saturday, Jaipur'), findsOneWidget);
    expect(find.text('Shukla Panchami'), findsOneWidget);
    expect(find.text('Shanivaar'), findsOneWidget);
    expect(find.text('Rohini till 04:12 PM'), findsOneWidget);
    expect(find.text('Siddhi'), findsOneWidget);
    expect(find.text('Bava'), findsOneWidget);
    expect(find.text('06:48 AM'), findsOneWidget);
    expect(find.text('05:52 PM'), findsOneWidget);
    // The muhurat card sits below the fold, so the ListView only
    // builds it once scrolled into view.
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('09:42 AM to 11:15 AM'), findsOneWidget);
    expect(find.text('04:30 PM to 06:05 PM'), findsOneWidget);
    expect(find.text('Rahu Kaal'), findsOneWidget);
  });
}
