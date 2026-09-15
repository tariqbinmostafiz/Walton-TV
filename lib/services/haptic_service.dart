import 'package:flutter/services.dart';
import 'settings_service.dart';

class HapticService {
  static void triggerButtonFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {
        // Safe ignore on unsupported platforms
      }
    }
  }

  static void triggerHeavyFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {
        // Safe ignore
      }
    }
  }
}
