import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'history_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2C3E50),
          ),
        ),
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF2C3E50),
            ),
            onPressed: controller.loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Tabs ──
          _buildFilterTabs(controller),

          // ── Scan List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2ECC71),
                  ),
                );
              }

              if (controller.filteredScans.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                color: const Color(0xFF2ECC71),
                onRefresh: controller.loadHistory,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.filteredScans.length,
                  itemBuilder: (context, index) {
                    final scan = controller.filteredScans[index];
                    return _buildScanCard(scan, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Filter Tabs ──
  Widget _buildFilterTabs(HistoryController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.filters.map((filter) {
                final isSelected =
                    controller.selectedFilter.value == filter;
                return GestureDetector(
                  onTap: () => controller.applyFilter(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF7F8C8D),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  // ── Scan Card ──
  Widget _buildScanCard(dynamic scan, HistoryController controller) {
    final scoreColor = controller.getScoreColor(scan.nutritionScore);
    final statusColor = controller.getStatusColor(scan.authenticityStatus);

    return Dismissible(
      key: Key(scan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Scan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Remove this scan from your history?',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF7F8C8D)),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFFE74C3C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => controller.deleteScan(scan.id),
      child: GestureDetector(
        onTap: () => Get.toNamed(
          AppRoutes.result,
          arguments: {'imagePath': null, 'productId': scan.id},
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Score Circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    scan.nutritionScore.toStringAsFixed(1),
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scan.brand,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.formatDate(scan.scannedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB2BEC3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Status + Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scan.authenticityStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState(HistoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            controller.selectedFilter.value == 'All'
                ? 'No scans yet'
                : 'No ${controller.selectedFilter.value} products',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your scan history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB2BEC3),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.scan),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Scan a Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}