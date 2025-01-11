import 'package:dummy_socialmedia/bottomNavBar/social_media.dart';
import 'package:dummy_socialmedia/signIn_screen/phonesignin_screen.dart';
import 'package:dummy_socialmedia/signIn_services/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_img.jpg"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                child: SizedBox(
                  width: 150,
                  height: 100,
                  child: Image.asset("assets/images/chat.png"),
                ),
              ),

              const SizedBox(height: 30),

              // Welcome Text
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              // Google Sign-In Button
              _buildCustomButton(
                context,
                text: 'Continue with Google',
                icon: FontAwesomeIcons.google,
                onPressed: () async {
                  await authService.signInWithGoogle();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SocialMediaApp()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Phone Sign-In Button
              _buildCustomButton(
                context,
                text: 'Continue with Phone',
                icon: FontAwesomeIcons.phone,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhoneSignInScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button Widget
  Widget _buildCustomButton(BuildContext context,
      {required String text, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(icon, color: Colors.deepPurple),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
