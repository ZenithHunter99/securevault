import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/bank.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/security_badge.dart';

class BankLinkingScreen extends StatefulWidget {
  const BankLinkingScreen({super.key});

  @override
  State<BankLinkingScreen> createState() => _BankLinkingScreenState();
}

class _BankLinkingScreenState extends State<BankLinkingScreen> with TickerProviderStateMixin {
  Bank? _selectedBank;
  bool _isLinking = false;
  bool _showOtpInput = false;
  bool _isLinked = false;
  String _connectionStatus = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _shieldAnimationController;
  
  // Mock list of banks
  final List<Bank> _banks = [
    Bank(id: '1', name: 'Chase', logoUrl: 'assets/images/banks/chase.png', securityLevel: 'End-to-End Encrypted'),
    Bank(id: '2', name: 'Bank of America', logoUrl: 'assets/images/banks/boa.png', securityLevel: 'Isolated Connection'),
    Bank(id: '3', name: 'Wells Fargo', logoUrl: 'assets/images/banks/wells_fargo.png', securityLevel: 'End-to-End Encrypted'),
    Bank(id: '4', name: 'Citibank', logoUrl: 'assets/images/banks/citi.png', securityLevel: 'Isolated Connection'),
    Bank(id: '5', name: 'Capital One', logoUrl: 'assets/images/banks/capital_one.png', securityLevel: 'End-to-End Encrypted'),
  ];

  @override
  void initState() {
    super.initState();
    _shieldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _shieldAnimationController.dispose();
    super.dispose();
  }

  void _showCredentialsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCredentialsModal(),
    );
  }

  Widget _buildCredentialsModal() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_selectedBank != null)
                  Image.asset(
                    _selectedBank!.logoUrl,
                    width: 32,
                    height: 32,
                  ),
                const SizedBox(width: 12),
                Text(
                  'Connect to ${_selectedBank?.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SecurityBadge(level: _selectedBank?.securityLevel ?? ''),
            const SizedBox(height: 24),
            if (!_showOtpInput) ...[
              AppTextField(
                controller: _usernameController,
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Connect',
                onPressed: _mockBankConnection,
                isLoading: _isLinking,
                icon: Icons.link,
              ),
            ] else ...[
              Text(
                'We sent a verification code to your registered device',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _otpController,
                labelText: 'Verification Code',
                prefixIcon: const Icon(Icons.security),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Verify',
                onPressed: _verifyOtp,
                isLoading: _isLinking,
                icon: Icons.check_circle,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _mockBankConnection() {
    setState(() {
      _isLinking = true;
      _connectionStatus = 'Establishing secure connection...';
    });

    // Simulate connection process
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _connectionStatus = 'Authenticating credentials...';
      });
      
      // Simulate authentication and request OTP
      Timer(const Duration(seconds: 2), () {
        if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
          setState(() {
            _isLinking = false;
            _connectionStatus = 'Connection failed. Please check your credentials.';
          });
          Navigator.pop(context);
          _showErrorSnackBar('Please enter valid credentials');
        } else {
          // Show OTP input
          setState(() {
            _showOtpInput = true;
            _isLinking = false;
            _connectionStatus = 'OTP verification required';
          });
          Navigator.pop(context);
          _showCredentialsModal();
        }
      });
    });
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      _showErrorSnackBar('Please enter the verification code');
      return;
    }

    setState(() {
      _isLinking = true;
      _connectionStatus = 'Verifying code...';
    });

    // Start shield animation
    _shieldAnimationController.reset();
    _shieldAnimationController.forward();

    // Simulate OTP verification
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isLinking = false;
        _isLinked = true;
        _connectionStatus = 'Connected securely';
      });
      Navigator.pop(context);
      _showSuccessDialog();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Connected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Colors.green,
              size: 64,
            ).animate()
              .scale(duration: 500.ms, curve: Curves.easeOut)
              .then(delay: 200.ms)
              .shake(hz: 2, curve: Curves.easeInOut),
            const SizedBox(height: 16),
            Text(
              'Your ${_selectedBank?.name} account has been successfully connected with ${_selectedBank?.securityLevel} protection.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Your Bank'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect your bank account securely',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your credentials are encrypted and never stored on our servers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bank dropdown
            DropdownButtonFormField<Bank>(
              decoration: const InputDecoration(
                labelText: 'Select your bank',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              value: _selectedBank,
              items: _banks.map((Bank bank) {
                return DropdownMenuItem<Bank>(
                  value: bank,
                  child: Row(
                    children: [
                      Image.asset(
                        bank.logoUrl,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.account_balance, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(bank.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Bank? newValue) {
                setState(() {
                  _selectedBank = newValue;
                  _isLinked = false;
                  _connectionStatus = '';
                });
              },
            ),

            const SizedBox(height: 24),
            
            // Connection status
            if (_connectionStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isLinked ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isLinked ? Colors.green : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLinking)
                      ShieldAnimation(controller: _shieldAnimationController)
                    else if (_isLinked)
                      const Icon(Icons.shield_outlined, color: Colors.green)
                    else
                      const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_connectionStatus),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Connect button
            if (_selectedBank != null && !_isLinked)
              AppButton(
                label: 'Connect to ${_selectedBank?.name}',
                onPressed: _showCredentialsModal,
                icon: Icons.account_balance,
                isFullWidth: true,
              )
            else if (_isLinked)
              AppButton(
                label: 'Disconnect Bank',
                onPressed: () {
                  setState(() {
                    _isLinked = false;
                    _connectionStatus = 'Disconnected';
                    _selectedBank = null;
                  });
                },
                icon: Icons.link_off,
                isFullWidth: true,
                buttonType: ButtonType.outlined,
              ),
          ],
        ),
      ),
    );
  }
}

// Shield animation widget for secure connection visualization
class ShieldAnimation extends StatelessWidget {
  final AnimationController controller;
  
  const ShieldAnimation({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Colors.blue[300],
            size: 24,
          ),
          Positioned.fill(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    ).animate(controller: controller)
      .fade(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
      .then(delay: 500.ms)
      .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5));
  }
}

// Security badge widget
class SecurityBadge extends StatelessWidget {
  final String level;

  const SecurityBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isEncrypted = level.toLowerCase().contains('encrypt');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEncrypted ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEncrypted ? Colors.green : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEncrypted ? Icons.lock : Icons.shield,
            size: 16,
            color: isEncrypted ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            level,
            style: TextStyle(
              color: isEncrypted ? Colors.green[700] : Colors.blue[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}