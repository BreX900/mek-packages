import 'package:permission_handler/permission_handler.dart';

extension PermissionName on Permission {
  String get name => toString().split('.').last;
}
