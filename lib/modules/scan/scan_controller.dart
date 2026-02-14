import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app/routes/app_routes.dart';

class ScanController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final isLoading = false.obs;
  final selectedImage = Rxn<File>();

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  // Pick from Camera
  Future<void> scanWithCamera() async {
    try {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        await Permission.camera.request();
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
        _processImage();
      }
    } catch (e) {
      Get.snackbar(
        'Camera Error',
        'Could not open camera. Please try again.',
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Pick from Gallery
  Future<void> scanFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        _processImage();
      }
    } catch (e) {
      Get.snackbar(
        'Gallery Error',
        'Could not open gallery. Please try again.',
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Process the image and navigate to result
  Future<void> _processImage() async {
    try {
      isLoading.value = true;

      // Show processing dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: _ProcessingDialog(),
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate processing delay (replace with real API call later)
      await Future.delayed(const Duration(seconds: 3));

      // Close dialog
      Get.back();

      // Navigate to result screen with image path
      Get.toNamed(
        AppRoutes.result,
        arguments: {'imagePath': selectedImage.value!.path},
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Processing Error',
        'Could not process image. Please try again.',
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// Processing Dialog Widget
class _ProcessingDialog extends StatefulWidget {
  const _ProcessingDialog();

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int _stepIndex = 0;

  final List<String> _steps = [
    'Reading product label...',
    'Verifying FSSAI number...',
    'Checking brand authenticity...',
    'Analyzing nutrition data...',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.6, end: 1.0).animate(_animController);

    // Cycle through steps
    _cycleSteps();
  }

  void _cycleSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 750));
      if (mounted) setState(() => _stepIndex = i);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Icon
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Color(0xFF2ECC71),
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyzing Product',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _steps[_stepIndex],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            color: Color(0xFF2ECC71),
            backgroundColor: Color(0xFFD5F5E3),
          ),
        ],
      ),
    );
  }
}