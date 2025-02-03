import 'dart:convert';

import 'package:abai_quiz/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Messages {
  static final groq = Groq(
      apiKey: dotenv.env['GROQ_API_KEY'] ?? "",
      model: "llama-3.3-70b-versatile");
  static Map<String, String> systemMessage = {
    "role": "system",
    "content":
        "You are AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language and stay true to the character. Additional information: you are 50 years old, you did not die yet, and you shouldn't mention anything your character wouln't know about. Again, NEVER mention or include any information your character does not know, act like this character would, act like you know nothing about that thing you shouldn't know. You are talking with complete stranger, outside your home",
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
    groq.clearChat();
  }

  static List<Map<String, String>> get() {
    return messages;
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    Messages.groq.startChat();
    Messages.groq.setCustomInstructionsWith(
        "You are AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language that is decodable by utf8 and stay true to the character. Additional information: you are 50 years old, you did not die yet, and you shouldn't mention anything your character wouln't know about. Again, NEVER mention or include any information your character does not know, act like this character would, act like you know nothing about that thing you shouldn't know.");
  }

  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      Messages.add({"role": "user", "content": userMessage});
    });

    _controller.clear();

    setState(() {
      _enabled = false;
      Messages.add({"role": "assistant", "content": ""});
    });
    try {
      final GroqResponse response =
          await Messages.groq.sendMessage(userMessage);
      String aiMessage =
          utf8.decode(latin1.encode(response.choices.first.message.content));
          print(response.choices.first.message.content);

      setState(() {
        _enabled = true;
        Messages.messages.last = {"role": "assistant", "content": aiMessage};
      });
    } on GroqException catch (error) {
      print("Error: ${error.message}");
      setState(() {
        _enabled = true;
        Messages.messages.last = {"role": "assistant", "content": "Error: ${error.message}"};
      });
    }
  }

  // Future<void> sendMessage() async {
  //   String userMessage = _controller.text.trim();
  //   if (userMessage.isEmpty) return;

  //   setState(() {
  //     Messages.add({"role": "user", "content": userMessage});
  //   });

  //   _controller.clear();

  //   try {
  //     final response = await http.post(
  //       Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer ${dotenv.env['GROQ_API_KEY']}",
  //       },
  //       body: jsonEncode({
  //         "messages": Messages.get(),
  //         // DeepSeek
  //         // "model": "deepseek-r1-distill-llama-70b",
  //         // "temperature": 0.6,
  //         // "max_completion_tokens": 4096,
  //         // "top_p": 0.95,
  //         // "stream": false,
  //         // "reasoning_format": "hidden",

  //         // Llama (doesn't work for now)
  //         "model": "llama-3.3-70b-versatile",
  //         "temperature": 1,
  //         "max_completion_tokens": 1024,
  //         "top_p": 1,
  //         "stream": true,
  //         "stop": null
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final decodedBody = utf8.decode(response.bodyBytes);
  //       final jsonResponse = jsonDecode(decodedBody);
  //       print(jsonResponse);
  //       String aiMessage = jsonResponse["choices"][0]["message"]["content"];

  //       setState(() {
  //         Messages.add({"role": "assistant", "content": aiMessage});
  //       });
  //     } else {
  //       print("Error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error sending message: $e");
  //   }
  // }

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

              return MessageWidget(
                  isMyMessage: message["role"] == "user",
                  markdownText: message["content"]);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextField(
            enabled: _enabled,
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
