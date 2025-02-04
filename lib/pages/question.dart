import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';

class QuestionData {
  final String question;
  final List<String> answers;
  final int correct;

  const QuestionData({
    required this.question,
    required this.answers,
    required this.correct,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      question: json['question'] as String,
      answers: List<String>.from(json['answers'] as List),
      correct: json['correct'] as int,
    );
  }
}

class QuestionPage extends StatefulWidget {
  final QuestionData questionData;
  final String title;
  final Function()? onRight;
  final Function()? onWrong;
  const QuestionPage({super.key, required this.title, required this.questionData, this.onRight, this.onWrong});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      endDrawer: MenuDrawer(),
      body: Column(
        children: [
          Text(widget.questionData.question),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.questionData.answers.length,
              itemBuilder: (context, index) {
                return Container(
                  child: ElevatedButton(
                    child: Text(widget.questionData.answers[index]),
                    onPressed: () {
                      if (index == widget.questionData.correct) {
                        widget.onRight?.call();
                      } else {
                        widget.onWrong?.call();
                      }
                    },
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );;
  }
}