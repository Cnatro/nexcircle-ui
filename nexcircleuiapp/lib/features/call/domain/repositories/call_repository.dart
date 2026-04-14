import 'package:nexcircleuiapp/features/call/domain/entities/call_session.dart';

abstract class CallRepository {
  Future<CallSession> initiateCall(String receiverId, String type);
}
