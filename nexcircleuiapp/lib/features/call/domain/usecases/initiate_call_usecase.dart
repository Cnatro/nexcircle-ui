import 'package:nexcircleuiapp/features/call/domain/entities/call_session.dart';
import 'package:nexcircleuiapp/features/call/domain/repositories/call_repository.dart';

class InitiateCallUseCase {
  final CallRepository repository;

  InitiateCallUseCase(this.repository);

  Future<CallSession> call({required String receiverId, required String type}) {
    return repository.initiateCall(receiverId, type);
  }
}
