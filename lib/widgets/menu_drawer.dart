import 'package:abai_quiz/main.dart';
import 'package:abai_quiz/pages/chat.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              OutlinedButton(
                style: ButtonStyle(padding:WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15, horizontal: 20))),
                onPressed: () {
                  Messages.clear();
                },
                child: Text("Абай атамен жаңа чат"),
              ),
              SegmentedButton<ThemeMode>(
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
                selected: <ThemeMode>{Notifier.get().value},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  setState(() {
                    Notifier.get().value = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
