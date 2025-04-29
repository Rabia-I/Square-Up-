import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:square_up_fresh/constants.dart';
import 'package:square_up_fresh/controllers/auth_controller.dart';
import 'package:square_up_fresh/views/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    await Supabase.initialize(
      url: 'https://mfinzesekftjjmkmdtlz.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1maW56ZXNla2Z0ampta21kdGx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3MzM1MTEsImV4cCI6MjA2MTMwOTUxMX0.xE1yegecWDOQeuOxO-rzFbcwJmliGmjuptwQ0Rgz7Rc',
    );
  } catch (e) {
    debugPrint("🔥 Initialization Error: $e");
  }

  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Requires Dart 2.17+ (fixed via pubspec.yaml)

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Square Up',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: GetBuilder<AuthController>(
        builder: (authController) {
          // ✅ Fixed: Use .value for RxBool comparison
          if (authController.isLoading.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return LoginScreen();
        },
      ),
    );
  }
}