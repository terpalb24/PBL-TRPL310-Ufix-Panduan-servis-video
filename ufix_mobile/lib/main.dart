// lib/main.dart
import 'package:flutter/material.dart';

// Import all your screen
import 'screen/welcome_unlogged.dart';
import 'screen/welcome_loggedin.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/homepage.dart';
import 'screen/bookmark.dart';
import 'screen/search.dart';
import 'screen/history.dart';
import 'screen/seting.dart';
import 'screen/searched.dart';
import 'screen/fakeplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electronics Learning App',
      home: SignupScreen(), // Start with welcome screen
      routes: {
        // Authentication Flow
        '/unlogged': (context) => WelcomeUnlogged(),
        '/login': (context) => ScreenLogin(),
        '/signup': (context) => SignupScreen(),
        '/loggedin': (context) => WelcomeLoggedin(),
        
        // Main App Flow
        '/home': (context) => Homepage(),
        '/search': (context) => Search(),
        '/searched_videos': (context) => SearchedVideos(),
        '/bookmark': (context) => Bookmark(),
        '/history': (context) => History(),
        '/settings': (context) => Settings(),
        '/player': (context) => FakePlayer(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}