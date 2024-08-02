import 'dart:io';

import 'package:blog/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// Custom aspect ratio class
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool showSpinner = false;
  final postRef = FirebaseDatabase.instance.ref().child('Posts');
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Entertainment';

  final List<String> categories = [
    "Entertainment",
    "Food",
    "Music",
    "Technology",
    "Fashion",
    "Lifestyle",
    "Travel",
    "Fitness",
    "Health"
  ];

  Future<void> getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.pink,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
            ],
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
        } else {
          print('No Image Selected');
        }
      });
    }
  }

  Future<void> getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.pink,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
            ],
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
        } else {
          print('No Image Selected');
        }
      });
    }
  }

  void dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: SizedBox(
            height: 120,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    getCameraImage();
                    Navigator.pop(context);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                  ),
                ),
                InkWell(
                  onTap: () {
                    getImageGallery();
                    Navigator.pop(context);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
        appBar: AppBar(
        title: const Text('Upload Blogs'),
    centerTitle: true,
    backgroundColor: Colors.pinkAccent,
    ),
    body: SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Column(
    children: [
    InkWell(
    onTap: () {
    dialog(context);
    },
    child: Center(
    child: SizedBox(
    height: MediaQuery.of(context).size.height * .3,
    width: MediaQuery.of(context).size.width * 1,
    child: _image != null
    ? ClipRect(
    child: Image.file(
    _image!.absolute,
    fit: BoxFit.fill,
    ),
    )
        : Container(
    decoration: BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
    child: Icon(
    Icons.camera_alt,
    color: Colors.blue,
    size: 50,
    ),
    ),
    ),
    ),
    ),
    ),
    const SizedBox(height: 30),
    Form(
    child: Column(
    children: [
    // Category Dropdown
    DropdownButton<String>(
    value: selectedCategory,
    icon: const Icon(Icons.category),
    onChanged: (String? newValue) {
    setState(() {
    selectedCategory = newValue!;
    });
    },
    items: categories.map<DropdownMenuItem<String>>((String category) {
    return DropdownMenuItem<String>(
    value: category,
    child: Text(category),
    );
    }).toList(),
    ),
    const SizedBox(height: 30),
    TextFormField(
    controller: titleController,
    keyboardType: TextInputType.text,
    decoration: const InputDecoration(
    labelText: 'Title',
    hintText: 'Enter Post Title',
    border: OutlineInputBorder(),
    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
    labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
    ),
    ),
    const SizedBox(height: 30),
    TextFormField(
    controller: descriptionController,
    keyboardType: TextInputType.text,
    minLines: 1,
    maxLines: 5,
    decoration: const InputDecoration(
    labelText: 'Description',
    hintText: 'Enter Post Description',
    border: OutlineInputBorder(),
    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
    labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
    ),
    ),
    const SizedBox(height: 30),
    RoundButton(
    title: 'Upload',
    onPress: () async {
    setState(() {
    showSpinner = true;
    });
    try {
    int date = DateTime.now().microsecondsSinceEpoch;

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/blogapp$date');
    UploadTask uploadTask = ref.putFile(_image!.absolute);
    await Future.value(uploadTask);
    var newUrl = await ref.getDownloadURL();

    final User? user = _auth.currentUser;
    postRef.child('Post List').child(date.toString()).set({
    'pId': date.toString(),
    'pImage': newUrl.toString(),
    'pTime': date.toString(),
    'pTitle': titleController.text.toString(),
    'pDescription': descriptionController.text.toString(),
    'uEmail': user!.email.toString(),
    'uid': user.uid.toString(),
    'category': selectedCategory, // Save category
    }).then((value) {
    toastMessage('Post Published Successfully');
    setState(() {
    showSpinner = false;
    });
    Navigator.pop(context); // Navigate back to HomeScreen
    }).onError((error, stackTrace) {
    toastMessage(error.toString());
    setState(() {
    showSpinner = false;
    });
    });
    } catch (e) {
    setState(() {
    showSpinner = false;
    });
    toastMessage(e.toString());
    }
    },
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
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

