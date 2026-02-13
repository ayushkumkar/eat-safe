import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  // Selected health conditions during register
  final selectedConditions = <String>[].obs;

  final List<Map<String, dynamic>> healthConditions = [
    {'label': 'Diabetes', 'icon': Icons.bloodtype_rounded},
    {'label': 'Hypertension', 'icon': Icons.favorite_rounded},
    {'label': 'Obesity', 'icon': Icons.monitor_weight_rounded},
    {'label': 'Heart Disease', 'icon': Icons.heart_broken_rounded},
    {'label': 'Lactose Intolerance', 'icon': Icons.no_drinks_rounded},
    {'label': 'Gluten Intolerance', 'icon': Icons.grain_rounded},
  ];

  void toggleCondition(String condition) {
    if (selectedConditions.contains(condition)) {
      selectedConditions.remove(condition);
    } else {
      selectedConditions.add(condition);
    }
  }

  // REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Create user in Firebase Auth
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user data in Firestore
      final user = UserModel(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email.trim(),
        healthConditions: selectedConditions.toList(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toMap());

      // Save uid locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', cred.user!.uid);

      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      }
      Get.snackbar(
        'Registration Failed',
        message,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save uid locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', cred.user!.uid);

      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }
      Get.snackbar(
        'Login Failed',
        message,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    Get.offAllNamed(AppRoutes.login);
  }
}