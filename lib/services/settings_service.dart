import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_slot.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  ThemeMode _themeMode = ThemeMode.system;
  bool _vibrationEnabled = true;
  List<CustomSlot> _customSlots = CustomSlot.createDefaultSlots();
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;
  List<CustomSlot> get customSlots => _customSlots;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

      // Load theme mode ('dark', 'light', 'system')
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }

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

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String val = mode == ThemeMode.dark
          ? 'dark'
          : (mode == ThemeMode.light ? 'light' : 'system');
      await prefs.setString('theme_mode', val);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
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

  /// Exports the current configuration as a JSON string
  String exportConfigJson() {
    final Map<String, dynamic> slotsMap = {};
    for (final slot in _customSlots) {
      slotsMap[slot.slotIndex.toString()] = {
        'title': slot.title,
        'cmd': slot.irCommand.toRadixString(16).padLeft(2, '0').toUpperCase(),
      };
    }

    final data = {
      'schema': 'walton_tv_remote_config',
      'version': 1,
      'themeMode': _themeMode == ThemeMode.dark
          ? 'dark'
          : (_themeMode == ThemeMode.light ? 'light' : 'system'),
      'vibrationEnabled': _vibrationEnabled,
      'customSlots': slotsMap,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Imports configuration from JSON text. Returns null on success or error string on failure.
  Future<String?> importConfigJson(String jsonStr) async {
    try {
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        return 'Invalid format: Root must be a JSON object';
      }

      if (decoded['schema'] != 'walton_tv_remote_config') {
        return 'Unsupported configuration schema';
      }

      final prefs = await SharedPreferences.getInstance();

      // Theme
      if (decoded.containsKey('themeMode')) {
        final t = decoded['themeMode'];
        if (t == 'dark') {
          _themeMode = ThemeMode.dark;
          await prefs.setString('theme_mode', 'dark');
        } else if (t == 'light') {
          _themeMode = ThemeMode.light;
          await prefs.setString('theme_mode', 'light');
        } else if (t == 'system') {
          _themeMode = ThemeMode.system;
          await prefs.setString('theme_mode', 'system');
        }
      }

      // Vibration
      if (decoded.containsKey('vibrationEnabled') && decoded['vibrationEnabled'] is bool) {
        _vibrationEnabled = decoded['vibrationEnabled'] as bool;
        await prefs.setBool('vibration_enabled', _vibrationEnabled);
      }

      // Custom slots
      if (decoded.containsKey('customSlots') && decoded['customSlots'] is Map) {
        final slotsMap = decoded['customSlots'] as Map;
        for (int i = 1; i <= 6; i++) {
          final slotData = slotsMap[i.toString()];
          if (slotData != null) {
            String? title;
            int? cmd;

            if (slotData is Map) {
              title = slotData['title']?.toString();
              final rawCmd = slotData['cmd']?.toString();
              if (rawCmd != null) {
                final cleanHex = rawCmd.startsWith('0x') || rawCmd.startsWith('0X')
                    ? rawCmd.substring(2)
                    : rawCmd;
                cmd = int.tryParse(cleanHex, radix: 16);
              }
            } else if (slotData is String) {
              // Shorthand hex
              final cleanHex = slotData.startsWith('0x') || slotData.startsWith('0X')
                  ? slotData.substring(2)
                  : slotData;
              cmd = int.tryParse(cleanHex, radix: 16);
            } else if (slotData is int) {
              cmd = slotData;
            }

            final slotIndex = _customSlots.indexWhere((s) => s.slotIndex == i);
            if (slotIndex != -1) {
              if (title != null && title.trim().isNotEmpty) {
                _customSlots[slotIndex].title = title.trim();
                await prefs.setString('custom_slot_${i}_title', title.trim());
              }
              if (cmd != null && cmd >= 0 && cmd <= 0xFF) {
                _customSlots[slotIndex].irCommand = cmd;
                await prefs.setInt('custom_slot_${i}_cmd', cmd);
              }
            }
          }
        }
      }

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Import failed: ${e.toString()}';
    }
  }
}
