import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PageScaffold extends StatelessWidget {
  final Widget title;
  final Widget child; 
  const PageScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: title,
      ),
      endDrawer: MenuDrawer(),
      body: child,
    );
  }
}

class MyMarkdownBody extends StatelessWidget {
  final String data;
  const MyMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MarkdownBody(
        selectable: true,
        data: data,
        imageBuilder: (uri, title, alt) {
          final assetPath = uri.toString();
          return Center(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          );
        },
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          h2: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          h3: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          p: TextStyle(
            fontSize: 17,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
