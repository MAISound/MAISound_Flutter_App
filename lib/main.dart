import 'package:flutter/material.dart';
import 'package:maisound/cadastro_page.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/login_page.dart';
import 'package:maisound/project_page.dart';
//import 'package:maisound/project_page.dart';
import 'package:maisound/track_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => AuthProvider(),
    child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, title: 'MAISound', home: HomePage());
  }
}

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

class MyAppState extends ChangeNotifier {}