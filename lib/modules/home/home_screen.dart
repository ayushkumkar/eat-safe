import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/product_model.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF2ECC71),
          onRefresh: () async {
            await controller.loadUserData();
            await controller.loadRecentScans();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(controller),
                _buildScanCard(),
                _buildQuickStats(),
                _buildRecentScans(controller),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────────────
  Widget _buildHeader(HomeController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        '${controller.getGreeting()},',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      )),
                  Obx(() => Text(
                        controller.userName.value.isEmpty
                            ? 'Loading...'
                            : controller.userName.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                ],
              ),
              Row(
                children: [
                  // History Button
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.history),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Profile Button
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar (decorative for now)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Color(0xFF7F8C8D), size: 20),
                SizedBox(width: 10),
                Text(
                  'Search products...',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Big Scan Card ────────────────────────────────────
  Widget _buildScanCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.scan),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scan a Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify authenticity &\ncheck nutrition instantly',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Scan Now →',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Stats ──────────────────────────────────────
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          _statCard(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF2ECC71),
            bgColor: const Color(0xFFD5F5E3),
            label: 'Safe Products',
            value: '0',
          ),
          const SizedBox(width: 14),
          _statCard(
            icon: Icons.warning_rounded,
            iconColor: const Color(0xFFF39C12),
            bgColor: const Color(0xFFFEF9E7),
            label: 'Suspicious',
            value: '0',
          ),
          const SizedBox(width: 14),
          _statCard(
            icon: Icons.cancel_rounded,
            iconColor: const Color(0xFFE74C3C),
            bgColor: const Color(0xFFFDEDEC),
            label: 'Fake Found',
            value: '0',
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Scans ─────────────────────────────────────
  Widget _buildRecentScans(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.history),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
              );
            }
            if (controller.recentScans.isEmpty) {
              return _buildEmptyScans();
            }
            return Column(
              children: controller.recentScans
                  .map((scan) => _buildScanItem(scan, controller))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyScans() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan your first product to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFBDC3C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanItem(ProductModel scan, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score Circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: controller
                  .getScoreColor(scan.nutritionScore)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                scan.nutritionScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: controller.getScoreColor(scan.nutritionScore),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scan.brand,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scan.authenticityStatus == 'AUTHENTIC'
                  ? const Color(0xFFD5F5E3)
                  : scan.authenticityStatus == 'FAKE'
                      ? const Color(0xFFFDEDEC)
                      : const Color(0xFFFEF9E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${controller.getStatusEmoji(scan.authenticityStatus)} ${scan.authenticityStatus}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scan.authenticityStatus == 'AUTHENTIC'
                    ? const Color(0xFF2ECC71)
                    : scan.authenticityStatus == 'FAKE'
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFFF39C12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home', true),
          _navItem(Icons.history_rounded, 'History', false,
              onTap: () => Get.toNamed(AppRoutes.history)),
          // Center Scan Button
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.scan),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          _navItem(Icons.bar_chart_rounded, 'Stats', false),
          _navItem(Icons.person_rounded, 'Profile', false,
              onTap: () => Get.toNamed(AppRoutes.profile)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? const Color(0xFF2ECC71)
                : const Color(0xFFBDC3C7),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFFBDC3C7),
            ),
          ),
        ],
      ),
    );
  }
}