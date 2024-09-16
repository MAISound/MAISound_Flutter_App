import 'package:flutter/material.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/login_page.dart';
import 'package:maisound/project_page.dart';
import 'package:maisound/track_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, title: 'MAISound', home: HomePage());
  }
}

class MyAppState extends ChangeNotifier {}