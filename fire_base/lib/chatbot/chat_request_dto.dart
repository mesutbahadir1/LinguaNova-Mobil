class ChatRequestDto {
  final String userMessage;
  final String history;

  ChatRequestDto({
    required this.userMessage,
    required this.history,
  });

  Map<String, dynamic> toJson() => {
    'UserMessage': userMessage,
    'History': history,
  };
}