import 'dart:convert';

import 'package:abai_quiz/pages/quizes.dart';
import 'package:flutter/services.dart';

class MyDocuments {
  static List<PageData>? _cachedQuizPages;
  static List<PageData>? _cachedAnalysisPages;

  static Future<List<PageData>> getQuizPages() async {
    if (_cachedQuizPages != null) {
      return _cachedQuizPages!;
    }
    _cachedQuizPages = await loadPages('assets/main/pages.json');
    return _cachedQuizPages!;
  }

  static Future<List<PageData>> getAnalysisPages() async {
    if (_cachedAnalysisPages != null) {
      return _cachedAnalysisPages!;
    }
    _cachedAnalysisPages = await loadPages('assets/analysis/pages.json');
    return _cachedAnalysisPages!;
  }

  static Future<List<PageData>> loadPages(String jsonPath) async {
  
    String jsonString = await rootBundle.loadString(jsonPath);
    List<dynamic> jsonList = json.decode(jsonString)['pages'];

    final List<Future<PageData>> futures = jsonList.map((page) async {
      final String title = page['title'];
      final String filePath = page['file'];

      final String markdown = await rootBundle.loadString(filePath);
      return PageData(title: title, markdown: markdown);
    }).toList();

    return await Future.wait(futures);
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