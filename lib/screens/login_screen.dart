import 'package:blog/screens/forgot_password_screen.dart';
import 'package:blog/screens/home_screen.dart';
import 'package:blog/screens/signin.dart'; // Import your sign-up screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../components/round_button.dart';
import 'option_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar( leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const OptionScreen()), ), ), title: const Text('Blog App'), backgroundColor: Colors.pinkAccent,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30), // Adjust this value to move elements up or down
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/login_icon.jpg'), // Make sure this path is correct
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20), // Reduce vertical padding
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
                            buildForgotPassword(context),
                            const SizedBox(height: 10), // Adjust spacing between fields and button
                            RoundButton(
                              title: 'Login',
                              onPress: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => showSpinner = true);
                                  try {
                                    await _auth.signInWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                    toastMessage('User Successfully Login');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomeScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    toastMessage(e.toString());
                                  } finally {
                                    setState(() => showSpinner = false);
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 5), // Adjust spacing before sign up prompt
                            buildSignUpPrompt(context),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  Widget buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account? ", style: TextStyle(color: Colors.black87)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Signin(),
                ),
              );
            },
            child: const Text(
              'Sign Up',
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
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.pink,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
