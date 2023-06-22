import 'package:flutter/material.dart';
import 'package:freegapp/src/LoginFlowForms/email_form_login.dart';
import 'package:freegapp/src/LoginFlowForms/password_form_login.dart';
import 'package:freegapp/selling.dart';
import 'package:freegapp/src/LoginFlowForms/register_form_login.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  password,
  loggedIn,
}

class LoginFlow extends StatelessWidget {
  const LoginFlow({
    required this.loginState,
    required this.email,
    required this.startLoginFlow,
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancelRegistration,
    required this.registerAccount,
    required this.signOut,
    Key? key,
  }) : super(key: key);

  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  //  typedef verifyEmail = final void Function(String email, void Function(Exception e) error,);
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
    String email,
    String password,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;
  final void Function() cancelRegistration;
  final void Function(
    String email,
    String displayName,
    String password,
    void Function(Exception e) error,
  ) registerAccount;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
        return EmailFormLogin(
            key: const Key('EmailFormLogin'),
            callback: (email) => verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.password:
        return PasswordFormLogin(
          key: const Key('PasswordFormLogin'),
          email: email!,
          login: (email, password) {
            signInWithEmailAndPassword(email, password,
                (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
        );
      case ApplicationLoginState.register:
        return RegisterFormLogin(
          key: const Key('RegisterFormLogin'),
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          registerAccount: (
            email,
            displayName,
            password,
          ) {
            registerAccount(
                email,
                displayName,
                password,
                (e) =>
                    _showErrorDialog(context, 'Failed to create account', e));
          },
        );
      case ApplicationLoginState.loggedIn:
        return Selling(
          logout: () {
            signOut();
          },
          key: const Key('Selling'),
        );
      default:
        return const Row(
          children: [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }
}

void _showErrorDialog(BuildContext context, String title, Exception e) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        key: const Key('AlertDialogLoginFlow'),
        title: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                '${(e as dynamic).message}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      );
    },
  );
}
