import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:freegapp/LoginFlow.dart';

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
  });
}
