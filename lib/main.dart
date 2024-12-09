import 'package:blog/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBzpjOoXleE74wD9gpMkcFA5DWBM0OAg_0",
        projectId: "ncrd-blog-app",
        databaseURL: "https://ncrd-blog-app-default-rtdb.firebaseio.com",
        messagingSenderId: '887656484222',
        appId: "1:887656484222:android:26685e9067874517daf72f",
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const SplashScreen(),
    );
  }
}
