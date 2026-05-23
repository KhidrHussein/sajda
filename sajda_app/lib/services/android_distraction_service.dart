import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/prayer.dart';
import 'database_service.dart';
import 'distraction_service.dart';
import 'platform_channel_service.dart';
import 'dart:io';

class AndroidDistractionService extends ChangeNotifier implements DistractionService {
  static final AndroidDistractionService _instance = AndroidDistractionService._internal();
  factory AndroidDistractionService() => _instance;
  AndroidDistractionService._internal();

  final DatabaseService _db = DatabaseService.instance;

  bool _isActive = false;
  Prayer? _currentPrayer;
  Timer? _lockTimer;
  int _remainingSeconds = 0;

  @override
  bool get isActive => _isActive;
  
  @override
  Prayer? get currentPrayer => _currentPrayer;
  
  @override
  int get remainingSeconds => _remainingSeconds;

  @override
  Future<void> init() async {
    // Initialization logic if any
  }

  @override
  bool isSupported() => Platform.isAndroid;

  @override
  Future<void> startDistractionControl(Prayer prayer) async {
    if (_isActive) return;

    final settings = await _db.getAppSettings();
    final lockDuration = settings?.lockDurationMinutes ?? 10;

    _isActive = true;
    _currentPrayer = prayer;
    _remainingSeconds = lockDuration * 60;

    // Trigger Native Overlay
    await PlatformChannelService.startLockOverlay(
      prayer.name.displayName,
      _remainingSeconds,
    );

    notifyListeners();

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        stopDistractionControl();
      }
    });
  }

  @override
  Future<void> stopDistractionControl() async {
    _lockTimer?.cancel();
    _lockTimer = null;
    _isActive = false;
    _currentPrayer = null;
    _remainingSeconds = 0;
    
    // Stop Native Overlay
    await PlatformChannelService.stopLockOverlay();
    
    notifyListeners();
  }

  String getFormattedTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
}
