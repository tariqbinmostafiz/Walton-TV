import 'package:flutter/material.dart';

enum CustomSlotType {
  irCommand,
}

class CustomSlot {
  final int slotIndex; // 1 to 6
  final String defaultTitle;
  String title;
  int irCommand; // 0x00 to 0xFF
  String iconKey;
  final CustomSlotType type;
  final Color accentColor;

  static const Map<String, IconData> availableIcons = {
    'tv': Icons.live_tv_rounded,
    'youtube': Icons.play_arrow_rounded,
    'video': Icons.smart_display_rounded,
    'settings': Icons.settings_rounded,
    'send': Icons.near_me_rounded,
    'movie': Icons.movie_rounded,
    'play': Icons.play_circle_filled_rounded,
    'folder': Icons.folder_open_rounded,
    'star': Icons.star_rounded,
    'grid': Icons.grid_view_rounded,
    'home': Icons.home_rounded,
    'music': Icons.music_note_rounded,
    'remote': Icons.settings_remote_rounded,
    'apps': Icons.apps_rounded,
    'cast': Icons.cast_rounded,
    'bolt': Icons.bolt_rounded,
  };

  CustomSlot({
    required this.slotIndex,
    required this.defaultTitle,
    required this.title,
    required this.irCommand,
    required this.iconKey,
    this.type = CustomSlotType.irCommand,
    required this.accentColor,
  });

  IconData get icon => availableIcons[iconKey] ?? Icons.tune_rounded;

  bool get isAppAction => false;

  String get irHex => '0x${irCommand.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  String get fullFrameHex =>
      '00BC${irCommand.toRadixString(16).padLeft(2, '0').toUpperCase()}${(0xFF - irCommand).toRadixString(16).padLeft(2, '0').toUpperCase()}';

  static List<CustomSlot> createDefaultSlots() {
    return [
      // Slot 1: IP TV on Page 1 (Default IR 0x15)
      CustomSlot(
        slotIndex: 1,
        defaultTitle: 'IP TV',
        title: 'IP TV',
        irCommand: 0x15,
        iconKey: 'tv',
        accentColor: const Color(0xFF2979FF),
      ),
      // Slot 2: YouTube VIP on Page 1 (Default IR 0x41)
      CustomSlot(
        slotIndex: 2,
        defaultTitle: 'YouTube VIP',
        title: 'YouTube VIP',
        irCommand: 0x41,
        iconKey: 'youtube',
        accentColor: const Color(0xFFFF0000),
      ),
      // Slot 3: Video Player on Page 2 (Default IR 0x57)
      CustomSlot(
        slotIndex: 3,
        defaultTitle: 'Video Player',
        title: 'Video Player',
        irCommand: 0x57,
        iconKey: 'video',
        accentColor: const Color(0xFF1E88E5),
      ),
      // Slot 4: Settings on Page 2 (Default IR 0x5A)
      CustomSlot(
        slotIndex: 4,
        defaultTitle: 'Settings',
        title: 'Settings',
        irCommand: 0x5A,
        iconKey: 'settings',
        accentColor: const Color(0xFF455A64),
      ),
      // Slot 5: LocalSend on Page 2 (Default IR 0x5C)
      CustomSlot(
        slotIndex: 5,
        defaultTitle: 'LocalSend',
        title: 'LocalSend',
        irCommand: 0x5C,
        iconKey: 'send',
        accentColor: const Color(0xFF00B0FF),
      ),
      // Slot 6: Movie on Page 2 (Default IR 0x5D)
      CustomSlot(
        slotIndex: 6,
        defaultTitle: 'Movie',
        title: 'Movie',
        irCommand: 0x5D,
        iconKey: 'movie',
        accentColor: const Color(0xFFFF9800),
      ),
    ];
  }
}
