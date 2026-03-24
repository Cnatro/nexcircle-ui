import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> login(String username, String password);
  Future<User?> register(String username, String email, String password);
}