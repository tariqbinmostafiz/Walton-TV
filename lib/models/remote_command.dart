/// Confirmed Walton TV IR commands strictly matching Section 8 of Master Specification.
/// Protocol: 38 kHz NEC / uPD6122
/// Frame: 0x00 0xBC CMD (0xFF - CMD)
/// Transmission: True LSB (Bit 0 first)

class RemoteCommand {
  final String id;
  final String label;
  final int cmd;
  final String description;

  const RemoteCommand({
    required this.id,
    required this.label,
    required this.cmd,
    required this.description,
  });

  /// Inverse byte: 0xFF - CMD
  int get inv => 0xFF - cmd;

  /// Full 32-bit frame packed hex string: "00BC{CMD}{INV}"
  String get packedHex =>
      '00BC${cmd.toRadixString(16).padLeft(2, '0').toUpperCase()}${inv.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  String get cmdHex =>
      '0x${cmd.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  @override
  String toString() => '$label ($cmdHex -> $packedHex)';
}

class WaltonCommands {
  // Core Confirmed Commands (Section 8)
  static const power = RemoteCommand(
    id: 'power',
    label: 'Power',
    cmd: 0x00,
    description: 'Toggle TV Power',
  );

  static const mute = RemoteCommand(
    id: 'mute',
    label: 'Mute',
    cmd: 0x01,
    description: 'Toggle Audio Mute',
  );

  static const picture = RemoteCommand(
    id: 'picture',
    label: 'Picture',
    cmd: 0x02,
    description: 'Picture Mode Presets',
  );

  static const sound = RemoteCommand(
    id: 'sound',
    label: 'Sound',
    cmd: 0x03,
    description: 'Sound Mode Presets',
  );

  static const num1 = RemoteCommand(id: '1', label: '1', cmd: 0x05, description: 'Digit 1');
  static const num2 = RemoteCommand(id: '2', label: '2', cmd: 0x06, description: 'Digit 2');
  static const num3 = RemoteCommand(id: '3', label: '3', cmd: 0x07, description: 'Digit 3');
  static const num4 = RemoteCommand(id: '4', label: '4', cmd: 0x08, description: 'Digit 4');
  static const num5 = RemoteCommand(id: '5', label: '5', cmd: 0x09, description: 'Digit 5');
  static const num6 = RemoteCommand(id: '6', label: '6', cmd: 0x0A, description: 'Digit 6');
  static const num7 = RemoteCommand(id: '7', label: '7', cmd: 0x0B, description: 'Digit 7');
  static const num8 = RemoteCommand(id: '8', label: '8', cmd: 0x0C, description: 'Digit 8');
  static const num9 = RemoteCommand(id: '9', label: '9', cmd: 0x0D, description: 'Digit 9');
  static const num0 = RemoteCommand(id: '0', label: '0', cmd: 0x42, description: 'Digit 0');

  static const ok = RemoteCommand(
    id: 'ok',
    label: 'OK',
    cmd: 0x10,
    description: 'Confirm / OK Selection',
  );

  static const left = RemoteCommand(
    id: 'left',
    label: 'Left',
    cmd: 0x11,
    description: 'Navigate Left',
  );

  static const right = RemoteCommand(
    id: 'right',
    label: 'Right',
    cmd: 0x12,
    description: 'Navigate Right',
  );

  static const up = RemoteCommand(
    id: 'up',
    label: 'Up',
    cmd: 0x13,
    description: 'Navigate Up',
  );

  static const down = RemoteCommand(
    id: 'down',
    label: 'Down',
    cmd: 0x14,
    description: 'Navigate Down',
  );

  static const display = RemoteCommand(
    id: 'display',
    label: 'Display',
    cmd: 0x16,
    description: 'OSD Info / Display Details',
  );

  static const menu = RemoteCommand(
    id: 'menu',
    label: 'Menu',
    cmd: 0x40,
    description: 'TV Main Menu',
  );

  static const source = RemoteCommand(
    id: 'source',
    label: 'Source',
    cmd: 0x43,
    description: 'Input Signal Source Selection',
  );

  static const recallBack = RemoteCommand(
    id: 'recall_back',
    label: 'Back / Recall',
    cmd: 0x44,
    description: 'Return to previous channel or screen',
  );

  static const home = RemoteCommand(
    id: 'home',
    label: 'Home',
    cmd: 0x45,
    description: 'Smart TV Home Screen',
  );

  static const exit = RemoteCommand(
    id: 'exit',
    label: 'Exit',
    cmd: 0x47,
    description: 'Exit Current Menu',
  );

  static const volUp = RemoteCommand(
    id: 'vol_up',
    label: 'VOL +',
    cmd: 0x48,
    description: 'Increase Volume',
  );

  static const volDown = RemoteCommand(
    id: 'vol_down',
    label: 'VOL -',
    cmd: 0x49,
    description: 'Decrease Volume',
  );

  static const chUp = RemoteCommand(
    id: 'ch_up',
    label: 'CH +',
    cmd: 0x4A,
    description: 'Next Channel',
  );

