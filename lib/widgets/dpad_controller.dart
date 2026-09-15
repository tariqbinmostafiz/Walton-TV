import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class DpadController extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onOk;
  final bool? isDark;

  const DpadController({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onOk,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    const double size = 200.0;
    const double centerSize = 74.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withAlpha(220) : const Color(0xFFCAD4E2).withAlpha(220),
            offset: const Offset(4, 6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: dark ? Colors.white.withAlpha(12) : Colors.white.withAlpha(240),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: dark ? Colors.white.withAlpha(14) : Colors.white.withAlpha(180),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // UP BUTTON
          Positioned(
            top: 4,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_up_rounded,
              onPressed: onUp,
              tooltip: 'Up',
              width: 90,
              height: 52,
              isDark: dark,
            ),
          ),

          // DOWN BUTTON
          Positioned(
            bottom: 4,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onPressed: onDown,
              tooltip: 'Down',
              width: 90,
              height: 52,
              isDark: dark,
            ),
          ),

          // LEFT BUTTON
          Positioned(
            left: 4,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onPressed: onLeft,
              tooltip: 'Left',
              width: 52,
              height: 90,
              isDark: dark,
            ),
          ),

          // RIGHT BUTTON
          Positioned(
            right: 4,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onPressed: onRight,
              tooltip: 'Right',
              width: 52,
              height: 90,
              isDark: dark,
            ),
          ),

          // CENTER OK BUTTON
          _CenterOkButton(
            size: centerSize,
            onPressed: onOk,
            isDark: dark,
          ),
        ],
      ),
    );
  }
}

class _DirectionalButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double width;
  final double height;
  final bool isDark;

  const _DirectionalButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  State<_DirectionalButton> createState() => _DirectionalButtonState();
}

class _DirectionalButtonState extends State<_DirectionalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.triggerDpadFeedback();
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.isDark ? Colors.black.withAlpha(80) : const Color(0xFFCAD4E2).withAlpha(120))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: _isPressed
                  ? RemoteColors.irBlue
                  : (widget.isDark
                      ? RemoteColors.darkTextPrimary.withAlpha(220)
                      : RemoteColors.lightTextPrimary.withAlpha(220)),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterOkButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;
  final bool isDark;

  const _CenterOkButton({
    required this.size,
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_CenterOkButton> createState() => _CenterOkButtonState();
}

class _CenterOkButtonState extends State<_CenterOkButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.triggerOkFeedback();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPressed
                ? (dark ? const Color(0xFF16181F) : const Color(0xFFDDE4EE))
                : (dark ? const Color(0xFF222631) : const Color(0xFFFFFFFF)),
            border: Border.all(
              color: dark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
              width: 1.5,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: dark ? Colors.black.withAlpha(220) : const Color(0xFFCAD4E2).withAlpha(180),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    )
                  ]
                : [
                    BoxShadow(
                      color: dark ? Colors.black.withAlpha(200) : const Color(0xFFCAD4E2).withAlpha(220),
                      offset: const Offset(2, 4),
                      blurRadius: 7,
                    ),
                    BoxShadow(
                      color: dark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(240),
                      offset: const Offset(-2, -2),
                      blurRadius: 5,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              'OK',
              style: TextStyle(
                color: dark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
