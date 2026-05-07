class EmailMessage {
  const EmailMessage({
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    this.attachmentPath,
  });

  final String from;
  final String to;
  final String subject;
  final String body;
  final String? attachmentPath;
}
