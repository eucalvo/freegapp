import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freegapp/src/ApplicationStateFirebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
                height: 80,
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
          var image2;
          var image3;

          var id = uuid.v4();
          var appState = ApplicationStateFirebase();
          await appState.addMessageToGuestBook(
              id,
              titleController.text,
              descriptionController.text,
              double.parse(costController.text),
              'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3',
              image2,
              image3);
          var food = await foods(id);
          print(food);
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
        'You have not yet picked an image.',
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

// A method that retrieves all the dogs from the dogs table.
  Future<List<Map<String, dynamic>>> foods(id) async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'freegapp.db'),
    );
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM food WHERE id=?', [id]);
    return maps;
  }

  Map<String, dynamic> toMap(id, title, description, cost) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
    };
  }
}
