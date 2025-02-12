import 'dart:convert';

import 'package:abai_quiz/documents.dart';
import 'package:abai_quiz/groq_api_client.dart';
import 'package:abai_quiz/pages/quiz.dart';
import 'package:abai_quiz/providers.dart';
import 'package:abai_quiz/widgets/card.dart';
import 'package:abai_quiz/widgets/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageData {
  final String title;
  final String markdown;

  PageData({required this.title, required this.markdown});
}

class Quiz {
  final PageData material;
  int? totalQuestions;
  int? score;

  Quiz({required this.material, this.totalQuestions, this.score});
}

Future<List<QuestionData>?> generateQuiz(String context) async {
  final request = [
    {
      "role": "system",
      "content":
          "Never respond with anything except text that is decodable from string to json. Don't talk to the user, do not say something like `Here is your answer`. Just include the json itself",
    },
    {
      "role": "user",
      "content":
          "Please return quiz in json format about following text:\n${context}\n\nIt should contain list called `questions`, each question has question itself called `question`, list of strings called `answers` and integer index of correct answer which is called `correct`. IMPORTANT! ALL TEXT SHOULD BE IN KAZAKH LANGUAGE. Additionally, please make the incorrect answers very believable, the difficulty should be pretty high. I shouldn't be able to pass the quiz if I don't know the answer. So don't make the correct answer stand out among other ones.",
    },
  ];
  final json_response;
  final response = await GroqAPI.get_response(request);
  if (response.statusCode == 200) {
    String cleanedString = GroqAPI.to_string(response)
        .replaceAll(RegExp(r'```json|```'), '')
        .trim();
    json_response = jsonDecode(cleanedString);
  } else {
    print("Error: ${response.statusCode}");
    return null;
  }
  List<QuestionData>? quiz = [];
  for (Map<String, dynamic> question in json_response["questions"]) {
    quiz.add(QuestionData.fromJson(question));
  }
  print(quiz);
  return quiz;
}

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  void _onTap(PageData page, int index) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PageWidget(page: page, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizModel = context.watch<QuizModel>();
    return Center(
      child: FutureBuilder<List<PageData>>(
        future: MyDocuments.getQuizPages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Қате: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Мазмұн жоқ.'));
          } else {
            List<PageData> pages = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  PageData page = pages[index];
                  return Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: QuizCard(
                      title: page.title,
                      onTap: () => _onTap(page, index),
                      progress: quizModel.getQuizResult(index),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class PageWidget extends StatefulWidget {
  final PageData page;
  final int index;

  const PageWidget({super.key, required this.page, required this.index});

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  int score = 0;
  int totalQuestion = 1;

  void startQuiz(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      List<QuestionData>? quiz = await generateQuiz(
          "${widget.page.title}\n\n\n${widget.page.markdown}");
      if (quiz == null) throw Error();
      totalQuestion = quiz.length;

      final quizScreen = QuizScreen(
        quiz: quiz,
        onFinish: (score, total) {
          Provider.of<QuizModel>(context, listen: false).saveQuizResult(widget.index, score / total);
        },
      );
      Navigator.of(context).pop();

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => quizScreen,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Қате!"),
          content: Text("Тест жасау кезінде қате шықты, қайтадан көріңіз."),
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
    return PageScaffold(
      title: Text(widget.page.title),
      child: ListView(
        children: [
          MyMarkdownBody(data: widget.page.markdown),
          SizedBox(height: 80),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              onPressed: () => startQuiz(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              child: Text(
                "Біліміңді тексер!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
