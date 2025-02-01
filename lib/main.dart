import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Abai Quiz'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class Page {
  final String title;
  final String markdown;

  Page({required this.title, required this.markdown});

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      title: json['title'],
      markdown: json['markdown'],
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  final Future<List<Page>> pages = Future<List<Page>>.delayed(
    const Duration(seconds: 2),
    () async {
      String jsonString = await rootBundle.loadString('assets/main/pages.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> pagesList = jsonData['pages'];
      return pagesList.map((json) => Page.fromJson(json)).toList();
    },
  );

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Page>>(
          future: pages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Қате: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Мазмұн жоқ.'));
            } else {
              List<Page> pages = snapshot.data!;
              return ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  Page page = pages[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(20, 5, 0, 5),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark),
            label: "Quiz",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      endDrawer: Drawer(),
    );
  }
}

class PageWidget extends StatelessWidget {
  final Page page;

  const PageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(page.title),
      ),
      body: Center(
        child: Markdown(selectable: true, data: page.markdown),
      ),
    );
  }
}
