import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class DpadController extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onOk;

  const DpadController({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 200.0;
    const double centerSize = 74.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RemoteColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(220),
            offset: const Offset(5, 7),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(12),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(14),
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
            ),
          ),

          // CENTER OK BUTTON
          _CenterOkButton(
            size: centerSize,
            onPressed: onOk,
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

  const _DirectionalButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.width,
    required this.height,
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
        HapticService.triggerButtonFeedback();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.black.withAlpha(60) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: _isPressed
                ? RemoteColors.irBlue
                : RemoteColors.darkTextPrimary.withAlpha(220),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _CenterOkButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _CenterOkButton({
    required this.size,
    required this.onPressed,
  });

  @override
  State<_CenterOkButton> createState() => _CenterOkButtonState();
}

class _CenterOkButtonState extends State<_CenterOkButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.triggerButtonFeedback();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed ? const Color(0xFF16181F) : const Color(0xFF222631),
          border: Border.all(
            color: Colors.white.withAlpha(20),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(220),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(200),
                    offset: const Offset(2, 4),
                    blurRadius: 7,
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(20),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: const Center(
          child: Text(
            'OK',
            style: TextStyle(
              color: RemoteColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
