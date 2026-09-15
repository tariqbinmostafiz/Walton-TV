import 'package:flutter/services.dart';
import 'settings_service.dart';

class HapticService {
  static void triggerButtonFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  static void triggerDpadFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  static void triggerOkFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  static void triggerPowerFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
    }
  }

  static void triggerCustomFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  static void triggerHeavyFeedback() {
    if (SettingsService().vibrationEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }
}
