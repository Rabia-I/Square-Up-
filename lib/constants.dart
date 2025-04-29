import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:square_up_fresh/controllers/auth_controller.dart';
import 'package:square_up_fresh/views/screens/add_video_screen.dart';
import 'package:square_up_fresh/views/screens/profile_screen.dart';
import 'package:square_up_fresh/views/screens/search_screen.dart';
import 'package:square_up_fresh/views/screens/video_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SUPABASE
final supabase = Supabase.instance.client;

// APP SCREENS
List pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  Text('Messages Screen'),
  ProfileScreen(uid: authController.user.uid),
];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE (for authentication and Firestore, still needed)
var firebaseAuth = FirebaseAuth.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;
