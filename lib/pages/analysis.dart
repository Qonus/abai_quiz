import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PageData {
  final String title;
  final String markdown;

  PageData({required this.title, required this.markdown});

  // factory PageData.fromJson(Map<String, dynamic> json) {
  //   return PageData(
  //     title: json['title'],
  //     markdown: json['markdown'],
  //   );
  // }
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class PagesCache {
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

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<PageData>>(
        future: PagesCache.loadPages(),
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
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    title: Text(page.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PageWidget(page: page),
                        ),
                      );
                    },
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
      body: Center(
        child: Markdown(
          selectable: true,
          data: page.markdown,
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.inversePrimary),
            code: TextStyle(fontSize: 14, color: Colors.green), // new end
          ),
        ),
      ),
    );
  }
}
