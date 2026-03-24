import '../repositories/user_repository.dart';
import '../entities/user.dart';

class RegisterUseCase {
  final UserRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> execute(String username, String email, String password) {
    return repository.register(username, email, password);
  }
}