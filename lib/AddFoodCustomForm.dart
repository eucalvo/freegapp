import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freegapp/src/ApplicationStateFirebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();
  var uuid = Uuid();
  var images;

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
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Column(children: [
      Column(children: [
        SafeArea(
            child: Container(
                height: 100,
                width: screenWidth,
                child: Row(children: [
                  FloatingActionButton(
                    onPressed: () {
                      _onImageButtonPressed(
                        ImageSource.gallery,
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
          controller: titleController,
          decoration:
              InputDecoration(border: OutlineInputBorder(), hintText: 'title'),
        ),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'description'),
        ),
        TextField(
          controller: costController,
          decoration:
              InputDecoration(border: OutlineInputBorder(), hintText: 'cost'),
        )
      ]),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('CANCEL'),
      ),
      FloatingActionButton(
        onPressed: () async {
          Navigator.pop(context);
          images = await readImagesToBase64(_imageFileList);
          await writeToFirebase(titleController.text,
              descriptionController.text, costController.text, images);
        },
        child: const Text('Upload'),
      ),
    ]));
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    final pickedFileList = await _picker.pickMultiImage();
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
                  ? Image.network(_imageFileList![index].path)
                  : Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Pick up to 3 images.',
        textAlign: TextAlign.center,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final result = Text(_retrieveDataError!);
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
    var appState = ApplicationStateFirebase();
    await appState.addDocumentToFood(
        id, title, description, double.parse(cost), images);
  }

  Future<List<dynamic>> readImagesToBase64(List<XFile>? imageFiles) async {
    var imageToBytes = List<Uint8List>.filled(3, Uint8List(0), growable: false);
    var temp = List.filled(imageFiles!.length, null.toString(), growable: true);
    for (var i = 0; i < imageFiles.length; i++) {
      imageToBytes[i] = await imageFiles[i].readAsBytes();
      temp[i] = base64Encode(imageToBytes[i]);
    }
    return temp;
  }
}
