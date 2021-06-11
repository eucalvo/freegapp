// The goal of a widget test is to verify that every widget’s UI looks and behaves as expected.//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freegapp/main.dart';

void main() {
  // The WidgetTester allows building and interacting with widgets in a test environment.
  testWidgets('MyApp creates a homepage widget called Map',
      (WidgetTester tester) async {
    // Create the widget by telling the tester to build it. Also triggers a frame.
    await tester.pumpWidget(MyApp());
    // Create the Finders.
    final titleFinder = find.text('Map');
    // Use the `findsOneWidget` matcher provided by flutter_test to verify
    // that the Text widgets appear exactly once in the widget tree.
    expect(titleFinder, findsOneWidget);
  });
}
