import 'package:flutter/material.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ir_indicator.dart';
import '../widgets/neumorphic_button.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? RemoteColors.darkBackground : RemoteColors.lightBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final slot3 = settings.customSlots[2]; // Video Player (Custom Slot 3)
            final slot4 = settings.customSlots[3]; // Settings (Custom Slot 4)
            final slot5 = settings.customSlots[4]; // LocalSend (Custom Slot 5)
            final slot6 = settings.customSlots[5]; // Movie (Custom Slot 6)

            return Column(
              children: [
                // TOP PHYSICAL IR EMITTER DIODE
                IrIndicatorBar(isDark: isDark),

                // TOP HEADER: Back button, Title, Balanced spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeumorphicButton(
                        width: 40,
                        height: 40,
                        isCircle: true,
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        onPressed: onSwipeBack,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                          size: 16,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'More Controls',
                            style: TextStyle(
                              color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Additional TV Functions',
                            style: TextStyle(
                              color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // Balances the back button
                    ],
                  ),
                ),

                // BODY: 100% FIXED GRID, NO VERTICAL SCROLLING
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // SECTION 1: Picture | Sound | Subtitle | Sleep (4 buttons)
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.image_outlined,
                              label: 'Picture',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.picture),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.volume_up_outlined,
                              label: 'Sound',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.sound),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.subtitles_outlined,
                              label: 'Subtitle',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.subtitle),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.bedtime_outlined,
                              label: 'Sleep',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.sleep),
                            ),
                          ],
                        ),

                        // SECTION 2: Display | Menu | Exit (3 buttons)
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Display',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.display),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.menu_rounded,
                              label: 'Menu',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.menu),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.exit_to_app_rounded,
                              label: 'Exit',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.exit),
                            ),
                          ],
                        ),

                        // SECTION 3: NUMPAD GRID (1-9, Display, 0, Back/Recall)
                        _buildNumpadRow(
                          ['1', '2', '3'],
                          [WaltonCommands.num1, WaltonCommands.num2, WaltonCommands.num3],
                          context,
                          isDark,
                        ),
                        _buildNumpadRow(
                          ['4', '5', '6'],
                          [WaltonCommands.num4, WaltonCommands.num5, WaltonCommands.num6],
                          context,
                          isDark,
                        ),
                        _buildNumpadRow(
                          ['7', '8', '9'],
                          [WaltonCommands.num7, WaltonCommands.num8, WaltonCommands.num9],
                          context,
                          isDark,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumpadSpecial(
                                label: 'Display',
                                isDark: isDark,
                                onPressed: () => _sendCommand(context, WaltonCommands.display),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildNumpadDigit(
                                digit: '0',
                                isDark: isDark,
                                onPressed: () => _sendCommand(context, WaltonCommands.num0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildNumpadSpecial(
                                label: 'Back',
                                isDark: isDark,
                                onPressed: () => _sendCommand(context, WaltonCommands.recallBack),
                              ),
                            ),
                          ],
                        ),

                        // SECTION 4: INPUT SOURCES (File Manager | HDMI | AV | VGA)
                        Row(
                          children: [
                            _buildGridButton(
                              icon: Icons.folder_open_rounded,
                              label: 'File Mgr',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.fileManager),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.settings_input_hdmi_rounded,
                              label: 'HDMI',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.hdmi),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.radio_button_checked_rounded,
                              label: 'AV',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.av),
                            ),
                            const SizedBox(width: 6),
                            _buildGridButton(
                              icon: Icons.monitor_rounded,
                              label: 'VGA',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.vga),
                            ),
                          ],
                        ),

                        // SECTION 5: THREE ACTION ROWS (2 BUTTONS PER ROW)
                        // ROW 1: YouTube (sends 0x60 IR) | Video Player (Custom Slot 3 IR)
                        Row(
                          children: [
                            // YouTube: Sends Walton IR 0x60
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCommand(context, WaltonCommands.youtube),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: RemoteColors.youtubeRed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'YouTube',
                                      style: TextStyle(
                                        color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Video Player: Custom Slot 3 IR
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCustom(context, 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot3.icon,
                                      color: slot3.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        slot3.title,
                                        style: TextStyle(
                                          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ROW 2: LocalSend (Custom Slot 5 IR) | Movie (Custom Slot 6 IR)
                        Row(
                          children: [
                            // LocalSend: Custom Slot 5 IR
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCustom(context, 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot5.icon,
                                      color: slot5.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        slot5.title,
                                        style: TextStyle(
                                          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Movie: Custom Slot 6 IR
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCustom(context, 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot6.icon,
                                      color: slot6.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        slot6.title,
                                        style: TextStyle(
                                          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ROW 3: TV Settings (sends 0x90 IR) | Settings (Custom Slot 4 IR)
                        Row(
                          children: [
                            // TV Settings: Walton TV IR Command 0x90
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCommand(context, WaltonCommands.tvSettings),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.settings_outlined,
                                      color: isDark ? RemoteColors.darkTextSecondary : const Color(0xFF37474F),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'TV Settings',
                                      style: TextStyle(
                                        color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Settings: Custom Slot 4 IR
                            Expanded(
                              child: NeumorphicButton(
                                height: 42,
                                isDark: isDark,
                                borderRadius: 14,
                                onPressed: () => _sendCustom(context, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot4.icon,
                                      color: slot4.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        slot4.title,
                                        style: TextStyle(
                                          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM PAGE INDICATOR & SWIPE BACK HINT
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSwipeBack,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? Colors.white : RemoteColors.lightTextPrimary).withAlpha(60),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              color: (isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary).withAlpha(180),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Swipe back for main controls',
                              style: TextStyle(
                                color: (isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary).withAlpha(180),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
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
    required bool isDark,
  }) {
    return Expanded(
      child: NeumorphicButton(
        height: 44,
        isDark: isDark,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
                fontSize: 9,
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
    bool isDark,
  ) {
    return Row(
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _buildNumpadDigit(
              digit: digits[i],
              isDark: isDark,
              onPressed: () => _sendCommand(context, commands[i]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumpadDigit({
    required String digit,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return NeumorphicButton(
      height: 38,
      isDark: isDark,
      borderRadius: 10,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(
        digit,
        style: TextStyle(
          color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNumpadSpecial({
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return NeumorphicButton(
      height: 38,
      isDark: isDark,
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
