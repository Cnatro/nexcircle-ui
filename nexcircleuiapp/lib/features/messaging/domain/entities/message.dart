class Message {
  final String? id;
  final String senderId;
  final String? receiverId;
  final String? conversationId;
  final String content;
  final String? messageType;
  final String? parentMessageId;

  Message({
    this.id,
    required this.senderId,
    this.conversationId,
    required this.content,
    this.receiverId,
    this.messageType,
    this.parentMessageId,
  });
}
