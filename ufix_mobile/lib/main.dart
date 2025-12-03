// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/search.dart';

// Import all your screens
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
      home: FrontScreen(), // Fixed: frontScreen() -> FrontScreen()
      routes: {
        // Authentication Flow
        '/unlogged': (context) => WelcomeUnlogged(),
        '/login': (context) => ScreenLogin(),
        '/signup': (context) => SignupScreen(),
        '/loggedin': (context) => WelcomeLoggedin(),
        
        // Main App Flow
        '/front': (context) => FrontScreen(), // Fixed: frontScreen -> FrontScreen
        '/searched_videos': (context) => SearchedVideos(),
        '/history': (context) => History(),
        '/settings': (context) => Settings(),
        '/comments': (context) => CommentsScreen(),
      },
      // Use onGenerateRoute for type-safe Video object passing
      onGenerateRoute: (settings) {
        // Handle Player route with Video object
        if (settings.name == '/player') {
          final Video video = settings.arguments as Video;
          return MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: video), // Fixed: Player -> VideoPlayerScreen
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}