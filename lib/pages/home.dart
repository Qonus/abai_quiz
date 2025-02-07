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
            child: Column(
              children: [
                MyMarkdownBody(data: homeMarkdown),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    if (index == 0) return Center();
                    PageData page = pages[index];
                    return Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: MyCard(
                        child: Text(page.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => PageScaffold(
                                title: Text(page.title),
                                child: MyMarkdownBody(data: page.markdown),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }
      },
    );
  }
}
