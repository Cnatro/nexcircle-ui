import 'package:nexcircleuiapp/features/auth/data/models/user_model.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user_device.dart';

class UserDeviceModel extends UserDevice {
  UserDeviceModel({
    String? id,
    required String deviceToken,
    DateTime? lastLogin,
    required String flatform,
    User? user,
  }) : super(
         id: id,
         deviceToken: deviceToken,
         lastLogin: lastLogin,
         flatform: flatform,
         user: user,
       );

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) =>
      UserDeviceModel(
        id: json['id']?.toString(),
        deviceToken: json['deviceToken'],
        lastLogin: DateTime.tryParse(json['lastLogin'] ?? ''),
        flatform: json['flatform'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceToken': deviceToken,
    'lastLogin': lastLogin?.toIso8601String(),
    'flatform': flatform,
    'user': (user as UserModel?)?.toJson(),
  };
}
