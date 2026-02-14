import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final allScans = <ProductModel>[].obs;
  final filteredScans = <ProductModel>[].obs;
  final selectedFilter = 'All'.obs;

  final filters = ['All', 'Authentic', 'Suspicious', 'Fake'];

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) return;

      final query = await _firestore
          .collection('scans')
          .where('uid', isEqualTo: uid)
          .orderBy('scannedAt', descending: true)
          .get();

      final scans = query.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      allScans.value = scans;
      filteredScans.value = scans;
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'All') {
      filteredScans.value = allScans;
    } else {
      filteredScans.value = allScans
          .where((s) =>
              s.authenticityStatus.toLowerCase() ==
              filter.toLowerCase())
          .toList();
    }
  }

  Future<void> deleteScan(String id) async {
    try {
      await _firestore.collection('scans').doc(id).delete();
      allScans.removeWhere((s) => s.id == id);
      applyFilter(selectedFilter.value);
      Get.snackbar(
        'Deleted',
        'Scan removed from history',
        backgroundColor: const Color(0xFF2ECC71),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error deleting scan: $e');
    }
  }

  Color getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF2ECC71);
    if (score >= 4) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  Color getStatusColor(String status) {
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

  String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}