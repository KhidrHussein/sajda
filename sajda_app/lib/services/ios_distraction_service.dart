import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/prayer.dart';
import 'distraction_service.dart';
import 'dart:io';

class IOSDistractionService extends ChangeNotifier implements DistractionService {
  static final IOSDistractionService _instance = IOSDistractionService._internal();
  factory IOSDistractionService() => _instance;
  IOSDistractionService._internal();

  static const MethodChannel _iosChannel = MethodChannel('com.sajda.sajda_app/ios_restriction');

  bool _isActive = false;
  Prayer? _currentPrayer;
  final int _remainingSeconds = 0;

  @override
  bool get isActive => _isActive;
  
  @override
  Prayer? get currentPrayer => _currentPrayer;
  
  @override
  int get remainingSeconds => _remainingSeconds;

  @override
  Future<void> init() async {
    try {
      await _iosChannel.invokeMethod('requestAuthorization');
    } on PlatformException catch (e) {
      debugPrint('Error requesting iOS authorization: $e');
    }
  }

  @override
  bool isSupported() => Platform.isIOS;

  @override
  Future<void> startDistractionControl(Prayer prayer) async {
    _isActive = true;
    _currentPrayer = prayer;
    notifyListeners();
    
    // On iOS, this might trigger a local notification or update state
    // Real blocking is handled by system schedules
  }

  @override
  Future<void> stopDistractionControl() async {
    _isActive = false;
    _currentPrayer = null;
    notifyListeners();
  }
  
  // iOS Specific: Trigger App Picker
  Future<void> selectAppsToBlock() async {
    try {
      await _iosChannel.invokeMethod('showFamilyPicker');
    } on PlatformException catch (e) {
      debugPrint('Error showing family picker: $e');
    }
  }
}
