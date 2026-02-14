import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';

class ResultController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final product = Rxn<ProductModel>();
  String? imagePath;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    imagePath = args?['imagePath'];
    _loadMockResult();
  }

  // Mock result — will be replaced with real API in Phase 5
  Future<void> _loadMockResult() async {
    await Future.delayed(const Duration(milliseconds: 500));

    product.value = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: 'Maggi 2-Minute Noodles',
      brand: 'Nestlé',
      fssaiNumber: '10013022002253',
      imageUrl: '',
      nutritionScore: 4.2,
      nutrients: {
        'calories': 350,
        'protein': 8.5,
        'carbohydrates': 52.0,
        'sugar': 2.1,
        'fat': 12.0,
        'saturatedFat': 5.5,
        'sodium': 890,
        'fiber': 2.0,
      },
      authenticityStatus: 'AUTHENTIC',
      scannedAt: DateTime.now(),
    );

    isLoading.value = false;
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null || product.value == null) return;

      final data = product.value!.toMap();
      data['uid'] = uid;

      await _firestore
          .collection('scans')
          .doc(product.value!.id)
          .set(data);
    } catch (e) {
      debugPrint('Error saving scan: $e');
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

  Color getAuthColor(String status) {
    switch (status) {
      case 'AUTHENTIC':
        return const Color(0xFF2ECC71);
      case 'SUSPICIOUS':
        return const Color(0xFFF39C12);
      case 'FAKE':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData getAuthIcon(String status) {
    switch (status) {
      case 'AUTHENTIC':
        return Icons.verified_rounded;
      case 'SUSPICIOUS':
        return Icons.warning_amber_rounded;
      case 'FAKE':
        return Icons.dangerous_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Nutrient warning levels
  String getNutrientLevel(String nutrient, double value) {
    switch (nutrient) {
      case 'sugar':
        if (value > 10) return 'HIGH';
        if (value > 5) return 'MEDIUM';
        return 'LOW';
      case 'sodium':
        if (value > 600) return 'HIGH';
        if (value > 300) return 'MEDIUM';
        return 'LOW';
      case 'fat':
        if (value > 17) return 'HIGH';
        if (value > 8) return 'MEDIUM';
        return 'LOW';
      case 'saturatedFat':
        if (value > 5) return 'HIGH';
        if (value > 2) return 'MEDIUM';
        return 'LOW';
      default:
        return 'LOW';
    }
  }

  Color getNutrientColor(String level) {
    switch (level) {
      case 'HIGH':
        return const Color(0xFFE74C3C);
      case 'MEDIUM':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF2ECC71);
    }
  }
}