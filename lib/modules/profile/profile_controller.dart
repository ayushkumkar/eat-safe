import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../modules/auth/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final user = Rxn<UserModel>();

  final List<Map<String, dynamic>> healthConditions = [
    {'label': 'Diabetes', 'icon': Icons.bloodtype_rounded},
    {'label': 'Hypertension', 'icon': Icons.favorite_rounded},
    {'label': 'Obesity', 'icon': Icons.monitor_weight_rounded},
    {'label': 'Heart Disease', 'icon': Icons.heart_broken_rounded},
    {'label': 'Lactose Intolerance', 'icon': Icons.no_drinks_rounded},
    {'label': 'Gluten Intolerance', 'icon': Icons.grain_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        user.value = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateHealthConditions(List<String> conditions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'healthConditions': conditions,
      });

      // Update local user object
      user.value = UserModel(
        uid: user.value!.uid,
        name: user.value!.name,
        email: user.value!.email,
        healthConditions: conditions,
        createdAt: user.value!.createdAt,
      );

      Get.snackbar(
        'Updated!',
        'Health profile updated successfully',
        backgroundColor: const Color(0xFF2ECC71),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error updating conditions: $e');
    }
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}