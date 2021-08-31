import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:flutter/src/services/asset_bundle.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImagePickerMock {
  /// The platform interface that drives this plugin
  @visibleForTesting
  static ImagePickerPlatform platform = MethodChannelImagePicker();
  Future<List<XFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    return platform.getMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  Future<LostDataResponse> retrieveLostData() {
    return platform.getLostData();
  }
}

final MethodChannel _channel = MethodChannel('plugins.flutter.io/image_picker');

Future<List<String>> loadStringFromAssets() async {
  if (Platform.environment.containsKey('FLUTTER_TEST') != true) {
    final temp = await getTemporaryDirectory();
    // '/data/user/0/com.freegapp.freegapp/cache/cow1.jpg'
    // '/data/user/0/com.freegapp.freegapp/cache/image_picker5340511547666958134.jpg'
    var imagePath1 = File('${temp.path}/cow1.jpg');
    var imagePath2 = File('${temp.path}/cow2.jpg');
    var imagePath3 = File('${temp.path}/cow3.jpg');
    if (await imagePath1.exists() == false) {
      // Image doesn't exist in cache
      await imagePath1.create(recursive: true);
      await imagePath2.create(recursive: true);
      await imagePath3.create(recursive: true);
    }
    var image1 = await rootBundle.load('assets/imagesTesting/cow1.jpg');
    var image2 = await rootBundle.load('assets/imagesTesting/cow2.jpg');
    var image3 = await rootBundle.load('assets/imagesTesting/cow3.jpg');
    image1.buffer;
    await File(imagePath1.path).writeAsBytes(
        image1.buffer.asUint8List(image1.offsetInBytes, image1.lengthInBytes));
    await File(imagePath2.path).writeAsBytes(
        image2.buffer.asUint8List(image2.offsetInBytes, image2.lengthInBytes));
    await File(imagePath3.path).writeAsBytes(
        image3.buffer.asUint8List(image3.offsetInBytes, image3.lengthInBytes));
    // Download the image and write to above file
    final imagePathList = [
      imagePath1.path,
      imagePath2.path,
      imagePath3.path,
    ];
    return imagePathList;
  } else {
    final imagePathList = [
      'assets/imagesTesting/cow1.jpg',
      'assets/imagesTesting/cow2.jpg',
      'assets/imagesTesting/cow3.jpg',
    ];
    return imagePathList;
  }
}

final mockPickedImagesXfile = [
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow1.jpg'),
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow2.jpg'),
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow3.jpg'),
];

/// An implementation of [ImagePickerPlatform] that uses method channels.
class MethodChannelImagePicker extends ImagePickerPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    var path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  // @override
  // Future<List<PickedFile>?> pickMultiImage({
  //   double? maxWidth,
  //   double? maxHeight,
  //   int? imageQuality,
  // }) async {
  //   final paths = await _getMultiImagePath(
  //     maxWidth: maxWidth,
  //     maxHeight: maxHeight,
  //     imageQuality: imageQuality,
  //   );
  //   if (paths == null) return null;

  //   return paths.map((path) => PickedFile(path)).toList();
  // }

  Future<List<dynamic>?> _getMultiImagePath(
    List<String> pathList, {
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }

    _channel.setMockMethodCallHandler(
        (methodCall) async => Future.delayed(const Duration(), () => pathList));

    return _channel.invokeMethod<List<dynamic>?>(
      'pickMultiImage',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
      },
    );
  }

  Future<String?> _getImagePath({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }

    return _channel.invokeMethod<String>(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
        'cameraDevice': preferredCameraDevice.index
      },
    );
  }

  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  Future<String?> _getVideoPath({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    return _channel.invokeMethod<String>(
      'pickVideo',
      <String, dynamic>{
        'source': source.index,
        'maxDuration': maxDuration?.inSeconds,
        'cameraDevice': preferredCameraDevice.index
      },
    );
  }

  @override
  Future<LostData> retrieveLostData() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostData.empty();
    }

    assert(result.containsKey('path') != result.containsKey('errorCode'));

    final String? type = result['type'];
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType? retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException? exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode'], message: result['errorMessage']);
    }

    final String? path = result['path'];

    return LostData(
      file: path != null ? PickedFile(path) : null,
      exception: exception,
      type: retrieveType,
    );
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    var path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<List<XFile>?> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    var mockPickedImages = await loadStringFromAssets();
    final paths = await _getMultiImagePath(
      mockPickedImages,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (paths == null) return null;

    return paths.map((path) => XFile(path)).toList();
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<LostDataResponse> getLostData() async {
    List<XFile>? pickedFileList;
    _channel.setMockMethodCallHandler((methodCall) async =>
        Future.delayed(const Duration(), () => mockPickedImagesXfile));

    var result = await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostDataResponse.empty();
    }

    assert(result.containsKey('path') != result.containsKey('errorCode'));

    final String? type = result['type'];
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType? retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException? exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode'], message: result['errorMessage']);
    }

    final String? path = result['path'];

    final pathList = result['pathList'];
    if (pathList != null) {
      pickedFileList = [];
      // In this case, multiRetrieve is invoked.
      for (String path in pathList) {
        pickedFileList.add(XFile(path));
      }
    }

    return LostDataResponse(
      file: path != null ? XFile(path) : null,
      exception: exception,
      type: retrieveType,
      files: pickedFileList,
    );
  }
}
