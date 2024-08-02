import 'dart:async';

import 'package:blog/screens/home_screen.dart';
import 'package:blog/screens/option_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth=FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    final user = auth.currentUser;
    if (user != null) {
      Timer(const Duration(seconds: 3),
              () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())));
    } else {
      Timer(const Duration(seconds: 3),
              () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const OptionScreen())));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
              height: MediaQuery.of(context).size.height* .3,
              width: MediaQuery.of(context).size.height* .3,
              image: const AssetImage('assets/blogging_9611762.png'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical:5),
            child: Align(
                alignment: Alignment.center,
                child:Text("Let's Blog!",style: TextStyle(
                fontSize:30,
                fontWeight: FontWeight.w300
            ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
