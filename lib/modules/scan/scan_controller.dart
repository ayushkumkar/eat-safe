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

  // FOUR images now
  final logoImage = Rxn<File>();
  final fssaiImage = Rxn<File>();
  final nutritionImage = Rxn<File>();
  final ingredientsImage = Rxn<File>();

  bool get isLogoReady => logoImage.value != null;
  bool get isFssaiReady => fssaiImage.value != null;
  bool get isNutritionReady => nutritionImage.value != null;
  bool get isIngredientsReady => ingredientsImage.value != null;
  bool get canAnalyze => isLogoReady && isFssaiReady && isNutritionReady && isIngredientsReady;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> pickImage(String type, ImageSource source) async {
    final file = await _pickImage(source);
    if (file != null) {
      switch (type) {
        case 'logo':
          logoImage.value = file;
          break;
        case 'fssai':
          fssaiImage.value = file;
          break;
        case 'nutrition':
          nutritionImage.value = file;
          break;
        case 'ingredients':
          ingredientsImage.value = file;
          break;
      }
    }
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

  Future<void> analyzeProduct() async {
    if (!canAnalyze) {
      Get.snackbar(
        'Missing Images',
        'Please add all 4 photos',
        backgroundColor: const Color(0xFFF39C12),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: _ProcessingDialog()),
        ),
        barrierDismissible: false,
      );

      final result = await _apiService.scanProduct(
        logoImage: logoImage.value!,
        fssaiImage: fssaiImage.value!,
        nutritionImage: nutritionImage.value!,
        ingredientsImage: ingredientsImage.value!,
      );

      Get.back();

      if (result != null) {
        Get.toNamed(
          AppRoutes.result,
          arguments: {
            'imagePath': nutritionImage.value!.path,
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
    logoImage.value = null;
    fssaiImage.value = null;
    nutritionImage.value = null;
    ingredientsImage.value = null;
  }
}

// Keep _ProcessingDialog same as before
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
    'Reading product labels...',
    'Verifying FSSAI number...',
    'Analyzing nutrition data...',
    'Checking ingredients...',
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