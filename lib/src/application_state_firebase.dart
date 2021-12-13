import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freegapp/login_flow.dart';
import 'package:freegapp/src/food.dart';
import 'package:freegapp/src/my_user_info.dart';
import 'dart:async'; // new
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freegapp/src/coordinateInfo.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class ApplicationStateFirebase extends ChangeNotifier {
  ApplicationStateFirebase() {
    init();
  }
  StreamSubscription<QuerySnapshot>? _foodSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _usersSubscription;
  List<Food> _foods = [];
  List<Food> _foodsMap = [];
  List<String> _userIdSellingFood = [];
  List<CoordinateInfo> _coordinateInfo = [];
  MyUserInfo _myUserInfo = MyUserInfo();
  Set<String> get userIdSellingFood => _userIdSellingFood.toSet();
  List<Food> get foodList => _foods;
  List<Food> get foodMapList => _foodsMap;
  List<CoordinateInfo> get coordinateInfoList => _coordinateInfo;
  MyUserInfo get myUserInfo => _myUserInfo;

  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      getCoordinatesForMap();
      FirebaseFirestore.instance
          .collection('food')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        _userIdSellingFood = [];
        snapshot.docs.forEach((document) {
          _userIdSellingFood.add(document.data()['userId']);
        });
        notifyListeners();
      });
      FirebaseFirestore.instance
          .collection('food')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        _foodsMap = [];
        snapshot.docs.forEach((document) {
          _foodsMap.add(
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
        });
        notifyListeners();
      });
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _usersSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
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
        _foodSubscription = FirebaseFirestore.instance
            .collection('food')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _foods = [];
          snapshot.docs.forEach((document) {
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
          });
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _foods = [];
        _myUserInfo = MyUserInfo();
        _foodSubscription?.cancel();
        _usersSubscription?.cancel();
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

  Future<void> addDocumentToUsers(
    String homeAddress,
    String country,
    int phoneNumber,
    String profilePic,
    double latitude,
    double longitude,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'homeAddress': homeAddress,
      'country': country,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  void seeYouSpaceCowboy(id) {
    FirebaseFirestore.instance.collection('food').doc(id).delete();
  }

  void getCoordinatesForMap() {
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _coordinateInfo = [];
      snapshot.docs.forEach((document) {
        _coordinateInfo.add(
          CoordinateInfo(
            userId: document.id,
            latitude: document.data()['latitude'].toDouble(),
            longitude: document.data()['longitude'].toDouble(),
          ),
        );
      });
      notifyListeners();
    });
  }
}
