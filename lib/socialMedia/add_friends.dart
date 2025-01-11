import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendsScreen extends StatefulWidget {
  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  // Check if the current user is following a specific user
  Future<bool> isFollowing(String userId) async {
    try {
      if (_currentUser != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
        final data = doc.data() as Map<String, dynamic>?;
        return data?['following']?.contains(userId) ?? false;
      }
    } catch (e) {
      debugPrint('Error checking following status: $e');
    }
    return false;
  }

  // Toggle follow/unfollow
  Future<void> toggleFollow(String userId) async {
    if (_currentUser != null) {
      try {
        bool following = await isFollowing(userId);

        if (following) {
          // Unfollow logic
          await _firestore.collection('users').doc(_currentUser!.uid).update({
            'following': FieldValue.arrayRemove([userId]),
          });
          await _firestore.collection('users').doc(userId).update({
            'followers': FieldValue.arrayRemove([_currentUser!.uid]),
          });
        } else {
          // Follow logic
          await _firestore.collection('users').doc(_currentUser!.uid).update({
            'following': FieldValue.arrayUnion([userId]),
          });
          await _firestore.collection('users').doc(userId).update({
            'followers': FieldValue.arrayUnion([_currentUser!.uid]),
          });
        }
      } catch (e) {
        debugPrint('Error toggling follow status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Add Friends', style: TextStyle(fontFamily: 'Philo', fontSize: 40 ,fontWeight: FontWeight.bold)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends', style: TextStyle(fontFamily: 'Philo', fontSize: 40 ,fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading users: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          // Exclude the current user from the list
          var users = snapshot.data!.docs.where((doc) => doc.id != _currentUser!.uid).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                trailing: FutureBuilder<bool>(
                  future: isFollowing(user.id),
                  builder: (context, followingSnapshot) {
                    if (followingSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (followingSnapshot.hasError) {
                      return Icon(Icons.error, color: Colors.red);
                    }

                    bool isFollowing = followingSnapshot.data ?? false;

                    return ElevatedButton(
                      onPressed: () => toggleFollow(user.id),
                      child: Text(isFollowing ? 'Unfollow' : ' Follow   ' ,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
