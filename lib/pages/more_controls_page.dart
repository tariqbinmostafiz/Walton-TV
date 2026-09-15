import 'package:flutter/material.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/neumorphic_button.dart';
import 'settings_page.dart';
import 'video_player_page.dart';

class MoreControlsPage extends StatelessWidget {
  final VoidCallback onSwipeBack;

  const MoreControlsPage({
    super.key,
    required this.onSwipeBack,
  });

  void _sendCommand(BuildContext context, RemoteCommand cmd) {
    IrService().sendCommand(cmd.cmd, label: cmd.label);
  }

  void _sendCustom(BuildContext context, int slotIndex) {
    final settings = SettingsService();
    final slot = settings.customSlots.firstWhere(
      (s) => s.slotIndex == slotIndex,
      orElse: () => settings.customSlots[0],
    );
    IrService().sendCommand(slot.irCommand, label: slot.title);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return Scaffold(
      backgroundColor: RemoteColors.lightBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final slot3 = settings.customSlots[2]; // CUSTOM 5 on UI
            final slot4 = settings.customSlots[3]; // CUSTOM 6 on UI

            return Column(
              children: [
                // TOP HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      NeumorphicButton(
                        width: 44,
                        height: 44,
                        isCircle: true,
                        isDark: false,
                        padding: EdgeInsets.zero,
                        onPressed: onSwipeBack,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: RemoteColors.lightTextPrimary,
                          size: 18,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'More Controls',
                              style: TextStyle(
                                color: RemoteColors.lightTextPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Additional TV Functions',
                              style: TextStyle(
                                color: RemoteColors.lightTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 44), // Balances the back button
                    ],
                  ),
                ),

                // SCROLLABLE BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Column(
                      children: [
                        // ROW 1: Picture | Sound | Subtitle | Sleep (4 buttons)
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.image_outlined,
                              label: 'Picture',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.picture),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.volume_up_outlined,
                              label: 'Sound',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.sound),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.subtitles_outlined,
                              label: 'Subtitle',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.subtitle),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.bedtime_outlined,
                              label: 'Sleep',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.sleep),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ROW 2: Display | Menu | Exit (3 buttons)
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Display',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.display),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.menu_rounded,
                              label: 'Menu',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.menu),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.exit_to_app_rounded,
                              label: 'Exit',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.exit),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // NUMPAD GRID (1-9, Display, 0, Back/Recall)
                        _buildNumpadRow(['1', '2', '3'], [
                          WaltonCommands.num1,
                          WaltonCommands.num2,
                          WaltonCommands.num3,
                        ], context),
                        const SizedBox(height: 8),
                        _buildNumpadRow(['4', '5', '6'], [
                          WaltonCommands.num4,
                          WaltonCommands.num5,
                          WaltonCommands.num6,
                        ], context),
                        const SizedBox(height: 8),
                        _buildNumpadRow(['7', '8', '9'], [
                          WaltonCommands.num7,
                          WaltonCommands.num8,
                          WaltonCommands.num9,
                        ], context),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumpadSpecial(
                                label: 'Display',
                                onPressed: () =>
                                    _sendCommand(context, WaltonCommands.display),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildNumpadDigit(
                                digit: '0',
                                onPressed: () =>
                                    _sendCommand(context, WaltonCommands.num0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildNumpadSpecial(
                                label: 'Back / Recall',
                                onPressed: () =>
                                    _sendCommand(context, WaltonCommands.recallBack),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // INPUT SOURCES ROW: File Manager | HDMI | AV | VGA
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.usb_rounded,
                              label: 'File Manager',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.fileManager),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.settings_input_hdmi_rounded,
                              label: 'HDMI',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.hdmi),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.radio_button_checked_rounded,
                              label: 'AV',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.av),
                            ),
                            const SizedBox(width: 10),
                            _buildGridButton(
                              icon: Icons.monitor_rounded,
                              label: 'VGA',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.vga),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ACTION PILLS ROW 1: YouTube (sends 0x60 IR) | Video Player (Slot 5 app action)
                        Row(
                          children: [
                            // YouTube Button: Sends Walton IR 0x60! (Section 13 & 15)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () =>
                                    _sendCommand(context, WaltonCommands.youtube),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: RemoteColors.youtubeRed,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'YouTube',
                                      style: TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Video Player: App action / Custom Slot 5 (Section 10 & 15)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const VideoPlayerPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: RemoteColors.videoPlayerBlue,
                                      size: 24,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Video Player',
                                      style: TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ACTION PILLS ROW 2: CUSTOM 5 (Slot 3) | CUSTOM 6 (Slot 4)
                        Row(
                          children: [
                            // CUSTOM 5 (Custom Slot 3)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () => _sendCustom(context, 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot3.icon,
                                      color: slot3.accentColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slot3.title,
                                      style: const TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // CUSTOM 6 (Custom Slot 4)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () => _sendCustom(context, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot4.icon,
                                      color: slot4.accentColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slot4.title,
                                      style: const TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ACTION PILLS ROW 3: TV Settings (sends 0x90 IR) | Settings (Slot 6 app action)
                        Row(
                          children: [
                            // TV Settings: Walton TV IR Command 0x90! (Section 14)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () =>
                                    _sendCommand(context, WaltonCommands.tvSettings),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.settings_outlined,
                                      color: Color(0xFF37474F),
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'TV Settings',
                                      style: TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // App Settings: Local Flutter Settings / Custom Slot 6 (Section 14 & 16)
                            Expanded(
                              child: NeumorphicButton(
                                height: 52,
                                isDark: false,
                                borderRadius: 16,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.settings_suggest_rounded,
                                      color: Color(0xFF37474F),
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        color: RemoteColors.lightTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // BOTTOM PAGE INDICATOR & SWIPE BACK HINT
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSwipeBack,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dots (Page 2 active)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: RemoteColors.lightTextSecondary.withAlpha(80),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: RemoteColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Swipe back for main controls',
                              style: TextStyle(
                                color: RemoteColors.lightTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_back_rounded,
                              color: RemoteColors.lightTextSecondary,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: NeumorphicButton(
        height: 66,
        isDark: false,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: RemoteColors.lightTextPrimary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: RemoteColors.lightTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(
    List<String> digits,
    List<RemoteCommand> commands,
    BuildContext context,
  ) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Expanded(
            child: _buildNumpadDigit(
              digit: digits[i],
              onPressed: () => _sendCommand(context, commands[i]),
            ),
          ),
          if (i < 2) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildNumpadDigit({
    required String digit,
    required VoidCallback onPressed,
  }) {
    return NeumorphicButton(
      height: 48,
      isDark: false,
      borderRadius: 14,
      onPressed: onPressed,
      child: Text(
        digit,
        style: const TextStyle(
          color: RemoteColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNumpadSpecial({
    required String label,
    required VoidCallback onPressed,
  }) {
    return NeumorphicButton(
      height: 48,
      isDark: false,
      borderRadius: 14,
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: RemoteColors.lightTextPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
