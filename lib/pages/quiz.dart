import 'dart:convert';

import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:abai_quiz/widgets/quiz_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuizData {
  final String question;
  final List<String> answers;
  final int correct;

  QuizData({
    required this.question,
    required this.answers,
    required this.correct,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      question: json['question'] as String,
      answers: List<String>.from(json['answers'] as List),
      correct: json['correct'] as int,
    );
  }
}

class PageData {
  final String title;
  final String markdown;

  PageData({required this.title, required this.markdown});

  // QuizData generateQuiz() {
  //   return QuizData.fromJson(json);
  // }

  // factory PageData.fromJson(Map<String, dynamic> json) {
  //   return PageData(
  //     title: json['title'],
  //     markdown: json['markdown'],
  //   );
  // }
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
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestJson);

    List<String> mdFiles = manifestMap.keys
        .where((String key) =>
            key.startsWith('assets/main/') && key.endsWith('.md'))
        .toList();

    List<PageData> pages = [];
    for (String file in mdFiles) {
      String content = await rootBundle.loadString(file);
      String title =
          file.split('/').last.replaceAll('_', ' ').replaceAll('.md', '');
      pages.add(PageData(title: title, markdown: content));
    }

    return pages;
    // String jsonString = await rootBundle.loadString('assets/main/pages.json');
    // List<dynamic> jsonList = json.decode(jsonString)['pages'];
    // _cachedPages = jsonList.map((json) => PageData.fromJson(json)).toList();
    // return _cachedPages!;
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

class PageWidget extends StatelessWidget {
  final PageData page;

  const PageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(page.title),
      ),
      endDrawer: MenuDrawer(),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
            child: MarkdownBody(
              selectable: true,
              data: page.markdown,
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
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PageWidget(page: page),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text("Біліміңді тексер!")),
        ],
      ),
    );
  }
}
