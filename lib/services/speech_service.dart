import 'dart:convert';
import 'package:aiassistant/models/transcribe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SpeechServices {
  String? baseUrl = dotenv.env['SERVER_URL'];
  Future<Map<String, dynamic>> sendAudioToWhisper(String audioPath) async {
    try {
      final uri = Uri.parse('$baseUrl/voice');

      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
          contentType: MediaType('audio', 'wav'),
        ),
      );
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = jsonDecode(responseBody);
        debugPrint("AI Reply: ${decoded["ai_reply"]}");
        return decoded;
      } else {
        // return "Error: ${response.statusCode}";
        return {"Error": "${response.statusCode}"};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // return "Server error: $e";
      return {"Server error": "$e"};
    }
  }
}
