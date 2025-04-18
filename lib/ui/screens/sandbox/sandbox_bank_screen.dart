import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

class SandboxBankScreen extends StatefulWidget {
  const SandboxBankScreen({super.key});

  @override
  State<SandboxBankScreen> createState() => _SandboxBankScreenState();
}

class _SandboxBankScreenState extends State<SandboxBankScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  String _username = '';
  String _password = '';
  double _balance = 10000.00;
  String _recipient = '';
  double _amount = 0.0;
  final List<String> _securityNotifications = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _generateSecurityNotification();
  }

  Future<void> _checkLoginStatus() async {
    String? username = await _storage.read(key: 'username');
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
    }

  void _generateSecurityNotification() {
    final notifications = [
      'AI Security: Unusual login attempt blocked at ${DateTime.now().toString().substring(0, 16)}',
      'AI Security: Transaction pattern analysis completed - all clear',
      'AI Security: Device fingerprint verified',
      'AI Security: Potential phishing attempt detected and blocked',
    ];
    setState(() {
      _securityNotifications
          .add(notifications[_random.nextInt(notifications.length)]);
      if (_securityNotifications.length > 3) {
        _securityNotifications.removeAt(0);
      }
    });
  }

  Future<void> _login() async {
    if (_username.isNotEmpty && _password.isNotEmpty) {
      await _storage.write(key: 'username', value: _username);
      setState(() {
        _isLoggedIn = true;
      });
      _generateSecurityNotification();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
    }
  }

  Future<void> _sendMoney() async {
    if (_recipient.isNotEmpty && _amount > 0 && _amount <= _balance) {
      setState(() {
        _balance -= _amount;
      });
      _generateSecurityNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Sent \$${_amount.toStringAsFixed(2)} to $_recipient')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid recipient or amount exceeds balance')),
      );
    }
  }

  void _logout() async {
    await _storage.delete(key: 'username');
    setState(() {
      _isLoggedIn = false;
      _username = '';
      _password = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault Sandbox Bank'),
        backgroundColor: Colors.blueAccent,
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          const Banner(
            message: 'Sandbox',
            location: BannerLocation.topStart,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'This is a sandbox environment — no real funds involved',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: _isLoggedIn ? _buildBankInterface() : _buildLoginScreen(),
          ),
          _buildSecurityNotifications(),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _username = value,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            onChanged: (value) => _password = value,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Login', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $_username',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Send Money',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Recipient Account',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _recipient = value,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _amount = double.tryParse(value) ?? 0.0,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendMoney,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Send Money', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotifications() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Security Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._securityNotifications
              .map((notification) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '• $notification',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              ,
        ],
      ),
    );
  }
}