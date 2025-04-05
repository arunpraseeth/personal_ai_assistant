class TranscribeModel {
  final String userText;
  final String aiReply;

  TranscribeModel(this.userText, this.aiReply);

  TranscribeModel.fromJson(Map<String, dynamic> json)
    : userText = json['user_text'],
      aiReply = json['ai_reply'];

  Map<String, dynamic> toJson() => {'userText': userText, 'aiReply': aiReply};

  // String get userMessage => userText;
  // String get aiMessage => aiReply;
}
