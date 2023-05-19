// The goal of a widget test is to verify that every widget’s UI looks and behaves as expected.//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:freegapp/src/application_state_firebase.dart';

import 'package:freegapp/main.dart';

void main() {
  // The WidgetTester allows building and interacting with widgets in a test environment.
  testWidgets('MyStatefulWidget creates a default widget as a homepage',
      (WidgetTester tester) async {
    // Create the widget by telling the tester to build it. Also triggers a frame.
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (context) => ApplicationStateFirebase(),
      builder: (context, _) => MyApp(),
    ));
    expect(find.byKey(Key('default')), findsOneWidget);
    // navigationIndexBar starts at 0 so TheMap should be the widget being displayed.
    expect(find.byKey(Key('TheMap')), findsOneWidget);
    // tap on navigationIndexBar 1
    await tester.tap(find.text('icon'));
    // Rebuild the widget after the state has changed.
    await tester.pump();
    expect(find.byKey(Key('LoginFlow')), findsOneWidget);
    await tester.tap(find.text('Map'));
    await tester.pump();
    expect(find.byKey(Key('TheMap')), findsOneWidget);
  });
}
