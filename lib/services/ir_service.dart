import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum IrTransmissionState {
  idle,
  sending,
  success,
  failure,
}

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
  IrTransmissionState _transmissionState = IrTransmissionState.idle;
  bool? _lastTransmissionSuccess;
  String? _lastSentHex;
  String? _lastSentLabel;
  Timer? _stateResetTimer;
  final List<IrTransmissionLog> _logs = [];

  bool get isChecking => _isChecking;
  bool get hasIrEmitter => _hasIrEmitter;
  bool get isTransmitting => _isTransmitting;
  IrTransmissionState get transmissionState => _transmissionState;
  bool? get lastTransmissionSuccess => _lastTransmissionSuccess;
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

    _stateResetTimer?.cancel();
    _isTransmitting = true;
    _transmissionState = IrTransmissionState.sending;
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
      debugPrint('IR TX Failed: MethodChannel not available on this platform.');
      success = false;
      errorMsg = 'MethodChannel not available / IR Blaster not detected';
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
      _lastTransmissionSuccess = success;
      _transmissionState = success ? IrTransmissionState.success : IrTransmissionState.failure;

      // Add to audit log (keep last 50 logs)
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
      if (_logs.length > 50) {
        _logs.removeLast();
      }

      notifyListeners();

      // Reset feedback state to idle after 250ms
      _stateResetTimer = Timer(const Duration(milliseconds: 250), () {
        _transmissionState = IrTransmissionState.idle;
        notifyListeners();
      });
    }

    return success;
  }

  /// Sends a test command (Power 0x00) for hardware validation
  Future<bool> sendTestCommand() async {
    return sendCommand(0x00, label: 'Test IR (Power)');
  }

  /// Clears the IR transmission audit log
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  /// Opens an external URL via platform channel intent
  Future<bool> openExternalUrl(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('openUrl', {'url': url});
      return result ?? false;
    } catch (e) {
      debugPrint('Error opening external url: $e');
      return false;
    }
  }
}
