import 'package:flutter_tts/flutter_tts.dart';

class FlutterttsSpeak {
  Future speak({required String text, required FlutterTts flutterTts}) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({
      "name": "com.apple.ttsbundle.Samantha-compact",
      "locale": "en-US",
    });
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> stopSpeaking({required FlutterTts flutterTts}) async {
    await flutterTts.stop();
  }
}
