import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freegapp/login_flow.dart';
import 'package:freegapp/src/food.dart';
import 'dart:async'; // new
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:freegapp/firebase_options.dart';

class ApplicationStateFirebase extends ChangeNotifier {
  ApplicationStateFirebase() {
    init();
  }
  StreamSubscription<QuerySnapshot>? _foodSubscription;
  List<Food> _foods = [];
  List<Food> get foodList => _foods;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _foodSubscription = FirebaseFirestore.instance
            .collection('food')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _foods = [];
          for (var document in snapshot.docs) {
            _foods.add(
              Food(
                documentID: document.id,
                title: document.data()['title'],
                description: document.data()['description'],
                cost: document.data()['cost'].toDouble(),
                image1: document.data()['image1'],
                image2: document.data()['image2'] ?? '',
                image3: document.data()['image3'] ?? '',
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _foods = [];
        _foodSubscription?.cancel();
      }
      notifyListeners();
    });
  }

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
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Add from here
  Future<DocumentReference> addDocumentToFood(
    String id,
    String title,
    String description,
    double cost,
    List<String> images,
  ) {
    return FirebaseFirestore.instance.collection('food').add({
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
      'image1': images[0],
      'image2': images.length <= 1 ? null : images[1],
      'image3': images.length <= 2 ? null : images[2],
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void seeYouSpaceCowboy(id) {
    FirebaseFirestore.instance.collection('food').doc(id).delete();
  }
}
