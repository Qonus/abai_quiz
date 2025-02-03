import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageWidget extends StatelessWidget {
  final String? markdownText;
  final bool isMyMessage;

  const MessageWidget({
    Key? key,
    required this.markdownText,
    this.isMyMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          isMyMessage ? SizedBox(width: 50) : Icon(Icons.person_2_outlined),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                    topLeft: isMyMessage ? Radius.circular(10) : Radius.circular(0),
                    topRight: isMyMessage ? Radius.circular(0) : Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: MarkdownBody(data: markdownText ?? ""),
            ),
          ),
          isMyMessage ? Icon(Icons.person) : SizedBox(width: 20),
        ],
      ),
    );
  }
}
