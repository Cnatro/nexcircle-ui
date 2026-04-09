class Attachment {
  final String id;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  Attachment({
    required this.id,
    required this.fileSize,
    required this.fileType,
    required this.fileUrl,
  });
}
