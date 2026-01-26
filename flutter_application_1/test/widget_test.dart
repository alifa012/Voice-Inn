import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ Import your actual app entry point
import 'package:voice_inn/main.dart';

void main() {
  testWidgets('VoiceInnApp loads home screen with articles',
      (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const VoiceInnApp());

    // Verify that sample articles are displayed on the HomeScreen
    expect(find.text('Breaking News: Flutter Rising'), findsOneWidget);
    expect(find.text('AI in News Apps'), findsOneWidget);
  });

  testWidgets('Tapping an article navigates to detail screen',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const VoiceInnApp());

    // Tap on the first article
    await tester.tap(find.text('Breaking News: Flutter Rising'));
    await tester.pumpAndSettle();

    // Verify that the detail screen shows the article content
    expect(find.text('Flutter adoption is rapidly increasing.'), findsOneWidget);
  });
}
