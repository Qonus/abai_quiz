import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';

class QuestionData {
  final String questionText;
  List<String> answers;
  int correct;

  QuestionData({
    required this.questionText,
    required this.answers,
    required this.correct,
  });

  void randomizeAnswers() {
    final correctAnswer = answers[correct];
    answers.shuffle();
    correct = answers.indexOf(correctAnswer);
  }

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      questionText: json['question'] as String,
      answers: List<String>.from(json['answers'] as List),
      correct: json['correct'] as int,
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<QuestionData> quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionData> new_quiz = List.empty();
  int currentQuestionIndex = 0;
  late List<int?> userAnswers;
  int score = 0;

  List<QuestionData> randomizeQuiz(List<QuestionData> quiz) {
    final randomizedQuiz = List<QuestionData>.from(quiz);
    randomizedQuiz.shuffle();
    for (var question in randomizedQuiz) {
      question.randomizeAnswers();
    }
    return randomizedQuiz;
  }

  @override
  void initState() {
    super.initState();
    userAnswers = List<int?>.filled(widget.quiz.length, null, growable: false);
    new_quiz = randomizeQuiz(widget.quiz);
  }

  void _updateSelectedOption(int? value) {
    setState(() {
      userAnswers[currentQuestionIndex] = value;
    });
  }

  void _submitAnswer() {
    if (userAnswers[currentQuestionIndex] == null) return;

    if (currentQuestionIndex < new_quiz.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _calculateScore();
      _showResultDialog();
    }
  }

  void _calculateScore() {
    int newScore = 0;
    for (int i = 0; i < new_quiz.length; i++) {
      if (userAnswers[i] == new_quiz[i].correct) {
        newScore++;
      }
    }
    setState(() {
      score = newScore;
    });
  }

  void _goToPrevious() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Тест аяқталды!'),
        content: Text('Сіз ${new_quiz.length} сұрақтан $score сұраққа дұрыс жауап бердіңіз.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pop(context);
            },
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = new_quiz[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title:
            Text("Question ${currentQuestionIndex + 1} of ${new_quiz.length}"),
      ),
      endDrawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              currentQuestion.questionText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.answers.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    title: Text(currentQuestion.answers[index]),
                    value: index,
                    groupValue: userAnswers[currentQuestionIndex],
                    onChanged: (int? value) {
                      _updateSelectedOption(value);
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: currentQuestionIndex <= 0 ? null : _goToPrevious,
                  child: const Text('Қайту'),
                ),
                OutlinedButton(
                  onPressed: userAnswers[currentQuestionIndex] == null
                      ? null
                      : _submitAnswer,
                  child: const Text('Келесі'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
