import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/custom_slot.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/developer_avatar.dart';
import '../widgets/neumorphic_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final IrService _irService = IrService();
  final SettingsService _settingsService = SettingsService();

  void _showExportDialog() {
    final jsonStr = _settingsService.exportConfigJson();
    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration copied to clipboard!'),
        backgroundColor: RemoteColors.connectedGreen,
        duration: Duration(seconds: 2),
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exported Configuration',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your custom configuration JSON has been copied to the clipboard. You can paste and save it as a backup.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF16181F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                jsonStr,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RemoteColors.irBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final textController = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E222B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Import Configuration',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your exported configuration JSON below to restore your custom slots and settings:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11),
                decoration: InputDecoration(
                  hintText: '{"vibration":true,"slots":[...]}',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF16181F),
                  errorText: errorMsg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (_) {
                  if (errorMsg != null) setDialogState(() => errorMsg = null);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data != null && data.text != null) {
                  textController.text = data.text!;
                }
              },
              child: const Text('Paste from Clipboard', style: TextStyle(color: RemoteColors.irBlue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RemoteColors.connectedGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final error = await _settingsService.importConfigJson(textController.text.trim());
                if (error == null) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration imported successfully!'),
                      backgroundColor: RemoteColors.connectedGreen,
                    ),
                  );
                } else {
                  setDialogState(() => errorMsg = error);
                }
              },
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? RemoteColors.darkBackground : RemoteColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings & Customization',
          style: TextStyle(
            color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_irService, _settingsService]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // SECTION 1: DEVELOPER PROFILE (CIRCULAR AVATAR)
              _buildDeveloperCard(isDark),

              const SizedBox(height: 16),

              // SECTION 2: THEME MODE SELECTOR
              _buildThemeModeCard(isDark),

              const SizedBox(height: 16),

              // SECTION 3: HARDWARE & IR TRANSMISSION STATUS + TEST BUTTON
              _buildHardwareCard(isDark),

              const SizedBox(height: 16),

              // SECTION 4: HAPTIC FEEDBACK (VIBRATION)
              _buildHapticCard(isDark),

              const SizedBox(height: 16),

              // SECTION 5: EXACTLY 6 CUSTOM SLOTS (ALL REAL IR COMMANDS)
              _buildCustomSlotsCard(isDark),

              const SizedBox(height: 16),

              // SECTION 6: BACKUP & RESTORE CONFIGURATION (JSON)
              _buildBackupRestoreCard(isDark),

              const SizedBox(height: 16),

              // SECTION 7: RECENT TRANSMISSIONS AUDIT LOG
              _buildAuditLogCard(isDark),

              const SizedBox(height: 16),

              // SECTION 8: ABOUT WALTON TV REMOTE
              _buildAboutCard(isDark),

              const SizedBox(height: 28),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeveloperCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(12) : RemoteColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(120) : const Color(0xFFCAD4E2).withAlpha(140),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Developer Avatar
              DeveloperAvatar(
                size: 72,
                isDark: isDark,
                showBorder: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Profile',
                      style: TextStyle(
                        color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Walton TV IR Remote App',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : RemoteColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // GitHub Link Button
                    GestureDetector(
                      onTap: () {
                        _irService.openExternalUrl('https://github.com/shifat-git');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: RemoteColors.irBlue.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: RemoteColors.irBlue.withAlpha(isDark ? 100 : 140),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.code_rounded,
                              size: 14,
                              color: RemoteColors.irBlue,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'GitHub: @shifat-git',
                              style: TextStyle(
                                color: RemoteColors.irBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeCard(bool isDark) {
    final currentMode = _settingsService.themeMode;

    return _buildSectionCard(
      isDark: isDark,
      title: 'App Theme Appearance',
      icon: Icons.palette_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select preferred theme mode for the application interface:',
            style: TextStyle(
              color: isDark ? Colors.white60 : RemoteColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeOption(
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                selected: currentMode == ThemeMode.system,
                onTap: () => _settingsService.setThemeMode(ThemeMode.system),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                selected: currentMode == ThemeMode.dark,
                onTap: () => _settingsService.setThemeMode(ThemeMode.dark),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                selected: currentMode == ThemeMode.light,
                onTap: () => _settingsService.setThemeMode(ThemeMode.light),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? RemoteColors.irBlue.withAlpha(isDark ? 50 : 30)
                : (isDark ? const Color(0xFF1B1E26) : const Color(0xFFEAEEF5)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? RemoteColors.irBlue
                  : (isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(15)),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? RemoteColors.irBlue
                    : (isDark ? Colors.white70 : RemoteColors.lightTextSecondary),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? RemoteColors.irBlue
                      : (isDark ? Colors.white70 : RemoteColors.lightTextSecondary),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHardwareCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'IR Blaster & Protocol Status',
      icon: Icons.wifi_tethering_rounded,
      child: Column(
        children: [
          _buildStatusRow(
            label: 'Hardware Emitter',
            value: _irService.hasIrEmitter ? 'Detected (Hardware IR)' : 'IR Not Available',
            statusColor: _irService.hasIrEmitter ? RemoteColors.connectedGreen : Colors.orangeAccent,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
          _buildStatusRow(
            label: 'Carrier Frequency',
            value: '38,000 Hz (38 kHz)',
            statusColor: RemoteColors.irBlue,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
          _buildStatusRow(
            label: 'Encoding Bit Order',
            value: 'True LSB (Bit 0 first)',
            statusColor: Colors.purpleAccent,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
          _buildStatusRow(
            label: 'NEC Frame Format',
            value: '00 BC CMD INV (INV = 0xFF - CMD)',
            statusColor: Colors.cyanAccent,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
          _buildStatusRow(
            label: 'Last Sent Frame',
            value: _irService.lastSentHex ?? 'No command sent yet',
            statusColor: isDark ? Colors.white70 : RemoteColors.lightTextSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // Test IR Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: RemoteColors.irBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                _irService.sendTestCommand();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test packet (0x00) transmitted through IR blaster!'),
                    backgroundColor: RemoteColors.connectedGreen,
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text(
                'Test IR Blaster (Transmit 0x00)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHapticCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'Haptic Feedback',
      icon: Icons.vibration_rounded,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Vibration on Tap',
          style: TextStyle(
            color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Tactile haptic click sensation when pressing remote buttons',
          style: TextStyle(
            color: isDark ? Colors.white54 : RemoteColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        value: _settingsService.vibrationEnabled,
        activeColor: RemoteColors.irBlue,
        onChanged: (val) {
          _settingsService.setVibrationEnabled(val);
        },
      ),
    );
  }

  Widget _buildCustomSlotsCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'Custom Buttons (6 Slots)',
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All 6 custom slots transmit real IR commands (0x00 to 0xFF). Tap Edit to customize labels or assign specific IR hex codes.',
            style: TextStyle(
              color: isDark ? Colors.white54 : RemoteColors.lightTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < _settingsService.customSlots.length; i++) ...[
            _buildSlotTile(_settingsService.customSlots[i], isDark),
            if (i < _settingsService.customSlots.length - 1)
              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
          ],
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: () => _settingsService.resetCustomSlotsToDefault(),
              icon: Icon(
                Icons.restore_rounded,
                size: 16,
                color: isDark ? Colors.white54 : RemoteColors.lightTextSecondary,
              ),
              label: Text(
                'Reset All Slots to Default',
                style: TextStyle(
                  color: isDark ? Colors.white54 : RemoteColors.lightTextSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupRestoreCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'Backup & Restore Configuration',
      icon: Icons.backup_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup your custom slots and settings as JSON or restore them from a previous backup:',
            style: TextStyle(
              color: isDark ? Colors.white54 : RemoteColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF262B36) : const Color(0xFFE2E8F0),
                    foregroundColor: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showExportDialog,
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export JSON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF262B36) : const Color(0xFFE2E8F0),
                    foregroundColor: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showImportDialog,
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: const Text('Import JSON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'Transmission Audit Log',
      icon: Icons.history_rounded,
      child: _irService.logs.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No transmissions logged yet.\nTap any remote button to see packet trace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : RemoteColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                for (final log in _irService.logs.take(8)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              log.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              size: 14,
                              color: log.success ? RemoteColors.connectedGreen : Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              log.label,
                              style: TextStyle(
                                color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.hexFrame,
                            style: const TextStyle(
                              color: RemoteColors.irBlue,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _irService.clearLogs(),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 14, color: Colors.redAccent),
                    label: const Text('Clear Logs', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'About Walton TV Remote',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Walton TV Remote v1.0.0',
            style: TextStyle(
              color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• 100% Offline & Ad-Free.\n'
            '• Carrier: 38 kHz NEC / uPD6122.\n'
            '• Frame: 00 BC CMD INV (True LSB bit-order).\n'
            '• Native Android ConsumerIrManager via Kotlin.\n'
            '• Developed and tested for Poco F6 IR Blaster.',
            style: TextStyle(
              color: isDark ? Colors.white60 : RemoteColors.lightTextSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? RemoteColors.darkSurface : RemoteColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(12) : RemoteColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(120) : const Color(0xFFCAD4E2).withAlpha(120),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: RemoteColors.irBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String value,
    required Color statusColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : RemoteColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: value.contains('00 BC') ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotTile(CustomSlot slot, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(slot.icon, color: slot.accentColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom ${slot.slotIndex}: ${slot.title}',
                      style: TextStyle(
                        color: isDark ? Colors.white : RemoteColors.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IR Code: ${slot.irHex} (${slot.fullFrameHex})',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : RemoteColors.lightTextSecondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF262B36) : const Color(0xFFE2E8F0),
            foregroundColor: isDark ? Colors.white : RemoteColors.lightTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _showEditSlotDialog(slot),
          child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showEditSlotDialog(CustomSlot slot) {
    final titleController = TextEditingController(text: slot.title);
    final hexController = TextEditingController(text: slot.irHex);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E222B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Custom Slot ${slot.slotIndex}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Button Display Name', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF16181F),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'IR Command Hex (0x00 to 0xFF)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: hexController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'e.g. 0x15 or 15',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF16181F),
                        errorText: errorMessage,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) {
                        if (errorMessage != null) {
                          setDialogState(() => errorMessage = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Walton Presets:',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: WaltonCommands.availableCustomCommands.map((cmd) {
                        return ActionChip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFF262B36),
                          label: Text(
                            cmd.cmdHex,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          onPressed: () {
                            hexController.text = cmd.cmdHex;
                            setDialogState(() => errorMessage = null);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RemoteColors.irBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final rawHex = hexController.text.trim();
                    final cleanHex = rawHex.startsWith('0x') || rawHex.startsWith('0X')
                        ? rawHex.substring(2)
                        : rawHex;

                    final parsedCmd = int.tryParse(cleanHex, radix: 16);
                    if (parsedCmd == null || parsedCmd < 0 || parsedCmd > 0xFF) {
                      setDialogState(() {
                        errorMessage = 'Invalid Hex! Enter 0x00 to 0xFF (0-255)';
                      });
                      return;
                    }

                    final newTitle = titleController.text.trim();
                    _settingsService.updateCustomSlot(
                      slot.slotIndex,
                      title: newTitle.isEmpty ? slot.defaultTitle : newTitle,
                      irCommand: parsedCmd,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
