import 'package:camera/camera.dart';

class CameraService {
  static late List<CameraDescription> cameras;

  static Future initCameras() async {
    cameras = await availableCameras();
  }

  static bool hasNoCamera() => cameras.isEmpty;
}