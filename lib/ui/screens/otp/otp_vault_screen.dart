import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';

class OtpVaultScreen extends StatefulWidget {
  const OtpVaultScreen({super.key});

  @override
  _OtpVaultScreenState createState() => _OtpVaultScreenState();
}

class _OtpVaultScreenState extends State<OtpVaultScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  // Mocked OTP data
  final List<Map<String, dynamic>> _otpList = [
    {'service': 'Bank of America', 'code': '123456', 'timeRemaining': 30},
    {'service': 'Chase Bank', 'code': '789012', 'timeRemaining': 15},
    {'service': 'Wells Fargo', 'code': '345678', 'timeRemaining': 45},
  ];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access OTP Vault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticated = authenticated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
    }
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP copied to clipboard')),
    );
  }

  void _addNewOtp() {
    // Implement OTP addition logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new OTP functionality')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Vault'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: const Text('AES-256 Secured'),
              avatar: const Icon(Icons.lock, size: 16),
              backgroundColor: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
      body: _isAuthenticated
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _otpList.length,
                    itemBuilder: (context, index) {
                      final otp = _otpList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(
                            FontAwesomeIcons.shieldAlt,
                            color: Colors.blue,
                          ),
                          title: Text(
                            otp['service'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Code: ${otp['code']}'),
                              LinearProgressIndicator(
                                value: otp['timeRemaining'] / 60,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.blue),
                              ),
                              Text('${otp['timeRemaining']}s remaining'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyToClipboard(otp['code']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _addNewOtp,
                    icon: const Icon(FontAwesomeIcons.plusCircle),
                    label: const Text('Securely Add OTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Vault Locked\nPlease authenticate to access OTPs',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}