import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

class SystemService {

  static bool isInited = false;
  static bool isIniting = false;
  static DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  static IosDeviceInfo? iosDeviceInfo;
  static AndroidDeviceInfo? androidDeviceInfo;
  static bool isSupportingIsolateImage = false;

  static const String _iPadUiPrefix = 'iPad';
  static const String _iPhoneUiPrefix = 'iPhone';

  static const double _iPadA12ChipFirstVersion = 11.2;
  static const double _iPhoneA12ChipFirstVersion = 11.2;

  static const double _iPadIOSFirstVersion = 16.1;
  static const double _iPhoneIOSFirstVersion = 16.0;

  static Future init() async {
    if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    }
    isSupportingIsolateImage = _isSupportingIsolateImage();
  }

  // TODO Test different devices
  static bool _isSupportingIsolateImage() {
    if (Platform.isIOS && iosDeviceInfo != null) {
      String machine = iosDeviceInfo!.utsname.machine!;
      double osVersion = double.parse(iosDeviceInfo!.systemVersion!);
      if (machine.contains(_iPhoneUiPrefix)) {
        double uiVersion = double.parse(machine.replaceFirst(_iPhoneUiPrefix, '').replaceFirst(',', '.'));
        return uiVersion >= _iPhoneA12ChipFirstVersion && osVersion >= _iPhoneIOSFirstVersion;
      }
      if (machine.contains(_iPadUiPrefix)) {
        double uiVersion = double.parse(machine.replaceFirst(_iPadUiPrefix, '').replaceFirst(',', '.'));
        return uiVersion >= _iPadA12ChipFirstVersion && osVersion >= _iPadIOSFirstVersion;
      }
    }
    return false;
  }
}