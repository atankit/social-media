import 'dart:async';
import 'package:dummy_socialmedia/bottomNavBar/social_media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dummy_socialmedia/signIn_screen/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    // Initialize Fade-in Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Navigate to SignInScreen after 4 seconds

    if(user != null){
      Timer(const Duration(seconds: 6),()=>  Navigator.push(context, MaterialPageRoute(builder:
          (context) => SocialMediaApp())) );
    }
    else{
      Timer(const Duration(seconds: 6), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)], // Purple gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Image.asset(
                  "assets/images/chat.png", // Replace with your app logo
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                // App Name
                const Text(
                  "Social Media App",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Popp',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Tagline
                const Text(
                  "Connect, Share, Explore",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Popp',
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
