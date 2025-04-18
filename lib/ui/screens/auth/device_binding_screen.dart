import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceBindingScreen extends StatefulWidget {
  const DeviceBindingScreen({super.key});

  @override
  State<DeviceBindingScreen> createState() => _DeviceBindingScreenState();
}

class _DeviceBindingScreenState extends State<DeviceBindingScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isVerified = false;
  bool _isCompromised = false;
  bool _isRooted = false;
  String _deviceUID = '';
  String _attestationStatus = 'Initializing...';
  List<String> _verificationLogs = [];

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat();

    // Simulate device verification process
    _startDeviceVerification();
  }

  void _startDeviceVerification() {
    setState(() {
      _isLoading = true;
      _isVerified = false;
      _verificationLogs = [];
      _attestationStatus = 'Initializing hardware attestation...';
    });

    _addLog('Starting device verification');
    _addLog('Initializing secure hardware interface');

    // Generate a mock hardware UID
    final uidBytes = List.generate(8, (_) => math.Random().nextInt(256));
    _deviceUID = uidBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
    
    _verificationTimer?.cancel();
    _verificationTimer = Timer(const Duration(seconds: 1), () {
      _addLog('Device UID: $_deviceUID');
      _addLog('Checking hardware integrity');
      
      _verificationTimer = Timer(const Duration(seconds: 1), () {
        _addLog('Verifying bootloader status');
        
        // Randomly simulate a rooted device (20% chance)
        _isRooted = math.Random().nextDouble() < 0.2;
        if (_isRooted) {
          _addLog('WARNING: Bootloader unlocked detected', isWarning: true);
        } else {
          _addLog('Bootloader verified: Locked');
        }
        
        _verificationTimer = Timer(const Duration(seconds: 1), () {
          _addLog('Running system integrity check');
          
          // Randomly simulate compromised device (10% chance)
          _isCompromised = math.Random().nextDouble() < 0.1;
          if (_isCompromised) {
            _addLog('WARNING: System integrity verification failed', isWarning: true);
          } else {
            _addLog('System integrity verified');
          }
          
          _verificationTimer = Timer(const Duration(seconds: 1), () {
            _addLog('Generating attestation certificate');
            
            _verificationTimer = Timer(const Duration(seconds: 1), () {
              // Finalize verification
              setState(() {
                _isLoading = false;
                _isVerified = !(_isRooted || _isCompromised);
                _attestationStatus = _isVerified
                    ? 'Device verification complete'
                    : 'Device verification failed';
                _animationController.stop();
              });
              
              _addLog(_isVerified
                  ? 'Device attestation successful'
                  : 'Device attestation failed');
            });
          });
        });
      });
    });
  }

  void _addLog(String message, {bool isWarning = false}) {
    setState(() {
      _verificationLogs.add(message);
      if (isWarning) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Secure Device Registration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF122640),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_isLoading)
                          AnimatedBuilder(
                            animation: _rotationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: const Icon(
                                  Icons.security,
                                  color: Colors.blueAccent,
                                  size: 48,
                                ),
                              );
                            },
                          )
                        else if (_isVerified)
                          const Icon(
                            Icons.verified_user,
                            color: Colors.greenAccent,
                            size: 48,
                          )
                        else
                          const Icon(
                            Icons.gpp_bad,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _attestationStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Device UID: $_deviceUID',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isRooted || _isCompromised) 
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text(
                                  'SECURITY ALERT',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRooted
                                  ? 'This device has been rooted or has an unlocked bootloader.'
                                  : 'System integrity check failed. Device may be compromised.',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Security features may be restricted.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Verification logs
              const Text(
                'Verification Log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2137),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E3A5F),
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _verificationLogs.length,
                    itemBuilder: (context, index) {
                      final log = _verificationLogs[index];
                      final isWarning = log.contains('WARNING:');
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: TextStyle(
                                color: isWarning ? Colors.redAccent : Colors.greenAccent,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: isWarning ? Colors.redAccent : Colors.white70,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startDeviceVerification,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Verification'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isVerified
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: _isVerified
                              ? const Color(0xFF43A047)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}