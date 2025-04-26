import 'package:flutter/material.dart';
import 'package:imitation/screens/home.dart';
import 'package:imitation/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    runApp(
        MaterialApp(
          home: user != null ? HomeScreen(user: user) : SplashScreen(),
          debugShowCheckedModeBanner: false,
        )
    );
  });
}