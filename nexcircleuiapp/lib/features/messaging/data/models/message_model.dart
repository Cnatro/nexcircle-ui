import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/attachment.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message_receipt.dart';

class MessageModel {
  final String id;
  final String content;
  final String? messageType;
  final DateTime createdAt;
  final String? parentMessageId;

  final User sender;
  final List<Attachment>? attachments;
  final List<MessageReceipt>? messageReceipts;

  MessageModel({
    required this.id,
    required this.content,
    this.messageType,
    required this.createdAt,
    this.parentMessageId,
    required this.sender,
    required this.attachments,
    required this.messageReceipts,
  });
}
