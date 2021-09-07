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

class PersonalInfo extends StatefulWidget {
  PersonalInfo({Key? key, required this.myUserInfo})
      : super(key: key); // Initializes key for subclasses.
  final MyUserInfo myUserInfo;
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final homeAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final countryController = TextEditingController();
  List<XFile>? _imageFileList;
  @override
  void initState() async {
    super.initState();
    homeAddressController.text = widget.myUserInfo.homeAddress == null
        ? ''
        : '${widget.myUserInfo.homeAddress}';
    phoneNumberController.text = widget.myUserInfo.phoneNumber == null
        ? ''
        : '${widget.myUserInfo.phoneNumber}';
    countryController.text =
        widget.myUserInfo.country == null ? '' : '${widget.myUserInfo.country}';
    if (widget.myUserInfo.profilePic != null) {
      var profilePicBase64 = widget.myUserInfo.profilePic as String;
      final temp = await getTemporaryDirectory();
      var profilePicTemporaryFile = File('${temp.path}/imageFromFirebase.jpg');
      await profilePicTemporaryFile.create(recursive: true);
      var imageInBytes = base64Decode(profilePicBase64);
      await File(profilePicTemporaryFile.path).writeAsBytes(imageInBytes);
      var tempList;
      _imageFileList = tempList.add(XFile(profilePicTemporaryFile.path));
    }
  }

  final ImagePicker _picker = ImagePicker();
  final ImagePickerMock _mockPicker = ImagePickerMock();
  final _formKey = GlobalKey<FormState>(debugLabel: '_PersonalInfoState');
  // String? _retrieveDataError;
  // set _imageFile(XFile? value) {
  //   _imageFileList = value == null ? null : [value];
  // }
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
        body: Form(
            key: _formKey,
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: <Widget>[
                  imageProfile(),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    key: Key('homeAddressPersonalInfo'),
                    controller: homeAddressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'title',
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
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final profilePic =
                              await readImagesToBase64(_imageFileList);
                          if (Platform.environment
                                  .containsKey('FLUTTER_TEST') ==
                              true) {
                            await ApplicationStateFirebaseMock()
                                .addDocumentToUsers(
                                    homeAddressController.text,
                                    countryController.text,
                                    int.parse(phoneNumberController.text),
                                    profilePic[0]);
                          } else {
                            await ApplicationStateFirebase().addDocumentToUsers(
                                homeAddressController.text,
                                countryController.text,
                                int.parse(phoneNumberController.text),
                                profilePic[0]);
                          }
                          Navigator.pop(context);
                          // Navigator.of(context).pop();
                        } on Exception catch (e) {
                          _showErrorDialog(context, 'No Image Selected', e);
                        }
                      }
                    },
                    child: const Text('Save'),
                  )
                ])));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
          radius: 80.0,
          backgroundImage: _imageFileList == null
              ? null
              : FileImage(File(_imageFileList![0].path)),
        ),
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

  // Text? _getRetrieveErrorWidget() {
  //   if (_retrieveDataError != null) {
  //     final result = Text(
  //       _retrieveDataError!,
  //       key: Key('_getRetrieveErrorWidgetPersonalInfo'),
  //     );
  //     _retrieveDataError = null;
  //     return result;
  //   }
  //   return null;
  // }

  // Future<void> retrieveLostData() async {
  //   final response = await _picker.retrieveLostData();
  //   if (response.isEmpty) {
  //     return;
  //   }
  //   if (response.file != null) {
  //     setState(() {
  //       _imageFile = response.file;
  //     });
  //   } else {
  //     _retrieveDataError = response.exception!.code;
  //   }
  // }
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
