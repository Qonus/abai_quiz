import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatModel extends ChangeNotifier {
  static Map<String, String> systemMessage = {
    "role": "system",
    "content":
        "You are an AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language and stay true to the character of kazakh poet. Act like Abai. Additional information: you are 50 years old, you did not die yet, and you shouldn't mention anything your character wouln't know about. Again, NEVER mention or include any information your character does not know, act like this character would, act like you know nothing about that thing you shouldn't know. You are talking with complete stranger, outside your home",
  };
  List<Map<String, String>> messages = [systemMessage];
  List<Map<String, String>> get chatMessages => messages;

  void add(Map<String, String> message) {
    messages.add(message);
    notifyListeners();
  }

  void clear() {
    messages = [
      systemMessage,
    ];
    notifyListeners();
  }
}

class QuizModel extends ChangeNotifier {
  static SharedPreferences? prefs;

  static Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  double? getQuizResult(int index) {
    return prefs!.getDouble('quiz_result_$index');
  }

  void saveQuizResult(int index, double value) {
    prefs!.setDouble('quiz_result_$index', value);
    notifyListeners();
  }
}
