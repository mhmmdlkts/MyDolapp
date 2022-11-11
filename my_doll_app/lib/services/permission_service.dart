import 'package:permission_handler/permission_handler.dart';

// if doesnt work for android check https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler/README.md
class PermissionService {
  static Future getPermission(Permission type) async {
    PermissionStatus status = await type.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return await type.request().isGranted;
  }
}