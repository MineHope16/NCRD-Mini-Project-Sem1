import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  bool showSpinner = false;
  final dbRef = FirebaseDatabase.instance.ref().child('Posts');
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

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    final snapshot = await dbRef.child('Post List').child(widget.postId).get();
    final data = snapshot.value as Map<dynamic, dynamic>;
    titleController.text = data['pTitle'] ?? '';
    descriptionController.text = data['pDescription'] ?? '';
    selectedCategory = data['category'] ?? 'Entertainment';
  }

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No Image Selected');
      }
    });
  }

  Future getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No Image Selected');
      }
    });
  }

  void dialog(context) {
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

  Future<void> _updatePost() async {
    setState(() {
      showSpinner = true;
    });
    try {
      String imageUrl = '';
      if (_image != null) {
        final int date = DateTime.now().microsecondsSinceEpoch;
        firebase_storage.Reference ref = storage.ref().child('blogapp$date');
        firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);
        await Future.value(uploadTask);
        imageUrl = await ref.getDownloadURL();
      }

      final updateData = {
        'pTitle': titleController.text,
        'pDescription': descriptionController.text,
        'category': selectedCategory,
        if (imageUrl.isNotEmpty) 'pImage': imageUrl,
      };

      await dbRef.child('Post List').child(widget.postId).update(updateData);
      Fluttertoast.showToast(msg: 'Post updated successfully');
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update post: $e');
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
        appBar: AppBar(
        title: const Text('Edit Post'),
    backgroundColor: Colors.pinkAccent,
    ),
    body: Padding(
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
      ElevatedButton(
        onPressed: _updatePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: const Text('Update Post'),
      ),
    ],
    ),
    ),
    ],
    ),
    ),
        ),
    );
  }
}

