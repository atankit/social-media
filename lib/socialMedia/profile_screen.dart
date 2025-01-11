import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dummy_socialmedia/signIn_screen/signin_screen.dart';
import 'package:dummy_socialmedia/socialMedia/details_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign-Out Function
  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut(); // Google Sign-Out
      await _auth.signOut(); // Firebase Auth Sign-Out

      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error while signing out: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> createUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      // If user document does not exist, create it
      if (!docSnapshot.exists) {
        await userDoc.set({
          'username': user.displayName ?? 'New User',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'bio': '',
          'profilePicture': user.photoURL ?? '',
        });
      }
    } catch (e) {
      print("Error creating user document: ${e.toString()}");
    }
  }

  Future<Map<String, int>> fetchCounts(String userId) async {
    try {
      // Fetch the count of posts for the current user
      var postsCount = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) => value.docs.length);

      // Fetch the count of followers and following
      var userDoc = await _firestore.collection('users').doc(userId).get();
      var followersCount = userDoc.data()?['followers'] != null
          ? (userDoc.data()?['followers'] as List).length
          : 0;
      var followingCount = userDoc.data()?['following'] != null
          ? (userDoc.data()?['following'] as List).length
          : 0;

      return {
        'posts': postsCount,
        'followers': followersCount,
        'following': followingCount,
      };
    } catch (e) {
      print("Error fetching counts: ${e.toString()}");
      return {'posts': 0, 'followers': 0, 'following': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontFamily: 'Philo', fontSize: 40 ,fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(), // Listen to auth state changes
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const Center(child: Text('User not logged in'));
          } else {
            final User user = authSnapshot.data!;
            createUserDocument(user); // Ensure user document exists

            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(user.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text('No user data available'));
                } else {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return FutureBuilder<Map<String, int>>(
                    future: fetchCounts(user.uid),
                    builder: (context, countsSnapshot) {
                      if (countsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final counts = countsSnapshot.data ?? {'posts': 0, 'followers': 0, 'following': 0};

                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Profile Picture
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(height: 12),

                                // Username
                                Text(
                                  userData['username'] ?? 'Unknown Username',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),


                                Text(
                                  // '${userData['email'] ?? 'No email'} | ${userData['phone'] ?? 'No phone'}',
                                  '${userData['email'] ?? ''}  ${userData['phone'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                // Bio
                                Text(
                                  userData['bio'] ?? 'No bio available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Stats: Posts, Followers, Following
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          counts['posts'].toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Posts'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          counts['followers'].toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Followers'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          counts['following'].toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Following'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Edit Profile Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailsScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Edit Profile",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
