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
    // FileImage(File('assets/imagesTesting/cow1.jpg')),
    await tester.tap(find.byIcon(Icons.image));
    await tester.pumpAndSettle();
    // var profilePic = CircleAvatar(
    //   radius: 80.0,
    //   backgroundImage: FileImage(File('assets/imagesTesting/cow1.jpg')),
    // );
    expect(
        find.byKey(Key('profilePicCircleAvatarPersonalInfo')), findsOneWidget);
    // expect(find.byWidget(profilePic), findsOneWidget);
    await tester.tap(find.byKey(Key('countryElevateButtonPersonalInfo')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afghanistan'));
    await tester.pumpAndSettle();
  });
}
