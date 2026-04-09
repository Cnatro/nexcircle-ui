import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class MessageSocketDataSource {
  late StompClient _stompClient;

  final String socketUrl;

  MessageSocketDataSource({String? socketUrl})
    : socketUrl = socketUrl ?? dotenv.env['SOCKET_URL'] ?? '';

  final _messageController = StreamController<Message>.broadcast();

  Stream<Message> onMessage() => _messageController.stream;

  void connect({required String token, required String conversationId}) {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: socketUrl,
        onConnect: (StompFrame frame) {
          print("WebSocket Connected ${conversationId ?? "no conversationId"}");

          _stompClient.subscribe(
            destination: '/user/private/messages/${conversationId}',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                print("Received message: $data");
                final message = Message(
                  id: data['id'],
                  senderId: data['senderId'],
                  content: data['content'],
                  conversationId: data['conversationId'],
                  receiverId: data['receiverId'],
                  messageType: data['messageType'],
                  parentMessageId: data['parentMessageId'],
                );

                _messageController.add(message);
              }
            },
          );
        },
        beforeConnect: () async {
          print('⏳ connecting...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print("WS Error: $error"),
        onDisconnect: (frame) => print("🔌 Disconnected"),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient.activate();
  }

  void sendMessage(Message message) {
    final body = jsonEncode({
      "senderId": message.senderId,
      "conversationId": message.conversationId,
      "content": message.content,
      "receiverId": message.receiverId,
      "messageType": message.messageType,
      "parentMessageId": message.parentMessageId ?? "",
    });

    _stompClient.send(destination: '/messages/send/private', body: body);
  }

  void disconnect() {
    _stompClient.deactivate();
    _messageController.close();
  }
}
