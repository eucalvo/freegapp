import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
// ignore: implementation_imports
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:freegapp/LoginFlow.dart';

void main() {
  testWidgets('adding an item to Selling widget', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: (context, _) => MaterialApp(
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
    expect(find.byKey(Key('Selling')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('AddFoodCustomForm')), findsOneWidget);
  });
}

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
final passwordError = FirebaseAuthException(
  code: 'wrong-password:',
  message: 'The password entered is incorrect',
);
final emailError = FirebaseAuthException(
  code: 'invalid-email:',
  message: 'Email is badly formatted',
);
Future<MockUserCredential> createUserWithEmailAndPassword(
    {required String email, required String password}) async {
  return MockUserCredential(false, mockUser: tUser);
}

Future<void> updateDisplayName(String? displayName) {
  // pretend to updateDisplayName
  return tUser.reload();
}

class ApplicationState extends ChangeNotifier {
  ApplicationLoginState _loginState = ApplicationLoginState.loggedIn;
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
      } else if (email.contains('@') && email.contains('.')) {
        _loginState = ApplicationLoginState.register;
      } else {
        errorCallback(emailError);
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
      if (result.user == tUser && password == 'T3STU1D') {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        errorCallback(passwordError);
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
      await createUserWithEmailAndPassword(email: email, password: password);
      await updateDisplayName(displayName);
      _loginState = ApplicationLoginState.loggedIn;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    auth.signOut();
  }
}
