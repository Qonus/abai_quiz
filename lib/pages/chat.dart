import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

//Hello write a huge essay about the name ANGSAR!
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "You are AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language and in character of ABAI KUNANBAIULU",
    },
  ];

  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": userMessage});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${dotenv.env['GROQ_API_KEY']}",
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

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decodedBody);
        String aiMessage = jsonResponse["choices"][0]["message"]["content"];

        setState(() {
          messages.add({"role": "assistant", "content": aiMessage});
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
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              if (message["role"] == "system") return Container();
              final isUser = message["role"] == "user";

              return Container(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MarkdownBody(
                  selectable: true,
                  data: message["content"] ?? "",
                ),
              );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextField(
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
