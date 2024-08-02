import 'dart:io';
import 'package:blog/screens/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import 'comment_section_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({required this.postId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder(
        future: _fetchPostDetails(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data as Map<dynamic, dynamic>;
            final title = data['pTitle'] ?? 'No Title';
            final description = data['pDescription'] ?? 'No Description';
            final imageUrl = data['pImage'] ?? '';
            final userProfilePic = data['userProfilePic'] ?? '';
            final userName = data['userName'] ?? 'Anonymous';
            final uploadDate = data['uploadDate'] ?? '';
            final likesCount = data['likes'] ?? 0;
            final comments = data['comments'] as Map<dynamic, dynamic>?;
            final commentsCount = comments?.length ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/blogging_9611762.png',
                    image: imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(description, style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(userProfilePic),
                              radius: 15,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              userName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          uploadDate,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up, color: Colors.blue, size: 20),
                              onPressed: () {
                                _likePost(postId, likesCount);
                              },
                            ),
                            Text('$likesCount Likes', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.comment, color: Colors.grey, size: 20),
                              onPressed: () {
                                // Handle comments navigation or functionality
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommentSectionScreen(postId: postId!),
                                  ),
                                );
                              },
                            ),
                            Text('$commentsCount Comments', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () {
                            _downloadPDF(title, description);
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPostScreen(postId: postId),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deletePost(postId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<dynamic, dynamic>> _fetchPostDetails(String postId) async {
    try {
      final postSnapshot = await FirebaseDatabase.instance.ref().child('Posts').child('Post List').child(postId).get();
      if (postSnapshot.exists) {
        return postSnapshot.value as Map<dynamic, dynamic>;
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch post details: $e');
    }
  }

  void _likePost(String postId, int currentLikes) async {
    try {
      final postRef = FirebaseDatabase.instance.ref().child('Posts').child('Post List').child(postId);
      await postRef.update({'likes': currentLikes + 1});
      Fluttertoast.showToast(msg: 'Post liked!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to like post: $e');
    }
  }

  void _deletePost(String postId) async {
    try {
      final postRef = FirebaseDatabase.instance.ref().child('Posts').child('Post List').child(postId);
      await postRef.remove();
      Fluttertoast.showToast(msg: 'Post deleted successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete post: $e');
    }
  }

  Future<void> _downloadPDF(String title, String description) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                description,
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/${title.replaceAll(' ', '_')}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      Fluttertoast.showToast(msg: 'PDF saved to $filePath');

      // Open the PDF file
      await OpenFile.open(filePath);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to save PDF: $e');
    }
  }
}
