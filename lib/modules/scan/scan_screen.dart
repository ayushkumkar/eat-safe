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
              'Clear All',
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
            // Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2ECC71), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Take 4 separate photos for accurate analysis',
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1 — Logo
            _buildPhotoSection(
              controller: controller,
              step: '1',
              type: 'logo',
              title: 'Brand Logo & Name',
              subtitle: 'Front package with brand logo',
              icon: Icons.branding_watermark_rounded,
              color: const Color(0xFF3498DB),
              imageObs: controller.logoImage,
            ),

            const SizedBox(height: 14),

            // Step 2 — FSSAI
            _buildPhotoSection(
              controller: controller,
              step: '2',
              type: 'fssai',
              title: 'FSSAI License Number',
              subtitle: 'Photo showing FSSAI code clearly',
              icon: Icons.verified_rounded,
              color: const Color(0xFF9B59B6),
              imageObs: controller.fssaiImage,
            ),

            const SizedBox(height: 14),

            // Step 3 — Nutrition
            _buildPhotoSection(
              controller: controller,
              step: '3',
              type: 'nutrition',
              title: 'Nutrition Facts Table',
              subtitle: 'Calories, protein, fat, sodium, etc.',
              icon: Icons.article_rounded,
              color: const Color(0xFFF39C12),
              imageObs: controller.nutritionImage,
            ),

            const SizedBox(height: 14),

            // Step 4 — Ingredients
            _buildPhotoSection(
              controller: controller,
              step: '4',
              type: 'ingredients',
              title: 'Ingredient List',
              subtitle: 'All ingredients & preservatives',
              icon: Icons.list_alt_rounded,
              color: const Color(0xFFE74C3C),
              imageObs: controller.ingredientsImage,
            ),

            const SizedBox(height: 24),

            // Analyze Button
            Obx(() => GestureDetector(
                  onTap: controller.canAnalyze
                      ? controller.analyzeProduct
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: controller.canAnalyze
                          ? const LinearGradient(
                              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
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
                          Icons.analytics_rounded,
                          color: controller.canAnalyze
                              ? Colors.white
                              : const Color(0xFFB2BEC3),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          controller.canAnalyze
                              ? 'Analyze Product'
                              : 'Add all 4 photos',
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

            const SizedBox(height: 20),

            // Progress Indicator
            Obx(() => _buildProgress(controller)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required ScanController controller,
    required String step,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Rxn<File> imageObs,
  }) {
    return Container(
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
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => imageObs.value != null
                  ? const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20)
                  : const SizedBox()),
            ],
          ),

          const SizedBox(height: 12),

          // Image Preview
          Obx(() => imageObs.value != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        imageObs.value!,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(type, ImageSource.camera),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 28, color: color.withOpacity(0.5)),
                      const SizedBox(height: 6),
                      Text(
                        'No photo yet',
                        style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 10),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.pickImage(type, ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.pickImage(type, ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, color: Color(0xFF7F8C8D), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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

  Widget _buildProgress(ScanController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildProgressDot('1', controller.isLogoReady),
        const Expanded(child: Divider()),
        _buildProgressDot('2', controller.isFssaiReady),
        const Expanded(child: Divider()),
        _buildProgressDot('3', controller.isNutritionReady),
        const Expanded(child: Divider()),
        _buildProgressDot('4', controller.isIngredientsReady),
      ],
    );
  }

  Widget _buildProgressDot(String num, bool done) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done ? const Color(0xFF2ECC71) : const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : Text(
                num,
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}