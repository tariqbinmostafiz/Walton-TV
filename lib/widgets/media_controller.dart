import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class MediaControllerPill extends StatelessWidget {
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;
  final bool? isDark;

  const MediaControllerPill({
    super.key,
    required this.onRewind,
    required this.onPlayPause,
    required this.onForward,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Rewind button
            _MediaItem(
              icon: Icons.fast_rewind_rounded,
              label: 'Rewind',
              onPressed: onRewind,
              isCenter: false,
              isDark: dark,
            ),

            // Play / Pause button (wider pill in the center)
            _MediaItem(
              icon: Icons.play_arrow_rounded,
              secondaryIcon: Icons.pause_rounded,
              label: 'Play/Pause',
              onPressed: onPlayPause,
              isCenter: true,
              isDark: dark,
            ),

            // Forward button
            _MediaItem(
              icon: Icons.fast_forward_rounded,
              label: 'Forward',
              onPressed: onForward,
              isCenter: false,
              isDark: dark,
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaItem extends StatefulWidget {
  final IconData icon;
  final IconData? secondaryIcon;
  final String label;
  final VoidCallback onPressed;
  final bool isCenter;
  final bool isDark;

  const _MediaItem({
    required this.icon,
    this.secondaryIcon,
    required this.label,
    required this.onPressed,
    required this.isCenter,
    required this.isDark,
  });

  @override
  State<_MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<_MediaItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;
    final double width = widget.isCenter ? 120 : 64;
    const double height = 54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticService.triggerButtonFeedback();
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: _isPressed
                    ? (dark ? const Color(0xFF14161D) : const Color(0xFFDDE4EE))
                    : (dark ? RemoteColors.darkSurface : RemoteColors.lightSurface),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: dark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(14),
                  width: 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: dark ? Colors.black.withAlpha(200) : const Color(0xFFCAD4E2).withAlpha(180),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: dark ? Colors.black.withAlpha(200) : const Color(0xFFCAD4E2).withAlpha(220),
                          offset: const Offset(3, 4),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: dark ? Colors.white.withAlpha(12) : Colors.white.withAlpha(240),
                          offset: const Offset(-2, -2),
                          blurRadius: 5,
                        ),
                      ],
              ),
              child: Center(
                child: widget.secondaryIcon != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            color: _isPressed
                                ? RemoteColors.irBlue
                                : (dark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary),
                            size: 24,
                          ),
                          Icon(
                            widget.secondaryIcon!,
                            color: _isPressed
                                ? RemoteColors.irBlue
                                : (dark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary),
                            size: 20,
                          ),
                        ],
                      )
                    : Icon(
                        widget.icon,
                        color: _isPressed
                            ? RemoteColors.irBlue
                            : (dark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary),
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: TextStyle(
            color: dark
                ? RemoteColors.darkTextSecondary.withAlpha(180)
                : RemoteColors.lightTextSecondary.withAlpha(180),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
