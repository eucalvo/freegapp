import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:freegapp/PersonalInfo.dart';
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
// import 'dart:io';

void main() {
  testWidgets('make profile', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (context) => ApplicationStateFirebaseMock(),
        builder: (context, _) => MaterialApp(
            home: Consumer<ApplicationStateFirebaseMock>(
                builder: (context, appState, _) => PersonalInfo(
                    key: Key('PersonalInfo'),
                    logout: () {
                      appState.signOut;
                    },
                    myUserInfo: appState.myUserInfo)))));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('PersonalInfo')), findsOneWidget);
    expect(
        find.byKey(Key('profilePicCircleAvatarPersonalInfo')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.image));
    await tester.pumpAndSettle();
    expect(
        find.byKey(Key('profilePicCircleAvatarPersonalInfo')), findsOneWidget);
    // expect(find.text('Select Country'), findsOneWidget);
    expect(
        (tester.widget(find.byKey(Key('DropdownButtonPersonalInfo')))
                as DropdownButton)
            .value,
        equals('Select Country'));
    expect(find.byKey(Key('ListViewFormPersonalInfo')), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_downward), warnIfMissed: false);
    // await tester.tap(find.byIcon(Icons.arrow_downward), warnIfMissed: false);
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    // after opening the menu we have two widgets with text 'Afghanistan'
    // one in index stack of the dropdown button and one in the menu .
    // apparently the last one is from the menu.
    await tester.tap(find.text('Afghanistan').last, warnIfMissed: false);
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    expect(
        (tester.widget(find.byKey(Key('DropdownButtonPersonalInfo')))
                as DropdownButton)
            .value,
        equals('Afghanistan'));
    // expect(find.byKey(Key('ListViewFormPersonalInfo')), findsOneWidget);
  });
}
