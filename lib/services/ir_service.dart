import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IrTransmissionLog {
  final int command;
  final String label;
  final String hexFrame;
  final bool success;
  final DateTime timestamp;
  final String? errorMessage;

  IrTransmissionLog({
    required this.command,
    required this.label,
    required this.hexFrame,
    required this.success,
    required this.timestamp,
    this.errorMessage,
  });
}

class IrService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('walton_tv_ir');
  static final IrService _instance = IrService._internal();

  factory IrService() => _instance;
  IrService._internal();

  bool _isChecking = false;
  bool _hasIrEmitter = false;
  bool _isTransmitting = false;
  String? _lastSentHex;
  String? _lastSentLabel;
  final List<IrTransmissionLog> _logs = [];

  bool get isChecking => _isChecking;
  bool get hasIrEmitter => _hasIrEmitter;
  bool get isTransmitting => _isTransmitting;
  String? get lastSentHex => _lastSentHex;
  String? get lastSentLabel => _lastSentLabel;
  List<IrTransmissionLog> get logs => List.unmodifiable(_logs);

  /// Initializes and checks device IR emitter availability
  Future<bool> checkIrEmitter() async {
    _isChecking = true;
    notifyListeners();

    try {
      final result = await _channel.invokeMethod<bool>('hasIrEmitter');
      _hasIrEmitter = result ?? false;
    } on MissingPluginException {
      // Running on web, desktop, or preview without platform channel
      debugPrint('MethodChannel walton_tv_ir not implemented on current platform.');
      _hasIrEmitter = false;
    } catch (e) {
      debugPrint('Error checking IR emitter: $e');
      _hasIrEmitter = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }

    return _hasIrEmitter;
  }

  /// Sends a Walton TV IR command (0x00 to 0xFF)
  /// Frame format: 0x00 0xBC CMD (0xFF - CMD)
  /// Carrier: 38 kHz, True LSB bit order
  Future<bool> sendCommand(int command, {String label = 'Command'}) async {
    if (command < 0 || command > 0xFF) {
      debugPrint('Invalid IR command: $command. Must be 0x00..0xFF');
      return false;
    }

    final int inv = 0xFF - command;
    final String hexFrame =
        '00BC${command.toRadixString(16).padLeft(2, '0').toUpperCase()}${inv.toRadixString(16).padLeft(2, '0').toUpperCase()}';

    _isTransmitting = true;
    _lastSentHex = hexFrame;
    _lastSentLabel = label;
    notifyListeners();

    bool success = false;
    String? errorMsg;

    try {
      final result = await _channel.invokeMethod<bool>(
        'sendCommand',
        {'command': command},
      );
      success = result ?? false;
    } on MissingPluginException {
      // In simulator / preview environment where Kotlin platform plugin isn't active
      debugPrint('Simulated IR TX: $label -> Frame $hexFrame (MethodChannel not attached)');
      success = true; // Mark as visually successful in UI
      errorMsg = 'IR Blaster not detected (Simulated mode)';
    } on PlatformException catch (e) {
      debugPrint('PlatformException sending IR: ${e.message}');
      success = false;
      errorMsg = e.message ?? 'Transmission failed';
    } catch (e) {
      debugPrint('Unexpected error sending IR: $e');
      success = false;
      errorMsg = e.toString();
    } finally {
      _isTransmitting = false;

      // Add to audit log (keep last 20 logs)
      _logs.insert(
        0,
        IrTransmissionLog(
          command: command,
          label: label,
          hexFrame: hexFrame,
          success: success,
          timestamp: DateTime.now(),
          errorMessage: errorMsg,
        ),
      );
      if (_logs.length > 20) {
        _logs.removeLast();
      }

      notifyListeners();
    }

    return success;
  }
}
