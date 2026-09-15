import 'package:flutter/material.dart';
import '../services/ir_service.dart';
import '../theme/app_colors.dart';

class IrIndicatorBar extends StatelessWidget {
  final bool isDark;

  const IrIndicatorBar({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final irService = IrService();

    return ListenableBuilder(
      listenable: irService,
      builder: (context, _) {
        final state = irService.transmissionState;
        final bool isTx = state == IrTransmissionState.sending;
        final bool isSuccess = state == IrTransmissionState.success;
        final bool isFail = state == IrTransmissionState.failure;
        final bool isActive = isTx || isSuccess || isFail;

        final Color glowColor = isTx
            ? RemoteColors.irBlue
            : (isSuccess
                ? RemoteColors.connectedGreen
                : (isFail ? RemoteColors.powerRed : Colors.transparent));

        final Color bulbColor = isTx
            ? RemoteColors.irBlue
            : (isSuccess
                ? RemoteColors.connectedGreen
                : (isFail
                    ? RemoteColors.powerRed
                    : (isDark ? Colors.white.withAlpha(40) : Colors.black.withAlpha(30))));

        final String? lastHex = irService.lastSentHex;
        final String? lastLabel = irService.lastSentLabel;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Physical IR Blaster diode representation
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: isActive ? 22 : 14,
                height: isActive ? 12 : 8,
                decoration: BoxDecoration(
                  color: bulbColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: glowColor.withAlpha(220),
                            blurRadius: 16,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: glowColor.withAlpha(150),
                            blurRadius: 24,
                            spreadRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Subtle animated status HUD badge
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive && lastHex != null ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D2028).withAlpha(230)
                      : const Color(0xFFFFFFFF).withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: glowColor.withAlpha(120),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTx
                          ? Icons.sensors_rounded
                          : (isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded),
                      size: 13,
                      color: glowColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${lastLabel ?? "IR"}: 0x$lastHex',
                      style: TextStyle(
                        color: isDark ? RemoteColors.darkTextPrimary : RemoteColors.lightTextPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
