import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';

import 'package:freegapp/LoginFlow.dart';

void main() {
// TextField widgets require a Material widget ancestor.
// In material design, most widgets are conceptually "printed" on a sheet of material. In Flutter's
// material library, that material is represented by the Material widget. It is the Material widget
// that renders ink splashes, for instance. Because of this, many material library widgets require that
// there be a Material widget in the tree above them.
// To introduce a Material widget, you can either directly include one, or use a widget that contains
// Material itself, such as a Card, Dialog, Drawer, or Scaffold.
  testWidgets('Login with accepted email and password',
      (WidgetTester tester) async {
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
    // Enter 'bob@thebuilder.com' into the TextField.
    await tester.enterText(find.byType(TextFormField), 'bob');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('AlertDialogLoginFlow')), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'bob@thebuilder.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('PasswordFormLogin')), findsOneWidget);
    await tester.enterText(
        find.byKey(Key('PasswordFormLoginTextFormField')), 'T3STU1D1');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.byKey(Key('AlertDialogLoginFlow')), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.enterText(
        find.byKey(Key('PasswordFormLoginTextFormField')), 'T3STU1D');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.byKey(Key('Selling')), findsOneWidget);
  });
  testWidgets('Go to register page', (WidgetTester tester) async {
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
    // Enter 'dom@thebuilder.com' into the TextField.
    await tester.enterText(find.byType(TextFormField), 'dom@thebuilder.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('RegisterFormLogin')), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pump();
    expect(find.byKey(Key('EmailFormLogin')), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'dom@thebuilder.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.enterText(
        find.byKey(Key('DisplayNameNameRegisterFormLogin')), 'Dom Builder');
    await tester.enterText(
        find.byKey(Key('PasswordRegisterFormLogin')), 'T3STU1D');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('Selling')), findsOneWidget);
  });
}
