import 'package:abai_quiz/groq_api_client.dart';
import 'package:abai_quiz/providers.dart';
import 'package:abai_quiz/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
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
  final ScrollController _scrollController = ScrollController();
  bool _enabled = true;

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(ChatModel chatModel) async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      chatModel.add({"role": "user", "content": userMessage});
      chatModel.add({"role": "assistant", "content": ""});
      _enabled = false;
    });
    _controller.clear();
    scrollDown();

    try {
      final response = await GroqAPI.get_response(chatModel.chatMessages);
      if (response.statusCode == 200) {
        String aiMessage = GroqAPI.to_string(response);

        setState(() {
          _enabled = true;
          chatModel.chatMessages.last = {
            "role": "assistant",
            "content": aiMessage
          };
        });
        scrollDown();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending message: $e");
      setState(() {
        _enabled = true;
        chatModel.chatMessages.last = {"role": "assistant", "content": "Қате!"};
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Қате!"),
          content: Text("Сұрақ жіберу кезінде қате шықты, қайтадан көріңіз."),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(e.toString()),
                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Ок"),
                        )
                      ],
                    ),
                  );
                },
                child: Text("Қатені көру")),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Ок"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = context.watch<ChatModel>();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: chatModel.chatMessages.length,
            itemBuilder: (context, index) {
              final message = chatModel.chatMessages[index];
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
            onSubmitted: (_) => sendMessage(chatModel),
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.menu_book),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              suffixIcon: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.arrow_upward),
                onPressed: () => sendMessage(chatModel),
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
