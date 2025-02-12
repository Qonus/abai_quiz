import 'package:abai_quiz/documents.dart';
import 'package:abai_quiz/pages/quizes.dart';
import 'package:abai_quiz/widgets/card.dart';
import 'package:abai_quiz/widgets/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MyDocuments.getAnalysisPages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Мазмұн жоқ.'));
        } else {
          List<PageData> pages = snapshot.data!;
          String homeMarkdown = pages[0].markdown;
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                if (index == 0) return MyMarkdownBody(data: homeMarkdown);
                PageData page = pages[index];
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: MyCard(
                    child: Text(
                      page.title,
                      style: TextStyle(fontSize: 17),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PageScaffold(
                            title: Text(page.title),
                            child: ListView(
                              children: [
                                MyMarkdownBody(data: page.markdown),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
