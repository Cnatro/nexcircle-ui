import '../repositories/user_repository.dart';
import '../entities/user.dart';

class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  Future<User?> execute(String username, String password) {
    return repository.login(username, password);
  }
}