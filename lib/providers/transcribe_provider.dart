import 'package:aiassistant/services/flutter_tts.dart';
import 'package:aiassistant/services/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/message.dart';

class TranscribeProvider extends ChangeNotifier {
  FlutterTts flutterTts = FlutterTts();
  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => _messages;

  Future<void> sendVoice({required String audiopath}) async {
    // _messages.insert(0, MessageModel(text: text, isUser: true));
    // notifyListeners();

    String response = await SpeechServices().sendAudioToWhisper(audiopath).then(
      (String value) {
        debugPrint("Just now completed");
        return value;
      },
    );
    FlutterttsSpeak().speak(text: response, flutterTts: flutterTts);
    // _messages.insert(
    //   0,
    //   MessageModel(text: response["user_text"]!, isUser: true),
    // );
    // _messages.insert(
    //   0,
    //   MessageModel(text: response["ai_reply"]!, isUser: false),
    // );
    notifyListeners();
  }
}
