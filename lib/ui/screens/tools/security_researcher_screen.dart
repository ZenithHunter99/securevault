import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'dart:async';
import 'dart:math';

class SecurityResearcherScreen extends StatefulWidget {
  const SecurityResearcherScreen({super.key});

  @override
  State<SecurityResearcherScreen> createState() => _SecurityResearcherScreenState();
}

class _SecurityResearcherScreenState extends State<SecurityResearcherScreen> with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;
  String _terminalOutput = '';
  late AnimationController _matrixAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _matrixAnim = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _fadeAnim = Tween<double>(begin: 0.2, end: 1.0).animate(_matrixAnim);
    _runMatrixEffect();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _matrixAnim.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    final canAuthenticate = await BiometricStorage().canAuthenticate();
    setState(() => _isBiometricAvailable = canAuthenticate == CanAuthenticateResponse.success);
  }

  Future<bool> _authenticate() async {
    if (_isBiometricAvailable) {
      try {
        final storage = await BiometricStorage().getStorage('researcher_access');
        await storage.write('authenticated');
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  void _runMatrixEffect() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isAuthenticated) return;
      final random = Random();
      final chars = '01xZ@#\$%*+-=><';
      final line = List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
      setState(() {
        _terminalOutput = '[$line]\n$_terminalOutput';
        if (_terminalOutput.length > 1000) {
          _terminalOutput = _terminalOutput.substring(0, 1000);
        }
      });
    });
  }

  void _verifyPin(String pin) {
    // Mock dev PIN: 1337
    if (pin == '1337') {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN', style: TextStyle(color: Colors.red))),
      );
    }
  }

  Widget _buildLockedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚠️ RESTRICTED ACCESS',
            style: TextStyle(color: Colors.red, fontSize: 24, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 20),
          if (_isBiometricAvailable)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900),
              onPressed: () async {
                if (await _authenticate()) {
                  setState(() => _isAuthenticated = true);
                }
              },
              child: const Text('Biometric Unlock', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'DEV PIN',
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.green, fontFamily: 'Courier'),
              onSubmitted: _verifyPin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String label, VoidCallback onPressed) {
    final obfuscatedLabel = label.split('').map((c) => Random().nextBool() ? c : String.fromCharCode(c.codeUnitAt(0) ^ 0x1)).join();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(color: Colors.green),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(
          obfuscatedLabel,
          style: const TextStyle(color: Colors.green, fontFamily: 'Courier', fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResearcherView() {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.green.shade900.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.red.withOpacity(0.8),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    '⚠️ RESEARCHER MODE ENABLED',
                    style: TextStyle(color: Colors.black, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ROOT@SYSTEM:/#',
                      style: TextStyle(color: Colors.green, fontFamily: 'Courier', fontSize: 18),
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        color: Colors.black.withOpacity(0.8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _terminalOutput.isEmpty ? '[INITIALIZING...]' : _terminalOutput,
                          style: const TextStyle(color: Colors.green, fontFamily: 'Courier'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildToolButton('DUMP_PERMS', () {
                      setState(() {
                        _terminalOutput = '[PERMS] android.permission.*: GRANTED\n$_terminalOutput';
                      });
                    }),
                    _buildToolButton('ENV_VIEW', () {
                      setState(() {
                        _terminalOutput = '[ENV] PATH=/system/bin;USER=root\n$_terminalOutput';
                      });
                    }),
                    _buildToolButton('TAMPER_SCAN', () {
                      setState(() {
                        _terminalOutput = '[SCAN] No tampering detected\n$_terminalOutput';
                      });
                    }),
                    _buildToolButton('SYS_FILES', () {
                      setState(() {
                        _terminalOutput = '[FILES] /system/build.prop\n$_terminalOutput';
                      });
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isAuthenticated ? _buildResearcherView() : _buildLockedView(),
      ),
    );
  }
}