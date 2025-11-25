// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/screen/homepage.dart';
import 'package:ufix_mobile/screen/search.dart';

// Import all your screen
import 'screen/welcome_unlogged.dart';
import 'screen/welcome_loggedin.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/mainScreen.dart';
import 'screen/history.dart';
import 'screen/settings.dart';
import 'screen/searched.dart';
import 'screen/fakeplayer.dart';
import 'screen/comments.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electronics Learning App',
      home: Homepage(), // Start with welcome screen
      routes: {
        // Authentication Flow
        '/unlogged': (context) => WelcomeUnlogged(),
        '/login': (context) => ScreenLogin(),
        '/signup': (context) => SignupScreen(),
        '/loggedin': (context) => WelcomeLoggedin(),
        
        // Main App Flow
        '/front': (context) => frontScreen(),
        '/search': (context) => Search(),
        '/history': (context) => History(),
        '/settings': (context) => Settings(),
        '/homepage':(context) => Homepage(),
        '/comments': (context) => CommentsScreen(),
        '/player': (context) => Player(
          url_video: '',
          judul_video: '',
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}