import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.x:8000/api/v1';
  // ☝️ Replace with your actual IP

  final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Now accepts BOTH front and back images
  Future<Map<String, dynamic>?> scanProduct({
    required File frontImage,
    required File backImage,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        'front': await dio.MultipartFile.fromFile(
          frontImage.path,
          filename: 'front.jpg',
        ),
        'back': await dio.MultipartFile.fromFile(
          backImage.path,
          filename: 'back.jpg',
        ),
      });

      final response = await _dio.post('/scan', data: formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on dio.DioException catch (e) {
      String message = 'Server error. Please try again.';
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Check your network.';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        message = 'Cannot connect to server. Make sure backend is running.';
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
      return null;
    }
  }
}