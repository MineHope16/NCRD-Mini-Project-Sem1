import 'dart:io';

import 'package:blog/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _nameController.text = _user.displayName ?? '';
    _emailController.text = _user.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Fluttertoast.showToast(msg: 'No image selected');
      }
    });
  }

  Future<void> _updateProfile() async {
    try {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${_user.uid}');
        final uploadTask = storageRef.putFile(_image!);
        await uploadTask.whenComplete(() async {
          final imageUrl = await storageRef.getDownloadURL();
          await _user.updateProfile(displayName: _nameController.text, photoURL: imageUrl);
        });
      } else {
        await _user.updateProfile(displayName: _nameController.text);
      }

      await _user.updateEmail(_emailController.text);
      Fluttertoast.showToast(msg: 'Profile updated successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update profile: $e');
    }
  }

  Future<void> _updatePassword() async {
    try {
      if (_passwordController.text.isNotEmpty) {
        await _user.updatePassword(_passwordController.text);
        Fluttertoast.showToast(msg: 'Password updated successfully');
      } else {
        Fluttertoast.showToast(msg: 'Please enter a new password');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update password: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (_user.photoURL != null
                    ? NetworkImage(_user.photoURL!)
                    : null) as ImageProvider,
                child: _image == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(controller: _nameController, label: 'Name'),
            const SizedBox(height: 10),
            _buildTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _passwordController,
              label: 'New Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _buildButton(
              label: 'Update Profile',
              onPressed: _updateProfile,
            ),
            const SizedBox(height: 10),
            _buildButton(
              label: 'Change Password',
              onPressed: _updatePassword,
            ),
            const SizedBox(height: 10),
            _buildButton(
              label: 'Logout',
              onPressed: _logout,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.pink,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
