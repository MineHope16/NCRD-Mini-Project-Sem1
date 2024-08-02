import 'dart:io';
import 'package:blog/screens/add_post.dart';
import 'package:blog/screens/edit_post_screen.dart';
import 'package:blog/screens/login_screen.dart';
import 'package:blog/screens/post_detail_screen.dart';
import 'package:blog/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import 'comment_section_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbRef = FirebaseDatabase.instance.ref().child('Posts');
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController searchController = TextEditingController();
  String search = "";
  String selectedCategory = 'All';

  final List<String> categories = [
    "All",
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Blogs'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.pinkAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPostScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                auth.signOut().then((onValue) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                });
              },
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: Column(
          children: [
            // Category Dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedCategory,
                icon: const Icon(Icons.category),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                    searchController.clear();
                    search = "";
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Search with blog title',
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {
                    search = value.toLowerCase();
                  });
                },
              ),
            ),
            // Trending Section
            _buildTrendingSection(),
            // Blog List
            Expanded(
              child: FirebaseAnimatedList(
                query: _getQuery(),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  if (snapshot.value != null && snapshot.value is Map) {
                    final data = snapshot.value as Map<dynamic, dynamic>;
                    final postId = snapshot.key;
                    final imageUrl = data['pImage'] ?? '';
                    final title = data['pTitle'] ?? 'No Title';
                    final description = data['pDescription'] ?? 'No Description';
                    final userProfilePic = data['userProfilePic'] ?? '';
                    final userName = data['userName'] ?? 'Anonymous';
                    final uploadDate = data['uploadDate'] ?? '';
                    final category = data['category'] ?? 'Uncategorized'; // New category field
                    final likesCount = data['likes'] ?? 0;
                    final comments = data['comments'] as Map<dynamic, dynamic>?;
                    final commentsCount = comments?.length ?? 0;

                    if (searchController.text.isEmpty || title.toLowerCase().contains(search)) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                FadeInImage.assetNetwork(
                                  placeholder: 'assets/blogging_9611762.png',
                                  image: imageUrl,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: double.infinity,
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      category,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      uploadDate,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
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
                                          _likePost(postId!, likesCount);
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
                                        builder: (context) => EditPostScreen(postId: postId!),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deletePost(postId!);
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostDetailScreen(postId: postId!),
                                      ),
                                    );
                                  },
                                  child: const Text('View Post'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },

              ),
            ),
          ],
        ),
      ),
    );
  }

  Query _getQuery() {
    if (selectedCategory == 'All') {
      return dbRef.child('Post List');
    } else {
      return dbRef.child('Post List').orderByChild('category').equalTo(selectedCategory);
    }
  }

  Widget _buildTrendingSection() {
    return FutureBuilder(
      future: _getTrendingPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final trendingPosts = snapshot.data as List<Map<dynamic, dynamic>>;
          return trendingPosts.isEmpty
              ? const Center(child: Text('No trending posts available'))
              : Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Trending Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingPosts.length,
                  itemBuilder: (context, index) {
                    final post = trendingPosts[index];
                    final postId = post['postId'];
                    final title = post['pTitle'];
                    final imageUrl = post['pImage'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(postId: postId),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: 'assets/blogging_9611762.png',
                              image: imageUrl,
                              fit: BoxFit.cover,
                              height: 120,
                              width: 200,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<Map<dynamic, dynamic>>> _getTrendingPosts() async {
    List<Map<dynamic, dynamic>> trendingPosts = [];

    try {
      final trendingQuery = await dbRef.child('Post List')
          .orderByChild('likes')
          .limitToLast(10)
          .get();
      if (trendingQuery.exists) {
        for (var post in trendingQuery.children) {
          if (post.value != null && post.value is Map) {
            final data = post.value as Map<dynamic, dynamic>;
            data['postId'] = post.key;
            trendingPosts.add(data);
          }
        }
      }
    } catch (e) {
      print('Failed to load trending posts: $e');
    }

    return trendingPosts;
  }

  void _deletePost(String postId) async {
    try {
      await dbRef.child('Post List').child(postId).remove();
      Fluttertoast.showToast(msg: 'Post deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete post: $e');
    }
  }

  Future<void> _downloadPDF(String title, String description) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(description, style: const pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$title.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  void _likePost(String postId, int currentLikes) async {
    try {
      final newLikesCount = currentLikes + 1;
      await dbRef.child('Post List').child(postId).update({'likes': newLikesCount});
      Fluttertoast.showToast(msg: 'Post liked');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to like post: $e');
    }
  }
}