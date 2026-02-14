import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final userName = ''.obs;
  final recentScans = <ProductModel>[].obs;
  final totalScans = 0.obs;
  final fakeDetected = 0.obs;
  final avgScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) return;

      // Load user info
      final userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final user = UserModel.fromMap(userDoc.data()!);
        userName.value = user.name.split(' ').first;
      }

      // Load recent scans
      final scansQuery = await _firestore
          .collection('scans')
          .where('uid', isEqualTo: uid)
          .orderBy('scannedAt', descending: true)
          .limit(5)
          .get();

      final scans = scansQuery.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      recentScans.value = scans;
      totalScans.value = scans.length;

      // Calculate stats
      fakeDetected.value = scans
          .where((s) => s.authenticityStatus == 'FAKE')
          .length;

      if (scans.isNotEmpty) {
        avgScore.value = scans
                .map((s) => s.nutritionScore)
                .reduce((a, b) => a + b) /
            scans.length;
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Color getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF2ECC71);
    if (score >= 4) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  String getScoreLabel(double score) {
    if (score >= 7) return 'Healthy';
    if (score >= 4) return 'Moderate';
    return 'Unhealthy';
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'AUTHENTIC':
        return '0xFF2ECC71';
      case 'SUSPICIOUS':
        return '0xFFF39C12';
      case 'FAKE':
        return '0xFFE74C3C';
      default:
        return '0xFF7F8C8D';
    }
  }
}