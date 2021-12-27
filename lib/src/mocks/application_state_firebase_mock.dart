import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
// ignore: implementation_imports
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:freegapp/login_flow.dart';
import 'package:freegapp/src/food.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'dart:async';
import 'package:freegapp/src/my_user_info.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'bob@thebuilder.com',
  displayName: 'Bob Builder',
  phoneNumber: '0800 I CAN FIX IT',
  photoURL: 'http://photos.url/bobbie.jpg',
  refreshToken: 'some_long_token',
);

final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
final instance = FakeFirebaseFirestore();
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

class MockQuerySnapshot {}

class ApplicationStateFirebaseMock extends ChangeNotifier {
  ApplicationStateFirebaseMock() {
    init();
  }

  List<Food> _foods = [];
  MyUserInfo _myUserInfo = MyUserInfo();
  List<Food> get foodList => _foods;
  MyUserInfo get myUserInfo => _myUserInfo;

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  Future<void> init() async {
    var i = 0;
    if (auth.currentUser != null) {
      instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .snapshots()
          .listen((documentSnapshot) {
        if (documentSnapshot.exists) {
          _myUserInfo = MyUserInfo(
            userId: documentSnapshot.id,
            name: documentSnapshot['name'],
            country: documentSnapshot['country'],
            homeAddress: documentSnapshot['homeAddress'],
            phoneNumber: documentSnapshot['phoneNumber'],
            profilePic: documentSnapshot['profilePic'],
            latitude: documentSnapshot['latitude'],
            longitude: documentSnapshot['longitude'],
          );
          // data = documentSnapshot.data();
        } else {
          _myUserInfo = MyUserInfo();
        }
        notifyListeners();
      });
      instance
          .collection('food')
          .where('userId', isEqualTo: auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        _foods = [];
        snapshot.docs.forEach((document) {
          _foods.add(
            Food(
              userId: document.data()['userId'],
              documentID: '$i',
              title: document.data()['title'],
              description: document.data()['description'],
              cost: document.data()['cost'].toDouble(),
              image1: document.data()['image1'],
              image2: document.data()['image2'] ?? '',
              image3: document.data()['image3'] ?? '',
            ),
          );
          i++;
        });
        notifyListeners();
      });
    } else {
      _loginState = ApplicationLoginState.loggedOut;
      _foods = [];
      _myUserInfo = MyUserInfo();
    }
    notifyListeners();
  }

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
        await addDocumentToUsers(
            '123 nowhere st, Stockton, California',
            'United States',
            1234567890,
            base64Encode(
                File('assets/imagesTesting/cow1.jpg').readAsBytesSync()),
            39.143879,
            -121.655434);
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
    _loginState = ApplicationLoginState.loggedOut;
    notifyListeners();
  }

  Future<void> addDocumentToFood(
    String id,
    String title,
    String description,
    double cost,
    List<String> images,
  ) {
    return instance.collection('food').add({
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
      'image1': images[0],
      'image2': images.length <= 1 ? null : images[1],
      'image3': images.length <= 2 ? null : images[2],
      'name': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> addDocumentToUsers(
    String homeAddress,
    String country,
    int phoneNumber,
    String profilePic,
    double latitude,
    double longitude,
  ) async {
    await instance.collection('users').doc(auth.currentUser!.uid).set({
      'homeAddress': homeAddress,
      'country': country,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'name': auth.currentUser!.displayName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  void seeYouSpaceCowboy(id) {
    instance.collection('food').doc(id).delete();
  }
}
