import 'dart:convert';

import 'package:abai_quiz/groq_api_client.dart';
import 'package:abai_quiz/pages/quiz.dart';
import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:abai_quiz/widgets/quiz_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PageData {
  final String title;
  final String markdown;

  PageData({required this.title, required this.markdown});

  Future<List<QuestionData>?> generateQuiz() async {
    final request = [
      {
        "role": "system",
        "content":
            "never respond with anything except text that is decodable from string to json.",
      },
      {
        "role": "user",
        "content":
            "Please return quiz in json format about following title and text:\ntitle: ${title},\ntext: \n${markdown}\n\nIt should contain list called `questions`, each question has question itself called `question`, list of strings called `answers` and integer index of correct answer which is called `correct`. IMPORTANT! ALL TEXT SHOULD BE IN KAZAKH LANGUAGE.",
      },
    ];
    final json_response;
    try {
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
    } catch (e) {
      print("Error sending message: $e");
      return null;
    }
    List<QuestionData>? quiz = [];
    for (Map<String, dynamic> question in json_response["questions"]) {
      quiz.add(QuestionData.fromJson(question));
    }
    print(quiz);
    return quiz;
  }
}

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class QuizesCache {
  static List<PageData>? _cachedPages;

  static Future<List<PageData>> getPages() async {
    if (_cachedPages != null) {
      return _cachedPages!;
    }
    return await loadPages();
  }

  static Future<List<PageData>> loadPages() async {
    String jsonString = await rootBundle.loadString('assets/main/pages.json');
    List<dynamic> jsonList = json.decode(jsonString)['pages'];

    final List<Future<PageData>> futures = jsonList.map((page) async {
      final String title = page['title'];
      final String filePath = page['file'];

      final String markdown = await rootBundle.loadString(filePath);
      return PageData(title: title, markdown: markdown);
    }).toList();

    _cachedPages = await Future.wait(futures);

    return _cachedPages!;
    // final manifestJson = await rootBundle.loadString('AssetManifest.json');
    // final Map<String, dynamic> manifestMap = json.decode(manifestJson);

    // List<String> mdFiles = manifestMap.keys
    //     .where((String key) =>
    //         key.startsWith('assets/main/') && key.endsWith('.md'))
    //     .toList();

    // List<PageData> pages = [];
    // for (String file in mdFiles) {
    //   String content = await rootBundle.loadString(file);
    //   String title =
    //       file.split('/').last.replaceAll('_', ' ').replaceAll('.md', '');
    //   pages.add(PageData(title: title, markdown: content));
    // }

    // return pages;
  }
}

class _QuizMainPageState extends State<QuizMainPage> {
  void _onTap(PageData page) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PageWidget(page: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<PageData>>(
        future: QuizesCache.loadPages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Қате: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Мазмұн жоқ.'));
          } else {
            List<PageData> pages = snapshot.data!;
            return ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                PageData page = pages[index];
                return Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: QuizCard(
                    title: page.title,
                    onTap: () => _onTap(page),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PageWidget extends StatefulWidget {
  final PageData page;

  const PageWidget({super.key, required this.page});

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  int score = 0;
  int totalQuestion = 1;

  void startQuiz(BuildContext context) async {
    List<QuestionData>? quiz = await widget.page.generateQuiz();
    if (quiz == null) return;
    totalQuestion = quiz.length;
    final quizScreen = QuizScreen(quiz: quiz);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => quizScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.page.title),
      ),
      endDrawer: MenuDrawer(),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
            child: MarkdownBody(
              selectable: true,
              data: widget.page.markdown,
              imageBuilder: (uri, title, alt) {
                final assetPath = uri.toString().replaceFirst('resource:', '');
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
                  color: Theme.of(context).colorScheme.inversePrimary,
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
          ),
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
