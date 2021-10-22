import 'package:flutter/material.dart';
import 'package:freegapp/Selling.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter/src/services/asset_bundle.dart' show rootBundle;

class PersonalInfo extends StatefulWidget {
  PersonalInfo({
    required this.logout,
    required this.myUserInfo,
    Key? key,
  }) : super(key: key); // Initializes key for subclasses.
  final void Function() logout;
  final MyUserInfo myUserInfo;
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final homeAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  List<XFile>? _imageFileList;
  var currentAddress;
  var currentPosition;

  final ImagePicker _picker = ImagePicker();
  final ImagePickerMock _mockPicker = ImagePickerMock();
  final _formKey = GlobalKey<FormState>(debugLabel: '_PersonalInfoStateForm');
  var _formIsVisible = true;
  String? countriesJsonString;
  final defaultDropDownValue = 'Select Country';
  var dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.myUserInfo.country ?? defaultDropDownValue;
    homeAddressController.text = widget.myUserInfo.homeAddress == null
        ? ''
        : widget.myUserInfo.homeAddress.toString();
    phoneNumberController.text = widget.myUserInfo.phoneNumber == null
        ? ''
        : widget.myUserInfo.phoneNumber.toString();
    latitudeController.text = widget.myUserInfo.latitude == null
        ? ''
        : widget.myUserInfo.latitude.toString();
    longitudeController.text = widget.myUserInfo.longitude == null
        ? ''
        : widget.myUserInfo.longitude.toString();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    homeAddressController.dispose();
    phoneNumberController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
            height: 160,
            width: MediaQuery.of(context).size.width,
            child: imageProfile(widget.myUserInfo.profilePic)),
        SizedBox(
          height: 20,
        ),
        FutureBuilder(
            future: loadCountriesFromAsset(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // futurer hasn't finished yet, return a place holder
                return Text('Loading');
              }
              return DropdownButton<String>(
                key: Key('DropdownButtonPersonalInfo'),
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    print('we inside');
                    dropdownValue = newValue!;
                    if (dropdownValue == defaultDropDownValue) {
                      _formIsVisible = false;
                    } else {
                      _formIsVisible = true;
                    }
                  });
                },
                items: List<String>.from(
                        jsonDecode(countriesJsonString.toString())['names'])
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            }),
        Expanded(
            child: Visibility(
                visible: _formIsVisible, child: form(widget.myUserInfo))),
      ],
    ));
  }

  Future<dynamic> loadCountriesFromAsset() async {
    final contents = await rootBundle.loadString('assets/countries.json');
    countriesJsonString = contents;
    if (dropdownValue == defaultDropDownValue) {
      _formIsVisible = false;
    } else {
      _formIsVisible = true;
    }
  }

  Widget form(MyUserInfo userInfo) {
    return Form(
        key: _formKey,
        child: ListView(
            key: Key('ListViewFormPersonalInfo'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            children: <Widget>[
              ElevatedButton(
                  key: Key('GetLocationElevatedButtonPersonalInfo'),
                  onPressed: () async {
                    var homePosition = await _determinePosition();
                    latitudeController.text = homePosition.latitude.toString();
                    longitudeController.text =
                        homePosition.longitude.toString();
                    try {
                      var placemarks = await placemarkFromCoordinates(
                          homePosition.latitude, homePosition.longitude);

                      homeAddressController.text =
                          '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
                      setState(() {
                        dropdownValue = placemarks[0].country.toString();
                      });
                    } on Exception catch (e) {
                      _showErrorDialog(context, 'please try again', e);
                    }
                  },
                  child: Text('Get Location')),
              Text('Home Address:', textAlign: TextAlign.center),
              TextFormField(
                onEditingComplete: () async {
                  try {
                    var coordinates = await locationFromAddress(
                        dropdownValue + ', ' + homeAddressController.text);
                    latitudeController.text =
                        coordinates[0].latitude.toString();
                    longitudeController.text =
                        coordinates[0].longitude.toString();
                    FocusScope.of(context).unfocus();
                  } on Exception catch (e) {
                    _showErrorDialog(context, 'please try again', e);
                  }
                },
                key: Key('homeAddressTextFormFieldPersonalInfo'),
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
              Row(
                children: [
                  Expanded(child: Text('Latitude:')),
                  Expanded(child: Text('Longitude'))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    key: Key('LatitudeTextFormFieldPersonalInfo'),
                    controller: latitudeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'latitude',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'manually find latitude through google or tap get location';
                      }
                      return null;
                    },
                  )),
                  Expanded(
                      child: TextFormField(
                    key: Key('LongitudeTextFormFieldPersonalInfo'),
                    controller: longitudeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'longitude',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'manually find longitude through google or tap to get location';
                      }
                      return null;
                    },
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text('Phone Number:'),
              TextFormField(
                key: Key('phoneNumberTextFormFieldPersonalInfo'),
                controller: phoneNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Phone Number',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your phone number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final profilePic =
                          await readImagesToBase64(_imageFileList);
                      if (userInfo.profilePic == profilePic[0] &&
                          userInfo.userId == userInfo.userId &&
                          userInfo.name == userInfo.name &&
                          userInfo.homeAddress == homeAddressController.text &&
                          userInfo.country == dropdownValue &&
                          userInfo.latitude ==
                              double.parse(latitudeController.text) &&
                          userInfo.longitude ==
                              double.parse(longitudeController.text) &&
                          userInfo.phoneNumber ==
                              int.parse(phoneNumberController.text)) {
                        print('we no go in here?');
                        if (Navigator.canPop(context)) {
                          print('we pop!');
                          return Navigator.pop(context);
                        } else {
                          print('we push!');
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Selling(logout: () {
                                        widget.logout();
                                      })));
                          return;
                        }
                      }
                      if (Platform.environment.containsKey('FLUTTER_TEST') ==
                          true) {
                        await ApplicationStateFirebaseMock().addDocumentToUsers(
                            homeAddressController.text,
                            dropdownValue,
                            int.parse(phoneNumberController.text),
                            profilePic[0],
                            double.parse(latitudeController.text),
                            double.parse(longitudeController.text));
                      } else {
                        await ApplicationStateFirebase().addDocumentToUsers(
                            homeAddressController.text,
                            dropdownValue,
                            int.parse(phoneNumberController.text),
                            profilePic[0],
                            double.parse(latitudeController.text),
                            double.parse(longitudeController.text));
                      }
                      if (Navigator.canPop(context)) {
                        print('we pop2!');
                        Navigator.pop(context);
                      } else {
                        print('we push2!');
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Selling(logout: () {
                                      widget.logout();
                                    })));
                        // Navigator.of(context).pop();
                      }
                    } on Exception catch (e) {
                      _showErrorDialog(context, 'No Image Selected', e);
                    }
                  }
                },
                child: const Text('Save'),
              )
            ]));
  }

  Future<dynamic> getImageFromDatabase(String? myProfilePic) async {
    if (myProfilePic == null) {
      return null;
    } else if (_imageFileList == null) {
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
                key: Key('profilePicCircleAvatarPersonalInfo'),
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
