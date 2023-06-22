import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final mockPickedImagesXfile = [
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow1.jpg'),
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow2.jpg'),
  XFile('/data/user/0/com.freegapp.freegapp/cache/cow3.jpg'),
];

class ImagePickerMock {
  /// The platform interface that drives this plugin

  Future<List<XFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    return Future.value(mockPickedImagesXfile);
  }
}
