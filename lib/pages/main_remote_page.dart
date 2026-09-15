import 'package:flutter/material.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dpad_controller.dart';
import '../widgets/media_controller.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/rocker_pill.dart';
import 'settings_page.dart';

class MainRemotePage extends StatelessWidget {
  final VoidCallback onSwipeToMore;

  const MainRemotePage({
    super.key,
    required this.onSwipeToMore,
  });

  void _sendCommand(BuildContext context, RemoteCommand cmd) {
    IrService().sendCommand(cmd.cmd, label: cmd.label);
  }

  void _sendCustom(BuildContext context, int slotIndex) {
    final settings = SettingsService();
    final slot = settings.customSlots.firstWhere(
      (s) => s.slotIndex == slotIndex,
      orElse: () => settings.customSlots.first,
    );
    IrService().sendCommand(slot.irCommand, label: slot.title);
  }

  @override
  Widget build(BuildContext context) {
    final ir = IrService();
    final settings = SettingsService();

    return Scaffold(
      backgroundColor: RemoteColors.darkBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([ir, settings]),
          builder: (context, _) {
            final slot1 = settings.customSlots[0];
            final slot2 = settings.customSlots[1];

            return Column(
              children: [
                // TOP HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Walton TV',
                            style: TextStyle(
                              color: RemoteColors.darkTextPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ir.hasIrEmitter
                                      ? RemoteColors.connectedGreen
                                      : Colors.amber,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (ir.hasIrEmitter
                                              ? RemoteColors.connectedGreen
                                              : Colors.amber)
                                          .withAlpha(150),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ir.hasIrEmitter ? 'Connected' : 'IR Ready (Standby)',
                                style: TextStyle(
                                  color: ir.hasIrEmitter
                                      ? RemoteColors.connectedGreen
                                      : RemoteColors.darkTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // IR Blaster status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RemoteColors.darkSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withAlpha(12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wifi_tethering_rounded,
                                  color: ir.isTransmitting
                                      ? RemoteColors.connectedGreen
                                      : RemoteColors.irBlue,
                                  size: 17,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'IR',
                                  style: TextStyle(
                                    color: RemoteColors.darkTextPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Settings icon button
                          NeumorphicButton(
                            width: 42,
                            height: 42,
                            isCircle: true,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.settings_outlined,
                              color: RemoteColors.darkTextSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // BODY SCROLL / LAYOUT
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Column(
                      children: [
                        // POWER & SOURCE ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Power Button (Glowing Red)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _sendCommand(context, WaltonCommands.power),
                                  child: Container(
                                    width: 64,
                                    height: 64,
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
                                          offset: const Offset(0, 4),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withAlpha(50),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.power_settings_new_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Power',
                                  style: TextStyle(
                                    color: RemoteColors.darkTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Source Button
                            Column(
                              children: [
                                NeumorphicButton(
                                  width: 64,
                                  height: 64,
                                  isCircle: true,
                                  padding: EdgeInsets.zero,
                                  onPressed: () =>
                                      _sendCommand(context, WaltonCommands.source),
                                  child: const Icon(
                                    Icons.input_rounded,
                                    color: RemoteColors.darkTextPrimary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Source',
                                  style: TextStyle(
                                    color: RemoteColors.darkTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // MIDDLE FLANKED SECTION: VOL | DPAD | CH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Volume Rocker
                            RockerPill(
                              label: 'VOL',
                              topIcon: Icons.add_rounded,
                              bottomIcon: Icons.remove_rounded,
                              onTopPressed: () =>
                                  _sendCommand(context, WaltonCommands.volUp),
                              onBottomPressed: () =>
                                  _sendCommand(context, WaltonCommands.volDown),
                            ),

                            // D-Pad Controller
                            DpadController(
                              onUp: () => _sendCommand(context, WaltonCommands.up),
                              onDown: () => _sendCommand(context, WaltonCommands.down),
                              onLeft: () => _sendCommand(context, WaltonCommands.left),
                              onRight: () => _sendCommand(context, WaltonCommands.right),
                              onOk: () => _sendCommand(context, WaltonCommands.ok),
                            ),

                            // Channel Rocker
                            RockerPill(
                              label: 'CH',
                              topIcon: Icons.keyboard_arrow_up_rounded,
                              bottomIcon: Icons.keyboard_arrow_down_rounded,
                              onTopPressed: () =>
                                  _sendCommand(context, WaltonCommands.chUp),
                              onBottomPressed: () =>
                                  _sendCommand(context, WaltonCommands.chDown),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // LOWER BUTTONS ROW: Mute | Home | Back / Recall
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Mute
                            _CircleActionItem(
                              icon: Icons.volume_off_rounded,
                              label: 'Mute',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.mute),
                            ),

                            // Home
                            _CircleActionItem(
                              icon: Icons.home_rounded,
                              label: 'Home',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.home),
                            ),

                            // Back / Recall
                            _CircleActionItem(
                              icon: Icons.undo_rounded,
                              label: 'Back / Recall',
                              onPressed: () =>
                                  _sendCommand(context, WaltonCommands.recallBack),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // CUSTOM BUTTONS ROW (CUSTOM 1 & CUSTOM 2)
                        Row(
                          children: [
                            // CUSTOM 1 (White Pill with blue icon)
                            Expanded(
                              child: NeumorphicButton(
                                height: 50,
                                borderRadius: 25,
                                surfaceColor: Colors.white,
                                onPressed: () => _sendCustom(context, 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot1.icon,
                                      color: slot1.accentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slot1.title,
                                      style: const TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // CUSTOM 2 (Dark Pill with purple icon)
                            Expanded(
                              child: NeumorphicButton(
                                height: 50,
                                borderRadius: 25,
                                onPressed: () => _sendCustom(context, 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      slot2.icon,
                                      color: slot2.accentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slot2.title,
                                      style: const TextStyle(
                                        color: RemoteColors.darkTextPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // MEDIA CONTROLS ROW
                        MediaControllerPill(
                          onRewind: () =>
                              _sendCommand(context, WaltonCommands.rewind),
                          onPlayPause: () =>
                              _sendCommand(context, WaltonCommands.playPause),
                          onForward: () =>
                              _sendCommand(context, WaltonCommands.forward),
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // BOTTOM PAGE INDICATOR & SWIPE HINT
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSwipeToMore,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(60),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Swipe for more controls',
                              style: TextStyle(
                                color: RemoteColors.darkTextSecondary.withAlpha(200),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: RemoteColors.darkTextSecondary.withAlpha(200),
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
}

class _CircleActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CircleActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicButton(
          width: 58,
          height: 58,
          isCircle: true,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon,
            color: RemoteColors.darkTextPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: RemoteColors.darkTextSecondary.withAlpha(200),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
