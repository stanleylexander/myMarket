class ChatMessage {
  final int id;
  final String text;
  final int userId;
  final String username;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.username,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.parse(json['id']),
      text: json['text'],
      userId: int.parse(json['user_id']),
      username: json['username'], 
      timestamp: DateTime.parse(json['tanggal']),
    );
  }
}
