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
                      value: _irService.hasIrEmitter ? 'Detected (Poco F6 / Hardware)' : 'Simulated / Standby',
                      statusColor: _irService.hasIrEmitter ? RemoteColors.connectedGreen : Colors.amber,
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
                    'Short tactile haptic feedback before IR transmission',
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

              // SECTION 3: EXACTLY 6 CUSTOM SLOTS (Section 10 & 16)
              _buildSectionCard(
                title: 'Custom Buttons (6 Slots)',
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign reserved Walton TV IR codes (0x15, 0x41, 0x57, 0x5A, 0x5C, 0x5D, 0x5E) to slots 1–4. Slots 5 and 6 are reserved for Video Player and Settings.',
                      style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    for (final slot in _settingsService.customSlots) ...[
                      _buildSlotTile(slot),
                      if (slot.slotIndex < 6) const Divider(color: Colors.white10, height: 16),
                    ],
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _settingsService.resetCustomSlotsToDefault(),
                        icon: const Icon(Icons.restore_rounded, size: 16, color: Colors.white54),
                        label: const Text(
                          'Reset Slots to Factory Default',
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
                      '• 0 unnecessary permissions.\n'
                      '• Carrier: 38 kHz NEC / uPD6122 (True LSB bit-order).\n'
                      '• Communicates with Android ConsumerIrManager via Kotlin MethodChannel.\n'
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
    if (slot.isAppAction) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(slot.icon, color: slot.accentColor, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot ${slot.slotIndex}: ${slot.title}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    slot.type == CustomSlotType.videoPlayer ? 'App In-App Video Player' : 'App Settings Screen',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'App Action',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(slot.icon, color: slot.accentColor, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slot ${slot.slotIndex}: ${slot.title}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Walton IR: ${slot.irHex} (00BC${slot.irCommand.toRadixString(16).padLeft(2, '0').toUpperCase()}${(0xFF - slot.irCommand).toRadixString(16).padLeft(2, '0').toUpperCase()})',
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF262B36),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _showEditSlotDialog(slot),
          child: const Text('Configure', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showEditSlotDialog(CustomSlot slot) {
    final titleController = TextEditingController(text: slot.title);
    int selectedCmd = slot.irCommand;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E222B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Configure Slot ${slot.slotIndex}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Button Label', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF16181F),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Reserved IR Code', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedCmd,
                      dropdownColor: const Color(0xFF1E222B),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF16181F),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: WaltonCommands.availableCustomCommands.map((cmd) {
                        return DropdownMenuItem<int>(
                          value: cmd.cmd,
                          child: Text(
                            '${cmd.cmdHex} (${cmd.label})',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCmd = val);
                        }
                      },
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
                    final newTitle = titleController.text.trim();
                    _settingsService.updateCustomSlot(
                      slot.slotIndex,
                      title: newTitle.isEmpty ? slot.defaultTitle : newTitle,
                      irCommand: selectedCmd,
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
