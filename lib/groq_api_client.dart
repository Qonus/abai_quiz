import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class GroqAPI {
  static final String api_url =
      "https://api.groq.com/openai/v1/chat/completions";

  static Future<Response> get_response(List<Map<String, String>> messages) async {
    final response = await post(
      Uri.parse(api_url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${dotenv.env['GROQ_API_KEY']}",
      },
      body: jsonEncode({
        "messages": messages,
        // DeepSeek
        "model": "deepseek-r1-distill-llama-70b",
        "temperature": 0.6,
        "max_completion_tokens": 4096,
        "top_p": 0.95,
        "stream": false,
        "reasoning_format": "hidden",

        // Llama (doesn't work for now)
        // "model": "llama-3.3-70b-versatile",
        // "temperature": 1,
        // "max_completion_tokens": 1024,
        // "top_p": 1,
        // "stream": true,
        // "stop": null
      }),
    );
    return response;
  }

  static Map<String, dynamic> to_json(Response response) {
    final decodedBody = utf8.decode(response.bodyBytes);
    final jsonResponse = jsonDecode(decodedBody);
    print(jsonResponse);
    return jsonResponse;
  }

  static String to_string(Response response) {
    return to_json(response)["choices"][0]["message"]["content"];
  }
}
