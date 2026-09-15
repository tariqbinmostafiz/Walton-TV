import 'package:flutter/material.dart';

enum CustomSlotType {
  irCommand,
}

class CustomSlot {
  final int slotIndex; // 1 to 6
  final String defaultTitle;
  String title;
  int irCommand; // 0x00 to 0xFF
  IconData icon;
  final CustomSlotType type;
  final Color accentColor;

  CustomSlot({
    required this.slotIndex,
    required this.defaultTitle,
    required this.title,
    required this.irCommand,
    required this.icon,
    this.type = CustomSlotType.irCommand,
    required this.accentColor,
  });

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
        icon: Icons.live_tv_rounded,
        accentColor: const Color(0xFF2979FF),
      ),
      // Slot 2: YouTube VIP on Page 1 (Default IR 0x41)
      CustomSlot(
        slotIndex: 2,
        defaultTitle: 'YouTube VIP',
        title: 'YouTube VIP',
        irCommand: 0x41,
        icon: Icons.play_arrow_rounded,
        accentColor: const Color(0xFFFF0000),
      ),
      // Slot 3: Video Player on Page 2 (Default IR 0x57)
      CustomSlot(
        slotIndex: 3,
        defaultTitle: 'Video Player',
        title: 'Video Player',
        irCommand: 0x57,
        icon: Icons.smart_display_rounded,
        accentColor: const Color(0xFF1E88E5),
      ),
      // Slot 4: Settings on Page 2 (Default IR 0x5A)
      CustomSlot(
        slotIndex: 4,
        defaultTitle: 'Settings',
        title: 'Settings',
        irCommand: 0x5A,
        icon: Icons.settings_rounded,
        accentColor: const Color(0xFF455A64),
      ),
      // Slot 5: LocalSend on Page 2 (Default IR 0x5C)
      CustomSlot(
        slotIndex: 5,
        defaultTitle: 'LocalSend',
        title: 'LocalSend',
        irCommand: 0x5C,
        icon: Icons.near_me_rounded,
        accentColor: const Color(0xFF00B0FF),
      ),
      // Slot 6: Movie on Page 2 (Default IR 0x5D)
      CustomSlot(
        slotIndex: 6,
        defaultTitle: 'Movie',
        title: 'Movie',
        irCommand: 0x5D,
        icon: Icons.movie_rounded,
        accentColor: const Color(0xFFFF9800),
      ),
    ];
  }
}
