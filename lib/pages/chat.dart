import 'dart:convert';
import 'package:abai_quiz/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Messages {
  static Map<String, String> systemMessage = {
    "role": "system",
    "content":
        "You are AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language and stay true to the character",
  };
  static List<Map<String, String>> messages = [
    systemMessage,
  ];
  static void add(Map<String, String> message) {
    messages.add(message);
  }

  static void clear() {
    messages = [
      systemMessage,
    ];
  }

  static List<Map<String, String>> get() {
    return messages;
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void updateMessages() {}

  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      Messages.add({"role": "user", "content": userMessage});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${dotenv.env['GROQ_API_KEY']}",
        },
        body: jsonEncode({
          "messages": Messages.get(),
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

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decodedBody);
        String aiMessage = jsonResponse["choices"][0]["message"]["content"];

        setState(() {
          Messages.add({"role": "assistant", "content": aiMessage});
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: Messages.get().length,
            itemBuilder: (context, index) {
              final message = Messages.get()[index];
              if (message["role"] == "system") return Container();
              final isUser = message["role"] == "user";

              return MessageWidget(isMyMessage: isUser, markdownText: message["content"]);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextField(
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            onSubmitted: (_) => sendMessage(),
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.menu_book),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              suffixIcon: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.arrow_upward),
                onPressed: sendMessage,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(35)),
              ),
              hintText: "Абайға сұрақ қойыңыз",
            ),
          ),
        ),
      ],
    );
  }
}
