import 'package:flutter/material.dart';
import 'package:freegapp/src/MyUserInfo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:freegapp/src/mocks/ImagePickerMock.dart';
import 'dart:io';
import 'package:freegapp/src/ApplicationStateFirebase.dart';
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PersonalInfo extends StatefulWidget {
  PersonalInfo({
    Key? key,
  }) : super(key: key); // Initializes key for subclasses.
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final homeAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final countryController = TextEditingController();
  List<XFile>? _imageFileList;
  var currentAddress;
  var currentPosition;

  final ImagePicker _picker = ImagePicker();
  final ImagePickerMock _mockPicker = ImagePickerMock();
  final _formKey = GlobalKey<FormState>(debugLabel: '_PersonalInfoState');

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    homeAddressController.dispose();
    phoneNumberController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ApplicationStateFirebase>(
            builder: (context, appState, _) => FutureBuilder(
                future: getFormFillFromDatabase(appState.myUserInfo),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    // futurer hasn't finished yet, return a place holder
                    return Text('Loading');
                  }
                  return Form(
                      key: _formKey,
                      child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          children: <Widget>[
                            imageProfile(appState.myUserInfo.profilePic),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              key: Key('homeAddressPersonalInfo'),
                              controller: homeAddressController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Home Address',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter your home Address';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              key: Key('phoneNumberPersonalInfo'),
                              controller: phoneNumberController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Phone Number',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter your phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              key: Key('phoneNumberPersonalInfo'),
                              controller: countryController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Country',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter your country';
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('CANCEL'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final profilePic = await readImagesToBase64(
                                        _imageFileList);
                                    var homePosition =
                                        await _determinePosition();
                                    if (Platform.environment
                                            .containsKey('FLUTTER_TEST') ==
                                        true) {
                                      await ApplicationStateFirebaseMock()
                                          .addDocumentToUsers(
                                              homeAddressController.text,
                                              countryController.text,
                                              int.parse(
                                                  phoneNumberController.text),
                                              profilePic[0],
                                              homePosition.latitude,
                                              homePosition.longitude);
                                    } else {
                                      await ApplicationStateFirebase()
                                          .addDocumentToUsers(
                                              homeAddressController.text,
                                              countryController.text,
                                              int.parse(
                                                  phoneNumberController.text),
                                              profilePic[0],
                                              homePosition.latitude,
                                              homePosition.longitude);
                                    }
                                    Navigator.pop(context);
                                    // Navigator.of(context).pop();
                                  } on Exception catch (e) {
                                    _showErrorDialog(
                                        context, 'No Image Selected', e);
                                  }
                                }
                              },
                              child: const Text('Save'),
                            )
                          ]));
                })));
  }

  Future<dynamic> getFormFillFromDatabase(MyUserInfo object) async {
    homeAddressController.text = object.homeAddress as String;
    phoneNumberController.text = object.phoneNumber.toString();
    countryController.text = object.country as String;
  }

  Future<dynamic> getImageFromDatabase(String? myProfilePic) async {
    if (myProfilePic == null) {
      return null;
    } else if (_imageFileList == null) {
      print('we get here');
      final temp = await getTemporaryDirectory();
      var profilePicTemporaryFile = File('${temp.path}/imageFromFirebase.jpg');
      // if (profilePicTemporaryFile.existsSync() == true) {
      //   await profilePicTemporaryFile.delete();
      // }
      // await profilePicTemporaryFile.create(recursive: true);
      var imageInBytes = base64Decode(myProfilePic);
      imageCache?.clear();
      await File(profilePicTemporaryFile.path).writeAsBytes(imageInBytes);
      var tempList = [XFile(profilePicTemporaryFile.path)];
      _imageFileList = tempList;
    }
  }

  Widget imageProfile(String? profilePicture) {
    return Center(
      child: Stack(children: <Widget>[
        FutureBuilder(
            future: getImageFromDatabase(profilePicture),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // futurer hasn't finished yet, return a place holder
                return Text('Loading');
              }
              return CircleAvatar(
                radius: 80.0,
                backgroundImage: _imageFileList == null
                    ? null
                    : FileImage(File(_imageFileList![0].path)),
              );
            }),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.teal,
              size: 28.0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Choose Profile photo',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                _onImageButtonPressed(
                  context: context,
                );
              },
              label: Text('Gallery'),
            ),
          ])
        ],
      ),
    );
  }

  void _onImageButtonPressed({BuildContext? context}) async {
    final pickedFileList =
        Platform.environment.containsKey('FLUTTER_TEST') == true
            ? await _mockPicker.pickMultiImage()
            : await _picker.pickMultiImage();
    setState(() {
      _imageFileList = pickedFileList;
    });
  }

  Future<List<String>> readImagesToBase64(List<XFile>? imageFiles) async {
    var imageToBytes = List<Uint8List>.filled(3, Uint8List(0), growable: false);
    if (imageFiles == null) {
      throw FormatException('Pick a profile Picture');
    }
    var temp = List.filled(imageFiles.length, null.toString(), growable: true);
    for (var i = 0; i < imageFiles.length; i++) {
      imageToBytes[i] = File(imageFiles[i].path).readAsBytesSync();
      temp[i] = base64Encode(imageToBytes[i]);
    }
    return temp;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    try {
      var placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      var place = placemarks[0];

      setState(() {
        currentPosition = position;
        currentAddress =
            '${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } on Exception catch (e) {
      _showErrorDialog(context, 'idk', e);
    }
    return position;
  }
}

void _showErrorDialog(BuildContext context, String title, Exception e) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        key: Key('AlertDialogShowErrorDialogAddFoodCustomForm'),
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
