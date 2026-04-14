import '../../domain/entities/call_session.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_datasource.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remote;

  CallRepositoryImpl({required this.remote});

  @override
  Future<CallSession> initiateCall(String receiverId, String type) async {
    final result = await remote.initiateCall(
      receiverId: receiverId,
      type: type,
    );

    return result;
  }
}
