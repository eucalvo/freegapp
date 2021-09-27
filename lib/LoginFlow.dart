import 'package:flutter/material.dart';
import 'package:freegapp/PersonalInfo.dart';
import 'package:freegapp/src/LoginFlowForms/EmailFormLogin.dart';
import 'package:freegapp/src/LoginFlowForms/PasswordFormLogin.dart';
import 'package:freegapp/Selling.dart';
import 'package:freegapp/src/LoginFlowForms/RegisterFormLogin.dart';
import 'package:freegapp/src/MyUserInfo.dart';
import 'dart:io';

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
    required this.myUserInfo,
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
  final MyUserInfo myUserInfo;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
        return EmailFormLogin(
            key: Key('EmailFormLogin'),
            callback: (email) => verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.password:
        return PasswordFormLogin(
          key: Key('PasswordFormLogin'),
          email: email!,
          login: (email, password) {
            signInWithEmailAndPassword(email, password,
                (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
        );
      case ApplicationLoginState.register:
        return RegisterFormLogin(
          key: Key('RegisterFormLogin'),
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
        if (Platform.environment.containsKey('FLUTTER_TEST') == true) {
          if (myUserInfo.userId == null) {
            return PersonalInfo(
              key: Key('PersonalInfo'),
              logout: () {
                signOut();
              },
              myUserInfo: myUserInfo,
            );
          } else {
            return Selling(
              logout: () {
                signOut();
              },
              key: Key('Selling'),
            );
          }
        } else {
          if (myUserInfo.userId == null) {
            return PersonalInfo(
              key: Key('PersonalInfo'),
              logout: () {
                signOut();
              },
              myUserInfo: myUserInfo,
            );
          } else {
            return Selling(
              logout: () {
                signOut();
              },
              key: Key('Selling'),
            );
          }
        }
      default:
        return Row(
          children: const [
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
        key: Key('AlertDialogLoginFlow'),
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
