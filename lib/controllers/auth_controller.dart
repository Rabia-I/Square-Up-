import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:square_up_fresh/constants.dart';
import 'package:square_up_fresh/models/user.dart' as model;
import 'package:square_up_fresh/views/screens/auth/login_screen.dart';
import 'package:square_up_fresh/views/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final Rx<firebase_auth.User?> _user = Rx<firebase_auth.User?>(null);
  final Rx<File?> _pickedImage = Rx<File?>(null);
  var isLoading = true.obs;

  File? get profilePhoto => _pickedImage.value;
  firebase_auth.User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    isLoading(true);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(firebase_auth.User? user) async {
    isLoading(true);
    try {
      if (user == null) {
        Get.offAll(() => LoginScreen());
      } else {
        await _createUserDocIfNeeded(user);
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      debugPrint("🔥 Auth Error: $e");
    } finally {
      isLoading(false);
    }
  }


  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _pickedImage.value = File(pickedImage.path);
      Get.snackbar('Profile Picture', 'Image selected!');
    }
  }

  Future<String> _uploadToSupabaseStorage(File image) async {
    final fileName = firebaseAuth.currentUser!.uid;
    final uploadedPath = await Supabase.instance.client.storage
        .from('profile-pics')
        .upload('$fileName.jpg', image);
    return Supabase.instance.client.storage.from('profile-pics').getPublicUrl('$fileName.jpg');
  }

  void registerUser(String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty && image != null) {
        isLoading(true);
        firebase_auth.UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToSupabaseStorage(image);
        model.AppUser user = model.AppUser(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );
        await firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        isLoading(false);
      } else {
        Get.snackbar('Error', 'Fill all fields');
      }
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        isLoading(true);
        await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        isLoading(false);
      } else {
        Get.snackbar('Error', 'Fill all fields');
      }
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> _createUserDocIfNeeded(firebase_auth.User user) async {
    DocumentSnapshot snap = await firestore.collection('users').doc(user.uid).get();
    if (!snap.exists) {
      await firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'Anonymous',
        'email': user.email ?? '',
        'uid': user.uid,
        'profilePhoto': user.photoURL ?? '',
      });
    }
  }
}