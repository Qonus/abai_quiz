import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Markdown(data: "#QUIZEZ"),
    );
  }
}