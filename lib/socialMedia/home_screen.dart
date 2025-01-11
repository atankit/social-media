import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  void _editPost(BuildContext context, String postId, String currentContent) {
    final TextEditingController _controller = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Update your post content",
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_controller.text.trim().isNotEmpty) {
                  await _firestore.collection('posts').doc(postId).update({
                    'content': _controller.text.trim(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('posts').doc(postId).delete();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _likePost(String postId, String userId) async {
    final postDoc = _firestore.collection('posts').doc(postId);

    _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postDoc);

      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
        dislikes.remove(userId);
      }

      transaction.update(postDoc, {'likes': likes, 'dislikes': dislikes});
    });
  }

  void _dislikePost(String postId, String userId) async {
    final postDoc = _firestore.collection('posts').doc(postId);

    _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postDoc);

      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);

      if (dislikes.contains(userId)) {
        dislikes.remove(userId);
      } else {
        dislikes.add(userId);
        likes.remove(userId);
      }

      transaction.update(postDoc, {'likes': likes, 'dislikes': dislikes});
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Home', style: TextStyle(fontFamily: 'Philo', fontSize: 40 ,fontWeight: FontWeight.bold)),
      ),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No posts available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;
              final userId = postData['userId'];

              // Check if the post is public or private
              final visibility = postData['private'] ?? false;
              if (visibility == true && userId != currentUserId) {
                // Skip private posts that are not from the current user
                return Container();
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: const LinearProgressIndicator(),
                    );
                  }

                  if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('User not found.'),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final likes = List<String>.from(postData['likes'] ?? []);
                  final dislikes = List<String>.from(postData['dislikes'] ?? []);
                  final isLiked = likes.contains(currentUserId);
                  final isDisliked = dislikes.contains(currentUserId);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: User info
                        ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: userData['profilePicture'] != null &&
                                  userData['profilePicture']!.isNotEmpty
                                  ? null
                                  : Colors.grey[300],
                              backgroundImage: userData['profilePicture'] != null &&
                                  userData['profilePicture']!.isNotEmpty
                                  ? NetworkImage(userData['profilePicture']!)
                                  : null,
                              child: userData['profilePicture'] == null ||
                                  userData['profilePicture']!.isEmpty
                                  ? Text(
                                userData['username']?.substring(0, 1) ?? 'U',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          title: Text(
                            userData['username'] ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            postData['createdAt'] != null
                                ? timeago.format(
                              DateTime.parse(postData['createdAt']),
                              locale: 'en',
                            )
                                : 'Unknown Time',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: userId == currentUserId
                              ? PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editPost(context, post.id, postData['content']);
                              } else if (value == 'delete') {
                                _deletePost(context, post.id);
                              }
                            },
                          )
                              : null,
                        ),
                        // Post Content
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            postData['content'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        // Footer: Like/Dislike buttons and counts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _likePost(post.id, currentUserId),
                                  icon: Icon(
                                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                    color: isLiked ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                Text(
                                  likes.length.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _dislikePost(post.id, currentUserId),
                                  icon: Icon(
                                    isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                                    color: isDisliked ? Colors.red : Colors.grey,
                                  ),
                                ),
                                Text(
                                  dislikes.length.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      )

    );
  }
}
