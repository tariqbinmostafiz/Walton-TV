import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class MediaControllerPill extends StatelessWidget {
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;

  const MediaControllerPill({
    super.key,
    required this.onRewind,
    required this.onPlayPause,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
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
            ),

            // Play / Pause button (wider pill in the center)
            _MediaItem(
              icon: Icons.play_arrow_rounded,
              secondaryIcon: Icons.pause_rounded,
              label: 'Play/Pause',
              onPressed: onPlayPause,
              isCenter: true,
            ),

            // Forward button
            _MediaItem(
              icon: Icons.fast_forward_rounded,
              label: 'Forward',
              onPressed: onForward,
              isCenter: false,
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

  const _MediaItem({
    required this.icon,
    this.secondaryIcon,
    required this.label,
    required this.onPressed,
    required this.isCenter,
  });

  @override
  State<_MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<_MediaItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _isPressed ? const Color(0xFF14161D) : RemoteColors.darkSurface,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: Colors.white.withAlpha(14),
                width: 1,
              ),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(200),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(200),
                        offset: const Offset(3, 4),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(12),
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
                              : RemoteColors.darkTextPrimary,
                          size: 24,
                        ),
                        Icon(
                          widget.secondaryIcon!,
                          color: _isPressed
                              ? RemoteColors.irBlue
                              : RemoteColors.darkTextPrimary,
                          size: 20,
                        ),
                      ],
                    )
                  : Icon(
                      widget.icon,
                      color: _isPressed
                          ? RemoteColors.irBlue
                          : RemoteColors.darkTextPrimary,
                      size: 24,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: TextStyle(
            color: RemoteColors.darkTextSecondary.withAlpha(180),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
