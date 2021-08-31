import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freegapp/src/ApplicationStateFirebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:freegapp/src/mocks/ApplicationStateFirebaseMock.dart';
import 'package:freegapp/src/mocks/ImagePickerMock.dart';

class AddFoodCustomForm extends StatefulWidget {
  AddFoodCustomForm({Key? key})
      : super(key: key); // Initializes key for subclasses.

  @override
  _AddFoodCustomFormState createState() => _AddFoodCustomFormState();
}

class _AddFoodCustomFormState extends State<AddFoodCustomForm> {
  List<XFile>? _imageFileList;
  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  dynamic _pickImageError;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();
  final ImagePickerMock _mockPicker = ImagePickerMock();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();
  var uuid = Uuid();
  var images;
  final imageHeight = 100.0;
  var validate = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    descriptionController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      SafeArea(
          child: Container(
              height: imageHeight,
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                FloatingActionButton(
                  onPressed: () {
                    _onImageButtonPressed(
                      context: context,
                    );
                  },
                  heroTag: 'image1',
                  tooltip: 'Pick Multiple Image from gallery',
                  child: const Icon(Icons.photo_library),
                ),
                _previewImages(),
              ]))),
      TextField(
        key: Key('titleAddFoodCustomForm'),
        controller: titleController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'title',
            errorText: validate ? 'Value Can\'t Be Empty' : null),
      ),
      TextField(
        key: Key('descriptionAddFoodCustomForm'),
        controller: descriptionController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'description',
            errorText: validate ? 'Value Can\'t Be Empty' : null),
      ),
      TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        key: Key('costAddFoodCustomForm'),
        controller: costController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'cost',
            errorText: validate ? 'Value Can\'t Be Empty' : null),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('CANCEL'),
      ),
      FloatingActionButton(
        onPressed: () async {
          try {
            images = await readImagesToBase64(_imageFileList);
            if (titleController.text.isEmpty ||
                descriptionController.text.isEmpty ||
                costController.text.isEmpty) {
              setState(() {
                validate = true;
              });
            } else {
              await writeToFirebase(titleController.text,
                  descriptionController.text, costController.text, images);
              Navigator.pop(context);
            }
          } on Exception catch (e) {
            _showErrorDialog(context, 'No Image Selected', e);
          }
        },
        child: const Text('Upload'),
      ),
    ]));
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

  Widget _previewImages() {
    final retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
        key: Key('SemanticsAddFoodCustomFormKeyWithListViewBuilderAsChild'),
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList![index].path,
                      height: imageHeight, width: 100, fit: BoxFit.cover)
                  : Image.file(
                      File(_imageFileList![index].path),
                      height: imageHeight,
                      width: 100,
                      fit: BoxFit.cover,
                      key: Key('ImageFile$index'),
                    ),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
        key: Key('_pickImageErrorAddFoodCustomForm'),
      );
    } else {
      return const Text(
        'Pick up to 3 images.',
        textAlign: TextAlign.center,
        key: Key('PickImagesAddFoodCustomForm'),
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final result = Text(
        _retrieveDataError!,
        key: Key('_getRetrieveErrorWidgetAddFoodCustomForm'),
      );
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Map<String, dynamic> toMap(id, title, description, cost) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
    };
  }

  Future<void> writeToFirebase(
      String title, String description, String cost, List<String> image) async {
    var id = uuid.v4();
    var mockAppState = ApplicationStateFirebaseMock();
    var appState = ApplicationStateFirebase();
    if (Platform.environment.containsKey('FLUTTER_TEST') == true) {
      await mockAppState.addDocumentToFood(
          id, title, description, double.parse(cost), images);
    } else {
      await appState.addDocumentToFood(
          id, title, description, double.parse(cost), images);
    }
  }

  Future<List<dynamic>> readImagesToBase64(List<XFile>? imageFiles) async {
    var imageToBytes = List<Uint8List>.filled(3, Uint8List(0), growable: false);
    if (imageFiles == null) {
      throw FormatException('Pick at least 1 image');
    }
    var temp = List.filled(imageFiles.length, null.toString(), growable: true);
    for (var i = 0; i < imageFiles.length; i++) {
      imageToBytes[i] = File(imageFiles[i].path).readAsBytesSync();
      temp[i] = base64Encode(imageToBytes[i]);
    }
    return temp;
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
