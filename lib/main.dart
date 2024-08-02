import 'package:blog/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCi8khDIy8TCeR7MjRx_5eT_msLRc2cQoY",
        projectId: "blog-app-2b9dd",
        databaseURL: "https://blog-app-2b9dd-default-rtdb.asia-southeast1.firebasedatabase.app/",
        messagingSenderId: '359744860509',
        appId: '1:359744860509:android:da0a27fbbc13e0d10e78b4',
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
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const SplashScreen(),
    );
  }
}
