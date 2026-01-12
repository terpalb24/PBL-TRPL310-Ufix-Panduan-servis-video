// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/screen/homepage.dart';
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/searched.dart';


// Import all your screens
import 'screen/welcome_unlogged.dart';
import 'screen/welcome_loggedin.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/main_screen.dart';
import 'screen/history.dart';
import 'screen/profile.dart';
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
      home: WelcomeUnlogged(), // Fixed: frontScreen() -> FrontScreen()
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
        '/profile': (context) => ProfilePage(),
        '/homepage':(context) => Homepage(),
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