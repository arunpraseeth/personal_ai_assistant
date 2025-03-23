import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> addUserMessage(String text) async {
    _messages.insert(0, Message(text: text, isUser: true));
    notifyListeners();

    String response = await AIService().getAIResponse(text);
    _messages.insert(0, Message(text: response, isUser: false));
    notifyListeners();
  }
}
