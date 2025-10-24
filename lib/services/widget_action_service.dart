import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../screens/quick_camera_screen.dart';

class WidgetActionService {
  static const platform = MethodChannel('com.nutrifit.ai/widget_actions');
  static final WidgetActionService _instance = WidgetActionService._internal();
  factory WidgetActionService() => _instance;
  WidgetActionService._internal();

  BuildContext? _context;

  void initialize(BuildContext context) {
    _context = context;

    // Set up method call handler for widget actions
    platform.setMethodCallHandler(_handleMethodCall);

    // Check for initial widget click
    _checkInitialWidgetClick();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'openQuickCamera':
        _openQuickCamera();
        break;
    }
  }

  Future<void> _checkInitialWidgetClick() async {
    try {
      final bool shouldOpenCamera = await platform.invokeMethod(
        'checkWidgetClick',
      );
      if (shouldOpenCamera) {
        // Delay to ensure app is fully loaded
        Future.delayed(const Duration(milliseconds: 500), () {
          _openQuickCamera();
        });
      }
    } catch (e) {
      print('Error checking widget click: $e');
    }
  }

  void _openQuickCamera() {
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => QuickCameraScreen(
            selectedDate: DateTime.now(),
            onSaveSuccess: () {
              // Return to previous screen after saving
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }
}
