import 'dart:async';
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
  final bool? isDark;

  const RockerPill({
    super.key,
    required this.label,
    required this.topIcon,
    required this.bottomIcon,
    required this.onTopPressed,
    required this.onBottomPressed,
    this.width = 54.0,
    this.height = 175.0,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        borderRadius: BorderRadius.circular(width / 2),
        border: Border.all(
          color: dark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withAlpha(200) : const Color(0xFFCAD4E2).withAlpha(220),
            offset: const Offset(4, 6),
            blurRadius: 10,
          ),
          BoxShadow(
            color: dark ? Colors.white.withAlpha(12) : Colors.white.withAlpha(240),
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
              isDark: dark,
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
                color: dark
                    ? RemoteColors.darkTextSecondary.withAlpha(220)
                    : RemoteColors.lightTextSecondary.withAlpha(220),
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
              isDark: dark,
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
  final bool isDark;
  final BorderRadius borderRadius;

  const _RockerHalf({
    required this.icon,
    required this.onPressed,
    required this.isTop,
    required this.isDark,
    required this.borderRadius,
  });

  @override
  State<_RockerHalf> createState() => _RockerHalfState();
}

class _RockerHalfState extends State<_RockerHalf> {
  bool _isPressed = false;
  Timer? _initialTimer;
  Timer? _repeatTimer;

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _initialTimer?.cancel();
    _initialTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    HapticService.triggerButtonFeedback();
    // Trigger immediate single tap command
    widget.onPressed();

    // Start long-press repeat after 320ms delay
    _cancelTimers();
    _initialTimer = Timer(const Duration(milliseconds: 320), () {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (!mounted || !_isPressed) {
          timer.cancel();
          return;
        }
        HapticService.triggerButtonFeedback();
        widget.onPressed();
      });
    });
  }

  void _handleTapEnd() {
    _cancelTimers();
    if (mounted && _isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapEnd(),
      onTapCancel: () => _handleTapEnd(),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.isDark ? Colors.black.withAlpha(80) : const Color(0xFFCAD4E2).withAlpha(120))
                : Colors.transparent,
            borderRadius: widget.borderRadius,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: _isPressed
                  ? RemoteColors.irBlue
                  : (widget.isDark
                      ? RemoteColors.darkTextPrimary.withAlpha(230)
                      : RemoteColors.lightTextPrimary.withAlpha(230)),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
