import 'package:flutter/material.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dpad_controller.dart';
import '../widgets/ir_indicator.dart';
import '../widgets/media_controller.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/rocker_pill.dart';
import 'settings_page.dart';

class MainRemotePage extends StatefulWidget {
  final VoidCallback onSwipeToMore;

  const MainRemotePage({
    super.key,
    required this.onSwipeToMore,
  });

  @override
  State<MainRemotePage> createState() => _MainRemotePageState();
}

class _MainRemotePageState extends State<MainRemotePage> {
  bool _powerPressed = false;

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
    final ir = IrService();
    final settings = SettingsService();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? RemoteColors.darkBackground : RemoteColors.lightBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([ir, settings]),
          builder: (context, _) {
            final slot1 = settings.customSlots[0];
            final slot2 = settings.customSlots[1];

            return Column(
              children: [
                // TOP PHYSICAL IR EMITTER DIODE (Constant footprint)
                IrIndicatorBar(isDark: isDark),

                // TOP HEADER: Walton TV, IR Status, Single Settings Gear
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: App Title & Hardware Connection Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Walton TV',
                            style: TextStyle(
                              color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ir.hasIrEmitter
                                      ? RemoteColors.connectedGreen
                                      : Colors.orangeAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (ir.hasIrEmitter
                                              ? RemoteColors.connectedGreen
                                              : Colors.orangeAccent)
                                          .withAlpha(150),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                ir.hasIrEmitter ? 'IR Ready' : 'IR Not Available',
                                style: TextStyle(
                                  color: ir.hasIrEmitter
                                      ? RemoteColors.connectedGreen
                                      : Colors.orangeAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: Single Settings Gear Button
                      NeumorphicButton(
                        width: 40,
                        height: 40,
                        isCircle: true,
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.settings_outlined,
                          color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY CONTENT: 100% FIXED, NO VERTICAL SCROLLING
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 1. POWER & SOURCE ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Power Button (Local scale animation)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTapDown: (_) => setState(() => _powerPressed = true),
                                  onTapUp: (_) {
                                    setState(() => _powerPressed = false);
                                    _sendCommand(context, WaltonCommands.power);
                                  },
                                  onTapCancel: () => setState(() => _powerPressed = false),
                                  child: AnimatedScale(
                                    scale: _powerPressed ? 0.94 : 1.0,
                                    duration: const Duration(milliseconds: 90),
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                          colors: [
                                            Color(0xFFFF5252),
                                            Color(0xFFE53935),
                                            Color(0xFFB71C1C),
                                          ],
                                          center: Alignment(-0.2, -0.3),
                                          radius: 0.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF3B30).withAlpha(160),
                                            offset: const Offset(0, 3),
                                            blurRadius: _powerPressed ? 6 : 14,
                                            spreadRadius: _powerPressed ? 0 : 1.5,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withAlpha(80),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.power_settings_new_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Power',
                                  style: TextStyle(
                                    color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            // Source Button
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NeumorphicButton(
                                  width: 58,
                                  height: 58,
                                  isCircle: true,
                                  isDark: isDark,
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _sendCommand(context, WaltonCommands.source),
                                  child: Icon(
                                    Icons.input_rounded,
                                    color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Source',
                                  style: TextStyle(
                                    color: isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 2. MIDDLE FLANKED SECTION: VOL | DPAD | CH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Volume Rocker
                            RockerPill(
                              label: 'VOL',
                              width: 50,
                              height: 155,
                              isDark: isDark,
                              topIcon: Icons.add_rounded,
                              bottomIcon: Icons.remove_rounded,
                              onTopPressed: () => _sendCommand(context, WaltonCommands.volUp),
                              onBottomPressed: () => _sendCommand(context, WaltonCommands.volDown),
                            ),

                            // D-Pad Controller (Center OK and 4 directions)
                            DpadController(
                              size: 165,
                              isDark: isDark,
                              onUp: () => _sendCommand(context, WaltonCommands.up),
                              onDown: () => _sendCommand(context, WaltonCommands.down),
                              onLeft: () => _sendCommand(context, WaltonCommands.left),
                              onRight: () => _sendCommand(context, WaltonCommands.right),
                              onOk: () => _sendCommand(context, WaltonCommands.ok),
                            ),

                            // Channel Rocker
                            RockerPill(
                              label: 'CH',
                              width: 50,
                              height: 155,
                              isDark: isDark,
                              topIcon: Icons.keyboard_arrow_up_rounded,
                              bottomIcon: Icons.keyboard_arrow_down_rounded,
                              onTopPressed: () => _sendCommand(context, WaltonCommands.chUp),
                              onBottomPressed: () => _sendCommand(context, WaltonCommands.chDown),
                            ),
                          ],
                        ),

                        // 3. LOWER BUTTONS ROW: Mute | Home | Back / Recall
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CircleActionItem(
                              icon: Icons.volume_off_rounded,
                              label: 'Mute',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.mute),
                            ),
                            _CircleActionItem(
                              icon: Icons.home_rounded,
                              label: 'Home',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.home),
                            ),
                            _CircleActionItem(
                              icon: Icons.undo_rounded,
                              label: 'Back',
                              isDark: isDark,
                              onPressed: () => _sendCommand(context, WaltonCommands.recallBack),
                            ),
                          ],
                        ),

                        // 4. CUSTOM BUTTONS ROW: Custom 1 (IP TV) & Custom 2 (YouTube VIP)
                        Row(
                          children: [
                            // Custom Slot 1
                            Expanded(
                              child: NeumorphicButton(
                                height: 46,
                                borderRadius: 23,
                                isDark: isDark,
                                onPressed: () => _sendCustom(context, 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: slot1.accentColor.withAlpha(40),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        slot1.icon,
                                        color: slot1.accentColor,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        slot1.title,
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

                            const SizedBox(width: 12),

                            // Custom Slot 2
                            Expanded(
                              child: NeumorphicButton(
                                height: 46,
                                borderRadius: 23,
                                isDark: isDark,
                                onPressed: () => _sendCustom(context, 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: slot2.accentColor.withAlpha(40),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        slot2.icon,
                                        color: slot2.accentColor,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        slot2.title,
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

                        // 5. MEDIA CONTROLS ROW: Rewind | Play/Pause | Forward
                        MediaControllerPill(
                          isDark: isDark,
                          onRewind: () => _sendCommand(context, WaltonCommands.rewind),
                          onPlayPause: () => _sendCommand(context, WaltonCommands.playPause),
                          onForward: () => _sendCommand(context, WaltonCommands.forward),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM PAGE INDICATOR & SWIPE HINT
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwipeToMore,
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
                                color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? Colors.white : RemoteColors.lightTextPrimary).withAlpha(60),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Swipe for more controls',
                              style: TextStyle(
                                color: (isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary).withAlpha(180),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: (isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary).withAlpha(180),
                              size: 13,
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
}

class _CircleActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  const _CircleActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicButton(
          width: 52,
          height: 52,
          isCircle: true,
          isDark: isDark,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon,
            color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
            size: 23,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDark ? RemoteColors.darkTextSecondary : RemoteColors.lightTextSecondary).withAlpha(200),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
