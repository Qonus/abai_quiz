import 'package:abai_quiz/groq_api_client.dart';
import 'package:abai_quiz/widgets/message.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Messages {
  static Map<String, String> systemMessage = {
    "role": "system",
    "content":
        "You are an AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language and stay true to the character of kazakh poet. Act like Abai. Additional information: you are 50 years old, you did not die yet, and you shouldn't mention anything your character wouln't know about. Again, NEVER mention or include any information your character does not know, act like this character would, act like you know nothing about that thing you shouldn't know. You are talking with complete stranger, outside your home",
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

// String extractFinalAnswer(String response) {
//   const marker = '</think>';
//   final markerIndex = response.indexOf(marker);
//   if (markerIndex != -1) {
//     return response.substring(markerIndex + marker.length).trim();
//   }
//   return response;
// }

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _enabled = true;

  // @override
  // void initState() {
  //   super.initState();
  //   Messages.groq.startChat();
  //   Messages.groq.setCustomInstructionsWith(
  //       "You are AI simulating Абай Құнанбайұлы, You should ALWAYS respond in kazakh language that is decodable by utf8 and stay true to the character. Additional information: you are 50 years old, you did not die yet, and you shouldn't mention anything your character wouln't know about. Again, NEVER mention or include any information your character does not know, act like this character would, act like you know nothing about that thing you shouldn't know.");
  // }

  // Future<void> sendMessage() async {
  //   String userMessage = _controller.text.trim();
  //   if (userMessage.isEmpty) return;

  //   setState(() {
  //     Messages.add({"role": "user", "content": userMessage});
  //   });

  //   _controller.clear();

  //   setState(() {
  //     _enabled = false;
  //     Messages.add({"role": "assistant", "content": ""});
  //   });
  //   try {
  //     final GroqResponse response =
  //         await Messages.groq.sendMessage(userMessage);
  //     String aiMessage = extractFinalAnswer(
  //         utf8.decode(latin1.encode(response.choices.first.message.content)));
  //     print(response.choices.first.message.content);

  //     setState(() {
  //       _enabled = true;
  //       Messages.messages.last = {"role": "assistant", "content": aiMessage};
  //     });
  //   } on GroqException catch (error) {
  //     print("Error: ${error.message}");
  //     setState(() {
  //       _enabled = true;
  //       Messages.messages.last = {
  //         "role": "assistant",
  //         "content": "Error: ${error.message}"
  //       };
  //     });
  //   }
  // }

  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      Messages.add({"role": "user", "content": userMessage});
      Messages.add({"role": "assistant", "content": ""});
      _enabled = false;
    });
    _controller.clear();

    try {
      final response = await GroqAPI.get_response(Messages.get());
      if (response.statusCode == 200) {
        String aiMessage = GroqAPI.to_string(response);

        setState(() {
          _enabled = true;
          Messages.messages.last = {"role": "assistant", "content": aiMessage};
        });
      } else {
        print("Error: ${response.statusCode}");
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

              return MessageWidget(
                isMyMessage: message["role"] == "user",
                markdownText: message["content"],
              );
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
              hintText: "Абайға сұрақ қойыңыз ",
            ),
          ),
        ),
      ],
    );
  }
}