  static const chDown = RemoteCommand(
    id: 'ch_down',
    label: 'CH -',
    cmd: 0x4B,
    description: 'Previous Channel',
  );

  static const netflix = RemoteCommand(
    id: 'netflix',
    label: 'Netflix',
    cmd: 0x50,
    description: 'Launch Netflix TV App',
  );

  static const playPause = RemoteCommand(
    id: 'play_pause',
    label: 'Play / Pause',
    cmd: 0x52,
    description: 'Toggle Play / Pause Media',
  );

  static const rewind = RemoteCommand(
    id: 'rewind',
    label: 'Rewind',
    cmd: 0x54,
    description: 'Fast Backward Media',
  );

  static const forward = RemoteCommand(
    id: 'forward',
    label: 'Forward',
    cmd: 0x55,
    description: 'Fast Forward Media',
  );

  static const next = RemoteCommand(
    id: 'next',
    label: 'Next',
    cmd: 0x58,
    description: 'Next Media Track',
  );

  static const sleep = RemoteCommand(
    id: 'sleep',
    label: 'Sleep',
    cmd: 0x5B,
    description: 'TV Sleep Timer',
  );

  /// CRITICAL (Section 13 & 15):
  /// YouTube button sends Walton TV IR command 0x60.
  /// It MUST NOT launch the phone's YouTube app!
  static const youtube = RemoteCommand(
    id: 'youtube',
    label: 'YouTube',
    cmd: 0x60,
    description: 'Walton TV YouTube App (Sends IR 0x60)',
  );

  static const youtubeBack = RemoteCommand(
    id: 'youtube_back',
    label: 'YouTube Back',
    cmd: 0x62,
    description: 'YouTube Back Navigation',
  );

  static const videoRestart = RemoteCommand(
    id: 'video_restart',
    label: 'Video Restart',
    cmd: 0x63,
    description: 'Restart Video from Beginning',
  );

  static const mousePointer = RemoteCommand(
    id: 'mouse_pointer',
    label: 'Mouse Pointer',
    cmd: 0x6A,
    description: 'Toggle Air-Mouse / Pointer',
  );

  static const subtitle = RemoteCommand(
    id: 'subtitle',
    label: 'Subtitle',
    cmd: 0x75,
    description: 'Closed Captions / Subtitles',
  );

  /// Media / File Manager primary confirmed command 0x74
  static const fileManager = RemoteCommand(
    id: 'file_manager',
    label: 'File Manager',
    cmd: 0x74,
    description: 'Open USB Media / File Manager',
  );

  /// Alternate tested File Manager command 0x7A (kept in database)
  static const fileManagerAlt = RemoteCommand(
    id: 'file_manager_alt',
    label: 'File Manager (Alt)',
    cmd: 0x7A,
    description: 'Alternate USB Media Browser',
  );

  static const hdmi = RemoteCommand(
    id: 'hdmi',
    label: 'HDMI',
    cmd: 0x7B,
    description: 'Switch HDMI 1 / HDMI 2',
  );

  static const av = RemoteCommand(
    id: 'av',
    label: 'AV',
    cmd: 0x7C,
    description: 'Switch AV Composite Input',
  );

  static const vga = RemoteCommand(
    id: 'vga',
    label: 'VGA',
    cmd: 0x7F,
    description: 'Switch VGA PC Input',
  );

  /// CRITICAL (Section 14):
  /// TV System Settings is Walton TV IR command 0x90.
  /// This is separate from local app settings!
  static const tvSettings = RemoteCommand(
    id: 'tv_settings',
    label: 'TV Settings',
    cmd: 0x90,
    description: 'Walton TV System Settings Menu (Sends IR 0x90)',
  );

  static const eShare = RemoteCommand(
    id: 'eshare',
    label: 'e-Share',
    cmd: 0x9A,
    description: 'Walton e-Share Screen Cast',
  );

  /// The 7 detected unused IR commands available for Custom Slots (Section 10 & 16)
  static const List<RemoteCommand> availableCustomCommands = [
    RemoteCommand(id: 'custom_15', label: 'Custom Code 0x15', cmd: 0x15, description: 'Reserved Custom Slot 1 default'),
    RemoteCommand(id: 'custom_41', label: 'Custom Code 0x41', cmd: 0x41, description: 'Reserved Custom Slot 2 default'),
    RemoteCommand(id: 'custom_57', label: 'Custom Code 0x57', cmd: 0x57, description: 'Reserved Custom Slot 3 default'),
    RemoteCommand(id: 'custom_5a', label: 'Custom Code 0x5A', cmd: 0x5A, description: 'Reserved Custom Slot 4 default'),
    RemoteCommand(id: 'custom_5c', label: 'Custom Code 0x5C', cmd: 0x5C, description: 'Reserved Custom Alternative'),
    RemoteCommand(id: 'custom_5d', label: 'Custom Code 0x5D', cmd: 0x5D, description: 'Reserved Custom Alternative'),
    RemoteCommand(id: 'custom_5e', label: 'Custom Code 0x5E', cmd: 0x5E, description: 'Reserved Custom Alternative'),
  ];
}
