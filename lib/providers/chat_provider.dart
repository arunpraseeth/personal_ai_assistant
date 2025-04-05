import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> addUserMessage(String text) async {
    _messages.insert(0, MessageModel(text: text, isUser: true));
    notifyListeners();

    String response = await AIService().getAIResponse(text);
    _messages.insert(0, MessageModel(text: response, isUser: false));
    notifyListeners();

    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
