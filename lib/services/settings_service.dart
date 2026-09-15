import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_slot.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  bool _vibrationEnabled = true;
  List<CustomSlot> _customSlots = CustomSlot.createDefaultSlots();
  bool _isLoaded = false;

  bool get vibrationEnabled => _vibrationEnabled;
  List<CustomSlot> get customSlots => _customSlots;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

      // Load custom slot overrides for all 6 slots
      for (int i = 0; i < _customSlots.length; i++) {
        final slot = _customSlots[i];
        final savedTitle = prefs.getString('custom_slot_${slot.slotIndex}_title');
        final savedCmd = prefs.getInt('custom_slot_${slot.slotIndex}_cmd');
        if (savedTitle != null && savedTitle.isNotEmpty) {
          slot.title = savedTitle;
        }
        if (savedCmd != null && savedCmd >= 0 && savedCmd <= 0xFF) {
          slot.irCommand = savedCmd;
        }
      }
    } catch (e) {
      debugPrint('Error loading settings from SharedPreferences: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vibration_enabled', enabled);
    } catch (e) {
      debugPrint('Error saving vibration setting: $e');
    }
  }

  Future<void> updateCustomSlot(int slotIndex, {required String title, required int irCommand}) async {
    final index = _customSlots.indexWhere((s) => s.slotIndex == slotIndex);
    if (index != -1) {
      _customSlots[index].title = title;
      _customSlots[index].irCommand = irCommand;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_slot_${slotIndex}_title', title);
        await prefs.setInt('custom_slot_${slotIndex}_cmd', irCommand);
      } catch (e) {
        debugPrint('Error saving custom slot: $e');
      }
    }
  }

  Future<void> resetCustomSlotsToDefault() async {
    _customSlots = CustomSlot.createDefaultSlots();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (int i = 1; i <= 6; i++) {
        await prefs.remove('custom_slot_${i}_title');
        await prefs.remove('custom_slot_${i}_cmd');
      }
    } catch (e) {
      debugPrint('Error resetting custom slots: $e');
    }
  }
}
