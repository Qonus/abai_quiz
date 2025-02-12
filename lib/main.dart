import 'package:abai_quiz/pages/quizes.dart';
import 'package:abai_quiz/pages/chat.dart';
import 'package:abai_quiz/pages/home.dart';
import 'package:abai_quiz/providers.dart';
import 'package:abai_quiz/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load();
  await QuizModel.loadPrefs();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ChatModel()),
      ChangeNotifierProvider(create: (_) => QuizModel()),
    ],
    child: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class Notifier {

  static final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.dark);

  static ValueNotifier<ThemeMode> get(){
    return _notifier;
  }
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: Notifier.get(),
        builder: (_, mode, __) {
          return MaterialApp(
            title: 'Abai Quiz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: mode,
            home: App(),
          );
        });
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

const List<Widget> widgetOptions = <Widget>[
  HomePage(),
  ChatPage(),
  QuizMainPage(),
];
int selectedIndex = 0;

class _AppState extends State<App> {
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Abai Quiz'),
      ),
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.house_outlined),
            label: "Басты бет",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: "Чат",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outlined),
            label: "Ақпарат",
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        onTap: onItemTapped,
      ),
      endDrawer: MenuDrawer(),
    );
  }
}
