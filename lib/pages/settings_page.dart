import 'package:flutter/material.dart';
import '../models/custom_slot.dart';
import '../models/remote_command.dart';
import '../services/ir_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final IrService _irService = IrService();
  final SettingsService _settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16181F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16181F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings & Customization',
          style: TextStyle(
            color: Colors.white,
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
              // SECTION 1: HARDWARE & TRANSMISSION STATUS
              _buildSectionCard(
                title: 'IR Blaster & Protocol Status',
                icon: Icons.wifi_tethering_rounded,
                child: Column(
                  children: [
                    _buildStatusRow(
                      label: 'Hardware Emitter',
                      value: _irService.hasIrEmitter ? 'Detected (Hardware IR)' : 'IR Not Available',
                      statusColor: _irService.hasIrEmitter ? RemoteColors.connectedGreen : Colors.orangeAccent,
                    ),
                    const Divider(color: Colors.white10, height: 18),
                    _buildStatusRow(
                      label: 'Carrier Frequency',
                      value: '38,000 Hz (38 kHz)',
                      statusColor: RemoteColors.irBlue,
                    ),
                    const Divider(color: Colors.white10, height: 18),
                    _buildStatusRow(
                      label: 'Encoding Bit Order',
                      value: 'True LSB (Bit 0 first)',
                      statusColor: Colors.purpleAccent,
                    ),
                    const Divider(color: Colors.white10, height: 18),
                    _buildStatusRow(
                      label: 'NEC Frame Format',
                      value: '00 BC CMD INV (INV = 0xFF - CMD)',
                      statusColor: Colors.cyanAccent,
                    ),
                    const Divider(color: Colors.white10, height: 18),
                    _buildStatusRow(
                      label: 'Last Sent Frame',
                      value: _irService.lastSentHex ?? 'No command sent yet',
                      statusColor: Colors.white70,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // SECTION 2: HAPTIC FEEDBACK (VIBRATION)
              _buildSectionCard(
                title: 'Haptic Feedback',
                icon: Icons.vibration_rounded,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Vibration on Tap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Tactile haptic feedback when pressing remote buttons',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  value: _settingsService.vibrationEnabled,
                  activeColor: RemoteColors.irBlue,
                  onChanged: (val) {
                    _settingsService.setVibrationEnabled(val);
                  },
                ),
              ),

              const SizedBox(height: 18),

              // SECTION 3: EXACTLY 6 CUSTOM SLOTS (ALL REAL IR COMMANDS)
              _buildSectionCard(
                title: 'Custom Buttons (6 Slots)',
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All 6 custom slots transmit real IR commands (0x00 to 0xFF). Tap Configure to customize button labels or assign specific IR codes.',
                      style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < _settingsService.customSlots.length; i++) ...[
                      _buildSlotTile(_settingsService.customSlots[i]),
                      if (i < _settingsService.customSlots.length - 1)
                        const Divider(color: Colors.white10, height: 16),
                    ],
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _settingsService.resetCustomSlotsToDefault(),
                        icon: const Icon(Icons.restore_rounded, size: 16, color: Colors.white54),
                        label: const Text(
                          'Reset All Slots to Default',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // SECTION 4: RECENT TRANSMISSIONS AUDIT LOG
              _buildSectionCard(
                title: 'Transmission Audit Log',
                icon: Icons.history_rounded,
                child: _irService.logs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No transmissions logged yet.\nTap any remote button to see packet trace.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final log in _irService.logs.take(6)) ...[
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log.hexFrame,
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
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
                        ],
                      ),
              ),

              const SizedBox(height: 18),

              // SECTION 5: ABOUT
              _buildSectionCard(
                title: 'About Walton TV Remote',
                icon: Icons.info_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Walton TV Remote v1.0.0',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• 100% Offline & Ad-Free.\n'
                      '• Carrier: 38 kHz NEC / uPD6122.\n'
                      '• Frame: 00 BC CMD INV (True LSB bit-order).\n'
                      '• Native Android ConsumerIrManager via Kotlin.\n'
                      '• Tested & optimized for Poco F6 built-in IR blaster.',
                      style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemoteColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
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
                style: const TextStyle(
                  color: Colors.white,
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
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

  Widget _buildSlotTile(CustomSlot slot) {
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
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IR Code: ${slot.irHex} (${slot.fullFrameHex})',
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF262B36),
            foregroundColor: Colors.white,
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
