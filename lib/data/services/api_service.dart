import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseUrl = 'https://sealable-valorie-unexcused.ngrok-free.dev/api/v1';
  // Replace with your actual ngrok URL

  final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 90),
    receiveTimeout: const Duration(seconds: 90),
    headers: {
      'ngrok-skip-browser-warning': 'true',
    },
  ));

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Now accepts 4 images
  Future<Map<String, dynamic>?> scanProduct({
    required File logoImage,
    required File fssaiImage,
    required File nutritionImage,
    required File ingredientsImage,
  }) async {
    try {
      print('🚀 Sending 4 images to backend...');

      final formData = dio.FormData.fromMap({
        'logo': await dio.MultipartFile.fromFile(
          logoImage.path,
          filename: 'logo.jpg',
        ),
        'fssai': await dio.MultipartFile.fromFile(
          fssaiImage.path,
          filename: 'fssai.jpg',
        ),
        'nutrition': await dio.MultipartFile.fromFile(
          nutritionImage.path,
          filename: 'nutrition.jpg',
        ),
        'ingredients': await dio.MultipartFile.fromFile(
          ingredientsImage.path,
          filename: 'ingredients.jpg',
        ),
      });

      print('📤 Uploading...');
      final response = await _dio.post('/scan', data: formData);
      print('✅ Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on dio.DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Message: ${e.message}');

      String message = 'Server error. Please try again.';
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Check your network.';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        message = 'Cannot connect to server.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        message = 'Analysis took too long. Try again.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        message = 'Server error: ${e.response?.statusCode}';
      }
      Get.snackbar(
        'API Error',
        message,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      print('❌ Unknown error: $e');
      return null;
    }
  }
}