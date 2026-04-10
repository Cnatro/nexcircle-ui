import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';

class UserDevice {
  final String? id;
  final String deviceToken;
  final DateTime? lastLogin;
  final String flatform; // Android, iOS, Web
  final User? user;

  UserDevice({
    this.id,
    required this.deviceToken,
    this.lastLogin,
    required this.flatform,
    this.user,
  });
}
