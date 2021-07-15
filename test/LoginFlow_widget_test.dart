import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:freegapp/LoginFlow.dart';

final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'bob@thebuilder.com',
  displayName: 'Bob Builder',
  phoneNumber: '0800 I CAN FIX IT',
  photoURL: 'http://photos.url/bobbie.jpg',
  refreshToken: 'some_long_token',
);

final auth = MockFirebaseAuth(mockUser: tUser);
final theError = FirebaseAuthException(
  code: 'wrong-password:',
  message: 'The password entered is incorrect',
);
void main() {
// TextField widgets require a Material widget ancestor.
// In material design, most widgets are conceptually "printed" on a sheet of material. In Flutter's
// material library, that material is represented by the Material widget. It is the Material widget
// that renders ink splashes, for instance. Because of this, many material library widgets require that
// there be a Material widget in the tree above them.
// To introduce a Material widget, you can either directly include one, or use a widget that contains
// Material itself, such as a Card, Dialog, Drawer, or Scaffold.
  testWidgets('Login with accepted email', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: (context, _) => MaterialApp(
            title: 'Freegap',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Consumer<ApplicationState>(
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
    await tester.enterText(find.byType(TextFormField), 'bob@thebuilder.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byKey(Key('PasswordFormLogin')), findsOneWidget);
    await tester.enterText(
        find.byKey(Key('PasswordFormLoginTextFormField')), 'T3STU1D');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.byKey(Key('Sell')), findsOneWidget);
    // expect(find.byKey(Key('AlertDialogLoginFlow')), findsOneWidget);
  });
}

class ApplicationState extends ChangeNotifier {
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods = await Future.value(['password']);
      if (methods.contains('password') && email == 'bob@thebuilder.com') {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == tUser) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        errorCallback(theError);
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.loggedOut;
    notifyListeners();
  }

  void registerAccount(String email, String displayName, String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    auth.signOut();
  }
}
