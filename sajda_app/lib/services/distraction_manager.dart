import 'dart:io';
import 'distraction_service.dart';
import 'android_distraction_service.dart';
import 'ios_distraction_service.dart';

class DistractionManager {
  static DistractionService get instance {
    if (Platform.isAndroid) {
      return AndroidDistractionService();
    } else if (Platform.isIOS) {
      return IOSDistractionService();
    } else {
      throw UnsupportedError('Distraction control is only supported on Android and iOS');
    }
  }
}
