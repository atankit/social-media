
import 'package:dummy_socialmedia/signIn_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In Demo',
      theme: ThemeData(
        fontFamily: 'Popp',
        primarySwatch: Colors.yellow,
      ),
      // home: const SignInScreen(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
