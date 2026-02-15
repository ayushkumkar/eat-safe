import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/api_service.dart';

class ScanController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;

  // TWO separate images now
  final frontImage = Rxn<File>();
  final backImage = Rxn<File>();

  // Track which side is ready
  bool get isFrontReady => frontImage.value != null;
  bool get isBackReady => backImage.value != null;
  bool get canAnalyze => isFrontReady && isBackReady;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  // Pick front image
  Future<void> pickFrontImage(ImageSource source) async {
    final file = await _pickImage(source);
    if (file != null) frontImage.value = file;
  }

  // Pick back image
  Future<void> pickBackImage(ImageSource source) async {
    final file = await _pickImage(source);
    if (file != null) backImage.value = file;
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.status;
        if (status.isDenied) await Permission.camera.request();
      }

      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (photo != null) return File(photo.path);
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not get image. Please try again.',
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Analyze both images
  Future<void> analyzeProduct() async {
    if (!canAnalyze) {
      Get.snackbar(
        'Missing Images',
        'Please add both front and back photos',
        backgroundColor: const Color(0xFFF39C12),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      Get.dialog(
        // ignore: deprecated_member_use
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: _ProcessingDialog()),
        ),
        barrierDismissible: false,
      );

      // Send BOTH images to backend
      // Front → brand/logo detection
      // Back → FSSAI + nutrition extraction
      final result = await _apiService.scanProduct(
        frontImage: frontImage.value!,
        backImage: backImage.value!,
      );

      Get.back();

      if (result != null) {
        Get.toNamed(
          AppRoutes.result,
          arguments: {
            'imagePath': backImage.value!.path,
            'apiResult': result,
          },
        );
      } else {
        Get.snackbar(
          'Analysis Failed',
          'Could not analyze the product. Please try again.',
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearImages() {
    frontImage.value = null;
    backImage.value = null;
  }
}

// Keep the _ProcessingDialog class exactly as it was before
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