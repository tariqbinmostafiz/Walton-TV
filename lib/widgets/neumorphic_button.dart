import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';

class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final IconData? icon;
  final String? label;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isDark;
  final bool isCircle;
  final Color? surfaceColor;
  final Color? iconColor;
  final Color? textColor;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.width,
    this.height,
    this.borderRadius = 18.0,
    this.isDark = true,
    this.isCircle = false,
    this.surfaceColor,
    this.iconColor,
    this.textColor,
    this.isSelected = false,
    this.padding,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;

    final Color bgColor = widget.surfaceColor ??
        (isDark
            ? (_isPressed ? const Color(0xFF16181F) : RemoteColors.darkSurface)
            : (_isPressed ? const Color(0xFFE4E9F0) : RemoteColors.lightSurface));

    final Color iconColor = widget.iconColor ??
        (isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary);

    final Color textColor = widget.textColor ??
        (isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary);

    final double effectiveRadius = widget.isCircle ? 100 : widget.borderRadius;

    final List<BoxShadow> shadows = _isPressed
        ? [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(180) : const Color(0xFFC0CAD8).withAlpha(160),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ]
        : [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(200)
                  : const Color(0xFFCAD4E2).withAlpha(220),
              offset: const Offset(3, 4),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(240),
              offset: const Offset(-3, -3),
              blurRadius: 5,
              spreadRadius: 0.5,
            ),
          ];

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.triggerButtonFeedback();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle ? null : BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: isDark
                ? (_isPressed ? Colors.transparent : Colors.white.withAlpha(12))
                : (_isPressed ? Colors.black.withAlpha(10) : Colors.white.withAlpha(180)),
            width: 1,
          ),
          boxShadow: shadows,
        ),
        child: Center(
          child: widget.child ??
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: iconColor,
                      size: 22,
                    ),
                  if (widget.icon != null && widget.label != null)
                    const SizedBox(height: 4),
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
