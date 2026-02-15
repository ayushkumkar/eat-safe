import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanController controller = Get.put(ScanController());

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
          'Scan Product',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.clearImages,
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Take 2 photos — front for logo/brand, back for FSSAI & nutrition info',
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Step 1: Front Image ──
            _buildImageSection(
              controller: controller,
              title: 'Step 1 — Front of Package',
              subtitle: 'Shows brand name & logo',
              icon: Icons.branding_watermark_rounded,
              color: const Color(0xFF3498DB),
              imageObs: controller.frontImage,
              onCamera: () =>
                  controller.pickFrontImage(ImageSource.camera),
              onGallery: () =>
                  controller.pickFrontImage(ImageSource.gallery),
            ),

            const SizedBox(height: 20),

            // ── Step 2: Back Image ──
            _buildImageSection(
              controller: controller,
              title: 'Step 2 — Back of Package',
              subtitle: 'Shows FSSAI number & nutrition table',
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF9B59B6),
              imageObs: controller.backImage,
              onCamera: () =>
                  controller.pickBackImage(ImageSource.camera),
              onGallery: () =>
                  controller.pickBackImage(ImageSource.gallery),
            ),

            const SizedBox(height: 28),

            // ── Analyze Button ──
            Obx(() => GestureDetector(
                  onTap: controller.canAnalyze
                      ? controller.analyzeProduct
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: controller.canAnalyze
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF2ECC71),
                                Color(0xFF27AE60)
                              ],
                            )
                          : null,
                      color: controller.canAnalyze
                          ? null
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: controller.canAnalyze
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2ECC71)
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_rounded,
                          color: controller.canAnalyze
                              ? Colors.white
                              : const Color(0xFFB2BEC3),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          controller.canAnalyze
                              ? 'Analyze Product'
                              : 'Add both photos to analyze',
                          style: TextStyle(
                            color: controller.canAnalyze
                                ? Colors.white
                                : const Color(0xFFB2BEC3),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            // ── Progress Indicator ──
            Obx(() => _buildProgressRow(controller)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required ScanController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Rxn<File> imageObs,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark if image is added
              Obx(() => imageObs.value != null
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2ECC71),
                      size: 24,
                    )
                  : const SizedBox()),
            ],
          ),

          const SizedBox(height: 16),

          // Image Preview or Placeholder
          Obx(() => imageObs.value != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageObs.value!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onCamera,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No photo added yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB2BEC3),
                        ),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 14),

          // Camera + Gallery Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            color: color, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onGallery,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_rounded,
                            color: Color(0xFF7F8C8D), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(ScanController controller) {
    return Row(
      children: [
        _buildProgressStep(
          number: '1',
          label: 'Front Photo',
          isDone: controller.isFrontReady,
          isActive: !controller.isFrontReady,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: controller.isFrontReady
                ? const Color(0xFF2ECC71)
                : const Color(0xFFE0E0E0),
          ),
        ),
        _buildProgressStep(
          number: '2',
          label: 'Back Photo',
          isDone: controller.isBackReady,
          isActive: controller.isFrontReady && !controller.isBackReady,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: controller.isBackReady
                ? const Color(0xFF2ECC71)
                : const Color(0xFFE0E0E0),
          ),
        ),
        _buildProgressStep(
          number: '3',
          label: 'Analyze',
          isDone: false,
          isActive: controller.canAnalyze,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF2ECC71)
                : isActive
                    ? const Color(0xFF2ECC71).withOpacity(0.2)
                    : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }
}