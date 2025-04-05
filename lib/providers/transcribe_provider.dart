import 'package:aiassistant/models/transcribe.dart';
import 'package:aiassistant/providers/chat_provider.dart';
import 'package:aiassistant/services/flutter_tts.dart';
import 'package:aiassistant/services/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/message.dart';

class TranscribeProvider extends ChangeNotifier {
  FlutterTts flutterTts = FlutterTts();
  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => _messages;

  Future<void> sendVoice({
    required String audiopath,
    required ChatProvider chatProvider,
  }) async {
    // _messages.insert(0, MessageModel(text: text, isUser: true));
    // notifyListeners();

    Map<String, dynamic> result = await SpeechServices().sendAudioToWhisper(
      audiopath,
    );
    final userText = result['user_text'] ?? '';
    final aiReply = result['ai_reply'] ?? '';
    if (userText.trim().isNotEmpty) {
      chatProvider.messages.insert(
        0,
        MessageModel(text: userText, isUser: true),
      );
    }
    if (aiReply.trim().isNotEmpty) {
      chatProvider.messages.insert(
        0,
        MessageModel(text: aiReply, isUser: false),
      );
    }
    chatProvider.notifyListeners();

    FlutterttsSpeak().speak(text: aiReply, flutterTts: flutterTts);
    notifyListeners();
  }
}
