import 'package:abai_quiz/pages/analysis.dart';
import 'package:abai_quiz/pages/quiz.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.dark);
  int selectedIndex = 0;
  static const List<Widget> widgetOptions = <Widget>[
    AnalysisPage(),
    QuizPage(),
    AnalysisPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: _notifier,
        builder: (_, mode, __) {
          return MaterialApp(
            title: 'Abai Quiz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: mode,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text('Abai Quiz'),
              ),
              body: widgetOptions.elementAt(selectedIndex),
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
                currentIndex: selectedIndex,
                selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
                onTap: onItemTapped,
              ),
              endDrawer: Drawer(
                child: Center(
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode)),
                    ],
                    selected: <ThemeMode>{mode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      setState(() {
                        _notifier.value = newSelection.first;
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}
