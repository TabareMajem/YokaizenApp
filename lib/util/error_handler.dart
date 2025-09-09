import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/colors.dart';

/// Comprehensive error handling utility for the app
/// Provides user-friendly error messages and recovery suggestions
class ErrorHandler {
  
  /// Handle API errors with user-friendly messages
  static String handleApiError(dynamic error) {
    if (error is SocketException) {
      return 'connection_error'.tr;
    } else if (error is HttpException) {
      return 'server_error'.tr;
    } else if (error is FormatException) {
      return 'data_format_error'.tr;
    } else if (error.toString().contains('timeout')) {
      return 'timeout_error'.tr;
    } else if (error.toString().contains('404')) {
      return 'not_found_error'.tr;
    } else if (error.toString().contains('500')) {
      return 'server_internal_error'.tr;
    } else if (error.toString().contains('401') || error.toString().contains('403')) {
      return 'authentication_error'.tr;
    } else {
      return 'generic_error'.tr;
    }
  }

  /// Check network connectivity
  static Future<bool> hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Show error snackbar with retry option
  static void showErrorSnackbar({
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      'Error'.tr,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: () {
                Get.back(); // Close snackbar
                onRetry();
              },
              child: Text(
                'Retry'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success'.tr,
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning'.tr,
      message,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.warning_outlined,
        color: Colors.white,
      ),
    );
  }

  /// Show offline indicator
  static void showOfflineIndicator() {
    Get.snackbar(
      'Offline'.tr,
      'no_internet_connection'.tr,
      backgroundColor: Colors.grey.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.wifi_off,
        color: Colors.white,
      ),
    );
  }

  /// Show back online indicator
  static void showOnlineIndicator() {
    Get.snackbar(
      'Back Online'.tr,
      'internet_connection_restored'.tr,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.wifi,
        color: Colors.white,
      ),
    );
  }

  /// Show loading state with message
  static void showLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(coral500),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Show confirmation dialog with retry option
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = coral500,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Handle cache errors
  static String handleCacheError(dynamic error) {
    if (error.toString().contains('storage')) {
      return 'storage_error'.tr;
    } else if (error.toString().contains('permission')) {
      return 'permission_error'.tr;
    } else {
      return 'cache_error'.tr;
    }
  }

  /// Log error for debugging (only in debug mode)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    if (debugMode) {
      customPrint('❌ ERROR in $context: $error');
      if (stackTrace != null) {
        customPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  /// Get user-friendly error message based on error type
  static String getUserFriendlyMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'The request took too long. Please try again.';
    } else if (errorString.contains('server') || errorString.contains('http')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (errorString.contains('format') || errorString.contains('parse')) {
      return 'There was a problem processing the data. Please try again.';
    } else if (errorString.contains('authentication') || errorString.contains('auth')) {
      return 'Please log in again to continue.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Show error dialog with detailed information
  static void showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Get.back();
                onCancel();
              },
              child: Text(
                'Cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: coral500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (onRetry == null && onCancel == null)
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'.tr),
            ),
        ],
      ),
    );
  }
} 