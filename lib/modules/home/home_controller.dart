import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final userName = ''.obs;
  final recentScans = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadRecentScans();
  }

  Future<void> loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!);
        userName.value = user.name.split(' ').first; // First name only
      }
    } catch (e) {
      userName.value = 'User';
    }
  }

  Future<void> loadRecentScans() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('scans')
          .orderBy('scannedAt', descending: true)
          .limit(5)
          .get();

      recentScans.value = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      recentScans.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF2ECC71);
    if (score >= 4) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  String getStatusEmoji(String status) {
    switch (status) {
      case 'AUTHENTIC': return '✅';
      case 'SUSPICIOUS': return '⚠️';
      case 'FAKE': return '❌';
      default: return '❓';
    }
  }
}