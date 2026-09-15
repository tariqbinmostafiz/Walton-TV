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
                    : (isDark ? Colors.white.withAlpha(35) : Colors.black.withAlpha(25))));

        return SizedBox(
          height: 12,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 18,
              height: 6,
              decoration: BoxDecoration(
                color: bulbColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: glowColor.withAlpha(230),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: glowColor.withAlpha(140),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
