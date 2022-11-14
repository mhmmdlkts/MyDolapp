import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:version/version.dart';

class SystemService {

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static IosDeviceInfo? iosDeviceInfo;
  static AndroidDeviceInfo? androidDeviceInfo;
  static bool isSupportingIsolateImage = false;

  static const String _iPadUiPrefix = 'iPad';
  static const String _iPhoneUiPrefix = 'iPhone';

  static final Version _iPadA12ChipFirstVersion = Version.parse('11.2');
  static final Version _iPhoneA12ChipFirstVersion = Version.parse('11.2');

  static final Version _iPadIOSFirstVersion = Version.parse('16.1');
  static final Version _iPhoneIOSFirstVersion = Version.parse('16.0');

  static Future init() async {
    if (Platform.isIOS) {
      iosDeviceInfo = await _deviceInfo.iosInfo;
    }
    if (Platform.isAndroid) {
      androidDeviceInfo = await _deviceInfo.androidInfo;
    }
    isSupportingIsolateImage = _isSupportingIsolateImage();
  }

  // TODO Test different devices
  static bool _isSupportingIsolateImage() {
    if (Platform.isIOS && iosDeviceInfo != null) {
      String machine = iosDeviceInfo!.utsname.machine!;
      Version osVersion = Version.parse(iosDeviceInfo!.systemVersion!);
      if (machine.contains(_iPhoneUiPrefix)) {
        Version uiVersion = Version.parse(machine.replaceFirst(_iPhoneUiPrefix, '').replaceFirst(',', '.'));
        return uiVersion >= _iPhoneA12ChipFirstVersion && osVersion >= _iPhoneIOSFirstVersion;
      }
      if (machine.contains(_iPadUiPrefix)) {
        Version uiVersion = Version.parse(machine.replaceFirst(_iPadUiPrefix, '').replaceFirst(',', '.'));
        return uiVersion >= _iPadA12ChipFirstVersion && osVersion >= _iPadIOSFirstVersion;
      }
    }
    return false;
  }
}