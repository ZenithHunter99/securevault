import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:stream_transform/stream_transform.dart';

class OtpEntry {
  final String name;
  final String issuer;
  final String secret;
  final DateTime createdAt;
  final int period;

  OtpEntry({
    required this.name,
    required this.issuer,
    required this.secret,
    required this.createdAt,
    this.period = 30,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuer': issuer,
        'secret': secret,
        'createdAt': createdAt.toIso8601String(),
        'period': period,
      };

  factory OtpEntry.fromJson(Map<String, dynamic> json) => OtpEntry(
        name: json['name'],
        issuer: json['issuer'],
        secret: json['secret'],
        createdAt: DateTime.parse(json['createdAt']),
        period: json['period'],
      );
}

class OtpManagerService {
  final List<OtpEntry> _entries = [];
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _cleanupTimer;
  bool _isAuthenticated = false;
  static const _mockKey = 'mock-aes-key-32bytes1234567890ab';
  static const _cleanupInterval = Duration(seconds: 5);
  static const _otpLifetime = Duration(minutes: 5);

  OtpManagerService() {
    _startCleanupTimer();
  }

  Stream<Map<String, dynamic>> get otpStream => _controller.stream;

  Future<bool> authenticateBiometrics() async {
    // Mock biometric authentication
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _notifyStream();
    return true;
  }

  Future<void> addOtp({
    required String name,
    required String issuer,
    required String secret,
  }) async {
    if (!_isAuthenticated) throw Exception('Not authenticated');
    
    final encryptedSecret = _mockEncrypt(secret);
    final entry = OtpEntry(
      name: name,
      issuer: issuer,
      secret: encryptedSecret,
      createdAt: DateTime.now(),
    );
    
    _entries.add(entry);
    _notifyStream();
  }

  Future<String> generateTotp(String secret) async {
    if (!_isAuthenticated) throw Exception('Not authenticated');
    
    final decryptedSecret = _mockDecrypt(secret);
    return _mockTotpGeneration(decryptedSecret);
  }

  List<OtpEntry> getEntries() {
    if (!_isAuthenticated) throw Exception('Not authenticated');
    return List.unmodifiable(_entries);
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpiredEntries();
    });
  }

  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    _entries.removeWhere((entry) =>
        now.difference(entry.createdAt) > _otpLifetime);
    _notifyStream();
  }

  String _mockEncrypt(String input) {
    // Mock AES encryption
    final key = utf8.encode(_mockKey);
    final data = utf8.encode(input);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);
    return base64Encode(digest.bytes);
  }

  String _mockDecrypt(String encrypted) {
    // Mock AES decryption (simplified)
    return base64Decode(encrypted).toString();
  }

  String _mockTotpGeneration(String secret) {
    // Mock TOTP generation
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeStep = timestamp ~/ 30;
    
    final key = utf8.encode(secret);
    final data = utf8.encode(timeStep.toString());
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(data);
    
    final offset = digest.bytes.last & 0xf;
    final binary = ((digest.bytes[offset] & 0x7f) << 24) |
                  ((digest.bytes[offset + 1] & 0xff) << 16) |
                  ((digest.bytes[offset + 2] & 0xff) << 8) |
                  (digest.bytes[offset + 3] & 0xff);
    
    final otp = binary % 1000000;
    return otp.toString().padLeft(6, '0');
  }

  void _notifyStream() {
    if (!_controller.isClosed) {
      final now = DateTime.now();
      final entriesWithTime = _entries.map((entry) {
        final remainingSeconds = entry.period -
            (now.millisecondsSinceEpoch ~/ 1000 % entry.period);
        return {
          'entry': entry,
          'remainingSeconds': remainingSeconds,
          'code': _mockTotpGeneration(_mockDecrypt(entry.secret)),
        };
      }).toList();
      
      _controller.add({
        'entries': entriesWithTime,
        'isAuthenticated': _isAuthenticated,
      });
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _controller.close();
  }
}