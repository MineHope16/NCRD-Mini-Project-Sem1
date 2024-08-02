import 'package:blog/screens/add_post.dart';
import 'package:blog/screens/edit_post_screen.dart';
import 'package:blog/screens/login_screen.dart';
import 'package:blog/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommentSectionScreen extends StatefulWidget {
  final String postId;
  const CommentSectionScreen({required this.postId, Key? key}) : super(key: key);

  @override
  _CommentSectionScreenState createState() => _CommentSectionScreenState();
}

class _CommentSectionScreenState extends State<CommentSectionScreen> {
  final dbRef = FirebaseDatabase.instance.ref().child('Posts');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Section'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder(
        future: _getPostDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final post = snapshot.data as Map<dynamic, dynamic>;
            final title = post['pTitle'] ?? 'No Title';
            final description = post['pDescription'] ?? 'No Description';
            final comments = post['comments'] as Map<dynamic, dynamic>?;

            return Column(
              children: [
                // Post Details
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(description, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                // Comments List
                Expanded(
                  child: ListView.builder(
                    itemCount: comments?.length ?? 0,
                    itemBuilder: (context, index) {
                      final commentKey = comments!.keys.elementAt(index);
                      final comment = comments[commentKey];
                      final commenterEmail = comment['email'] ?? 'Anonymous';
                      final commentText = comment['text'] ?? '';

                      return ListTile(
                        title: Text(commentText),
                        subtitle: Text(commenterEmail),
                      );
                    },
                  ),
                ),
                // Add Comment Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            labelText: 'Add a comment',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Map<dynamic, dynamic>> _getPostDetails() async {
    final snapshot = await dbRef.child('Post List').child(widget.postId).get();
    if (snapshot.exists) {
      return snapshot.value as Map<dynamic, dynamic>;
    } else {
      throw Exception('Post not found');
    }
  }

  void _addComment() async {
    final user = auth.currentUser;
    if (user != null) {
      final commentText = commentController.text.trim();
      if (commentText.isNotEmpty) {
        final comment = {
          'text': commentText,
          'email': user.email,
          'timestamp': DateTime.now().toIso8601String(),
        };

        try {
          await dbRef.child('Post List').child(widget.postId).child('comments').push().set(comment);
          Fluttertoast.showToast(msg: 'Comment added');
          commentController.clear();
          setState(() {}); // Refresh comments
        } catch (e) {
          Fluttertoast.showToast(msg: 'Failed to add comment: $e');
        }
      } else {
        Fluttertoast.showToast(msg: 'Comment cannot be empty');
      }
    } else {
      Fluttertoast.showToast(msg: 'You must be logged in to comment');
    }
  }
}
