import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DeveloperAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool? isDark;

  const DeveloperAvatar({
    super.key,
    this.size = 38.0,
    this.onTap,
    this.showBorder = true,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    final Widget avatarImage = ClipOval(
      child: Image.asset(
        'assets/developer_profile.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? RemoteColors.darkSurfaceLight : RemoteColors.lightShadow,
            ),
            child: Icon(
              Icons.person_rounded,
              size: size * 0.6,
              color: dark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
            ),
          );
        },
      ),
    );

    final Widget content = Container(
      width: size + (showBorder ? 6 : 0),
      height: size + (showBorder ? 6 : 0),
      padding: EdgeInsets.all(showBorder ? 2.5 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        border: showBorder
            ? Border.all(
                color: RemoteColors.irBlue.withAlpha(dark ? 120 : 160),
                width: 1.5,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: dark ? Colors.black.withAlpha(160) : const Color(0xFFCAD4E2).withAlpha(180),
                  offset: const Offset(2, 3),
                  blurRadius: 5,
                ),
                BoxShadow(
                  color: RemoteColors.irBlue.withAlpha(40),
                  offset: const Offset(0, 0),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: avatarImage,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
