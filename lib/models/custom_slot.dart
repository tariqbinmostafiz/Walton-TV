import 'package:flutter/material.dart';

enum CustomSlotType {
  irCommand,
  videoPlayer,
  appSettings,
}

class CustomSlot {
  final int slotIndex; // 1 to 6
  final String defaultTitle;
  String title;
  int irCommand; // e.g. 0x15, 0x41, 0x57, 0x5A, 0x5C, 0x5D, 0x5E
  IconData icon;
  final CustomSlotType type;
  final Color accentColor;

  CustomSlot({
    required this.slotIndex,
    required this.defaultTitle,
    required this.title,
    required this.irCommand,
    required this.icon,
    required this.type,
    required this.accentColor,
  });

  bool get isAppAction =>
      type == CustomSlotType.videoPlayer || type == CustomSlotType.appSettings;

  String get irHex => '0x${irCommand.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  static List<CustomSlot> createDefaultSlots() {
    return [
      // Slot 1: Generic Custom 1 on Page 1
      CustomSlot(
        slotIndex: 1,
        defaultTitle: 'CUSTOM 1',
        title: 'CUSTOM 1',
        irCommand: 0x15,
        icon: Icons.grid_view_rounded,
        type: CustomSlotType.irCommand,
        accentColor: const Color(0xFF2979FF),
      ),
      // Slot 2: Generic Custom 2 on Page 1
      CustomSlot(
        slotIndex: 2,
        defaultTitle: 'CUSTOM 2',
        title: 'CUSTOM 2',
        irCommand: 0x41,
        icon: Icons.star_rounded,
        type: CustomSlotType.irCommand,
        accentColor: const Color(0xFFAB47BC),
      ),
      // Slot 3: Generic Custom 3 (labeled CUSTOM 5 on Page 2 to match design)
      CustomSlot(
        slotIndex: 3,
        defaultTitle: 'CUSTOM 5',
        title: 'CUSTOM 5',
        irCommand: 0x57,
        icon: Icons.apps_rounded,
        type: CustomSlotType.irCommand,
        accentColor: const Color(0xFF4CAF50),
      ),
      // Slot 4: Generic Custom 4 (labeled CUSTOM 6 on Page 2 to match design)
      CustomSlot(
        slotIndex: 4,
        defaultTitle: 'CUSTOM 6',
        title: 'CUSTOM 6',
        irCommand: 0x5A,
        icon: Icons.star_rounded,
        type: CustomSlotType.irCommand,
        accentColor: const Color(0xFFFF9800),
      ),
      // Slot 5: In-App Video Player action (Section 10 & 15)
      CustomSlot(
        slotIndex: 5,
        defaultTitle: 'Video Player',
        title: 'Video Player',
        irCommand: 0x00,
        icon: Icons.play_arrow_rounded,
        type: CustomSlotType.videoPlayer,
        accentColor: const Color(0xFF1E88E5),
      ),
      // Slot 6: App Settings action (Section 10 & 14)
      CustomSlot(
        slotIndex: 6,
        defaultTitle: 'Settings',
        title: 'Settings',
        irCommand: 0x00,
        icon: Icons.settings_rounded,
        type: CustomSlotType.appSettings,
        accentColor: const Color(0xFF455A64),
      ),
    ];
  }
}
