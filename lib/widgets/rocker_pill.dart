import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class RockerPill extends StatelessWidget {
  final String label;
  final IconData topIcon;
  final IconData bottomIcon;
  final VoidCallback onTopPressed;
  final VoidCallback onBottomPressed;
  final double width;
  final double height;

  const RockerPill({
    super.key,
    required this.label,
    required this.topIcon,
    required this.bottomIcon,
    required this.onTopPressed,
    required this.onBottomPressed,
    this.width = 54.0,
    this.height = 175.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RemoteColors.darkSurface,
        borderRadius: BorderRadius.circular(width / 2),
        border: Border.all(
          color: Colors.white.withAlpha(14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(200),
            offset: const Offset(4, 6),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(12),
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top half (+) or (CH^)
          Expanded(
            child: _RockerHalf(
              icon: topIcon,
              onPressed: onTopPressed,
              isTop: true,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(width / 2),
              ),
            ),
          ),

          // Center Label (VOL / CH)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              label,
              style: TextStyle(
                color: RemoteColors.darkTextSecondary.withAlpha(220),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Bottom half (-) or (CHv)
          Expanded(
            child: _RockerHalf(
              icon: bottomIcon,
              onPressed: onBottomPressed,
              isTop: false,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(width / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RockerHalf extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isTop;
  final BorderRadius borderRadius;

  const _RockerHalf({
    required this.icon,
    required this.onPressed,
    required this.isTop,
    required this.borderRadius,
  });

  @override
  State<_RockerHalf> createState() => _RockerHalfState();
}

class _RockerHalfState extends State<_RockerHalf> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.triggerButtonFeedback();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.black.withAlpha(80) : Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: _isPressed
                ? RemoteColors.irBlue
                : RemoteColors.darkTextPrimary.withAlpha(230),
            size: 26,
          ),
        ),
      ),
    );
  }
}
