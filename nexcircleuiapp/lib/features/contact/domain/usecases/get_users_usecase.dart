import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class GetUsersUseCase {
  final ContactRepository repository;

  GetUsersUseCase(this.repository);

  Future<List<User>> call({required int page, required int size}) {
    return repository.getUsers(page: page, size: size);
  }
}