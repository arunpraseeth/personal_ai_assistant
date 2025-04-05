import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  String? baseUrl = dotenv.env['CLIENT_URL'];

  Future<String> getAIResponse(String input) async {
    try {
      final url = Uri.parse(
        '$baseUrl/v1/chat/completions',
      ); // Corrected API path
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "meta-llama-3-8b-instruct", // Model name in LM Studio
          "messages": [
            {"role": "user", "content": input},
          ],
          "max_tokens": 100,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String responseText = jsonResponse['choices'][0]['message']['content'] ?? 'No response';
        return responseText;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 'Error connecting to LM Studio server';
    }
  }
}
