import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dummy_socialmedia/signIn_screen/signin_screen.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController(); // Changed from Address to Bio

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile data from Firestore
  void _loadUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? ''; // Updated field to 'bio'
        });
      }
    }
  }

  // Update profile in Firestore
  Future<void> _updateProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // Update user data in Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'username': _usernameController.text,
      'bio': _bioController.text, // Updated field to 'bio'
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? ''
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  // Sign-Out Function
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit', style: TextStyle(fontFamily: 'Philo', fontSize: 40 ,fontWeight: FontWeight.bold)),
      ),
      body: user != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Username Field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Bio Field
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Save Button
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Background color
                foregroundColor: Colors.white,    // Text color
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 5, // Button shadow
                shadowColor: Colors.deepPurpleAccent, // Shadow color
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        ),
      )
          : const Center(
        child: Text(
          'No user is signed in',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
