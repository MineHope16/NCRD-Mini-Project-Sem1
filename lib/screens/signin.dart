import 'package:blog/components/round_button.dart';
import 'package:blog/screens/home_screen.dart';
import 'package:blog/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'option_screen.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool rememberMe = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String email = "", password = "";

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar( leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const OptionScreen()),), ), title: const Text('Blog App'), backgroundColor: Colors.pinkAccent,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.7, 1],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30), // Add space at the top
                      const CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('assets/login_icon.jpg'), // Make sure this path is correct
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Register',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildTextFormField(
                                controller: emailController,
                                hintText: 'Email',
                                labelText: 'Email',
                                icon: Icons.email,
                                isPassword: false,
                              ),
                              const SizedBox(height: 15),
                              buildTextFormField(
                                controller: passwordController,
                                hintText: 'Password',
                                labelText: 'Password',
                                icon: Icons.lock,
                                isPassword: true,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text('Remember Me', style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontWeight: FontWeight.bold,)),
                                ],
                              ),
                              const SizedBox(height: 10), // Adjust spacing between fields and button
                              RoundButton(
                                title: 'Register',
                                onPress: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => showSpinner = true);
                                    try {
                                      final user = await _auth.createUserWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passwordController.text.trim(),
                                      );
                                      toastMessage('User Successfully Created');
                                      await _saveRememberMe();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      );
                                    } catch (e) {
                                      toastMessage(e.toString());
                                    } finally {
                                      setState(() => showSpinner = false);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 5), // Adjust spacing before login prompt
                              buildLoginPrompt(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white70,
      ),
      validator: (value) => value!.isEmpty ? 'Enter $labelText' : null,
    );
  }

  Widget buildLoginPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? ", style: TextStyle(color: Colors.black87)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.pink,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
