import 'package:camera/camera.dart';

class CameraService {
  static late List<CameraDescription> cameras;

  static Future initCameras({DateTime? now}) async {
    cameras = await availableCameras();

    if (now != null) {
      print('initCameras: took: ${DateTime.now().difference(now).inMilliseconds}');
    }
  }

  static bool hasNoCamera() => cameras.isEmpty;
}