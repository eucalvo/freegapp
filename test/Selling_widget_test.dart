// import 'dart:html';

// import 'package:image_picker/image_picker.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';
// import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:freegapp/LoginFlow.dart';

// import 'dart:io';

void main() {
  testWidgets('adding an item to Selling widget', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (context) => ApplicationStateFirebaseMock(),
        builder: (context, _) => MaterialApp(
            home: Consumer<ApplicationStateFirebaseMock>(
                builder: (context, appState, _) => LoginFlow(
                    email: appState.email,
                    loginState: appState.loginState,
                    startLoginFlow: appState.startLoginFlow,
                    verifyEmail: appState.verifyEmail,
                    signInWithEmailAndPassword:
                        appState.signInWithEmailAndPassword,
                    cancelRegistration: appState.cancelRegistration,
                    registerAccount: appState.registerAccount,
                    signOut: appState.signOut,
                    key: Key('LoginFlow'))))));
    expect(find.byKey(Key('EmailFormLogin')), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'bob@thebuilder.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('PasswordFormLogin')), findsOneWidget);
    await tester.enterText(
        find.byKey(Key('PasswordFormLoginTextFormField')), 'T3STU1D');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.byKey(Key('Selling')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('AddFoodCustomForm')), findsOneWidget);
    await tester.enterText(find.byKey(Key('titleAddFoodCustomForm')), 'test');
    await tester.enterText(
        find.byKey(Key('descriptionAddFoodCustomForm')), 'This is a test!');
    await tester.enterText(find.byKey(Key('costAddFoodCustomForm')), '10.69');
    expect(find.byKey(Key('PickImagesAddFoodCustomForm')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.photo_library));
    await tester.pumpAndSettle();
    // final _imageFileList = [
    //   'assets/imagesTesting/cow1.jpg',
    //   'assets/imagesTesting/cow2.jpg',
    //   'assets/imagesTesting/cow3.jpg',
    // ];
    expect(
        find.byKey(
            Key('SemanticsAddFoodCustomFormKeyWithListViewBuilderAsChild')),
        findsOneWidget);
    expect(find.byKey(Key('ImageFile0')), findsOneWidget);
    expect(find.byKey(Key('ImageFile1')), findsOneWidget);
    expect(find.byKey(Key('ImageFile2')), findsOneWidget);
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Selling')), findsOneWidget);
    // finds specific dismissable of item just created. the key of each dismissable
    // is int i = 0; i++
    expect(find.byKey(Key('0')), findsOneWidget);
    // swipe item to delete
    await tester.drag(find.byKey(Key('0')), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('0')), findsNothing);
  });
}
