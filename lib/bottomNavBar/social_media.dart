
import 'package:dummy_socialmedia/socialMedia/add_friends.dart';
import 'package:flutter/material.dart';
import 'package:dummy_socialmedia/socialMedia/add_screen.dart';
import 'package:dummy_socialmedia/socialMedia/home_screen.dart';
import 'package:dummy_socialmedia/socialMedia/profile_screen.dart';

void main() => runApp(SocialMediaApp());

class SocialMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavScreen(),
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  // Screens
  final List<Widget> _screens = [
    HomeScreen(), // Home screen
    AddFriendsScreen(), // Add friends screen
    AddPostScreen(), // Add post screen
    ProfileScreen(), // Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.orangeAccent, // Changed color for selected item
        unselectedItemColor: Colors.grey, // Kept color for unselected item
        showSelectedLabels: false, // Hides labels
        showUnselectedLabels: false, // Hides labels
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: _currentIndex == 0 ? Colors.orangeAccent : Colors.grey,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.orangeAccent,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_add_alt_1_outlined,
              color: _currentIndex == 1 ? Colors.orangeAccent : Colors.grey,
            ),
            activeIcon: Icon(
              Icons.person_add_alt_sharp,
              color: Colors.orangeAccent,
            ),
            label: 'Add Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
              color: _currentIndex == 2 ? Colors.orangeAccent : Colors.grey,
            ),
            activeIcon: Icon(
              Icons.add_circle,
              color: Colors.orangeAccent,
            ),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: _currentIndex == 3 ? Colors.orangeAccent : Colors.grey,
            ),
            activeIcon: Icon(
              Icons.person,
              color: Colors.orangeAccent,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
