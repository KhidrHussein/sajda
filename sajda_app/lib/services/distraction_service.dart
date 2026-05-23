import '../models/prayer.dart';

abstract class DistractionService {
  bool get isActive;
  Prayer? get currentPrayer;
  int get remainingSeconds;

  Future<void> init();
  Future<void> startDistractionControl(Prayer prayer);
  Future<void> stopDistractionControl();
  
  // Platform specific capability check
  bool isSupported();
  
  // For UI updates
  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}
