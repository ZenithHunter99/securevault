import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/lockdown_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/status_indicator.dart';
import '../../common/constants/app_colors.dart';

class LockdownScreen extends ConsumerStatefulWidget {
  const LockdownScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LockdownScreen> createState() => _LockdownScreenState();
}

class _LockdownScreenState extends ConsumerState<LockdownScreen> with SingleTickerProviderStateMixin {
  bool _showConfirmation = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  late AnimationController _animationController;
  late Animation<double> _lockAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _lockAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _cancelCountdown();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _showConfirmation = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _triggerLockdown();
          _cancelCountdown();
        }
      });
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted) {
      setState(() {
        _showConfirmation = false;
      });
    }
  }

  void _triggerLockdown() {
    // Trigger the animation
    _animationController.forward();
    
    // Update the lockdown state in the provider
    Future.delayed(const Duration(milliseconds: 800), () {
      ref.read(lockdownProvider.notifier).enableLockdown();
    });
  }

  void _disableLockdown() {
    // Trigger the reverse animation
    _animationController.reverse();
    
    // Update the lockdown state in the provider
    Future.delayed(const Duration(milliseconds: 800), () {
      ref.read(lockdownProvider.notifier).disableLockdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLockdownActive = ref.watch(lockdownProvider);
    
    // Set the animation to the correct state when building
    if (isLockdownActive && _animationController.status != AnimationStatus.completed) {
      _animationController.value = 1.0;
    } else if (!isLockdownActive && _animationController.status != AnimationStatus.dismissed) {
      _animationController.value = 0.0;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/vault_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: AnimatedBuilder(
                  animation: _lockAnimation,
                  builder: (context, child) {
                    return Container(
                      color: isLockdownActive 
                          ? Color.lerp(Colors.transparent, Colors.red.withOpacity(0.15), _lockAnimation.value)
                          : Color.lerp(Colors.red.withOpacity(0.15), Colors.transparent, _lockAnimation.value),
                      child: child,
                    );
                  },
                  child: _buildContent(isLockdownActive),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 16),
          const Text(
            'Emergency Lockdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isLockdownActive) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildStatusIndicator(isLockdownActive),
          const SizedBox(height: 48),
          _buildWarningText(),
          const SizedBox(height: 64),
          if (_showConfirmation)
            _buildCountdownConfirmation()
          else
            _buildActionButton(isLockdownActive),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isLockdownActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLockdownActive ? AppColors.dangerRed : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'SYSTEM STATUS',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _lockAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: isLockdownActive
                        ? 1.0 + (_lockAnimation.value * 0.2)
                        : 1.0 + ((1 - _lockAnimation.value) * 0.2),
                    child: Text(
                      isLockdownActive ? '🔒 LOCKED' : '🔓 UNLOCKED',
                      style: TextStyle(
                        color: isLockdownActive ? AppColors.dangerRed : Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatusIndicator(
            isActive: isLockdownActive,
            activeColor: AppColors.dangerRed,
            inactiveColor: Colors.green,
            pulse: isLockdownActive,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildWarningText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'WARNING',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Activating emergency lockdown will:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildWarningItem('Suspend all financial applications'),
          _buildWarningItem('Block all outgoing transactions'),
          _buildWarningItem('Require admin verification to unlock'),
          _buildWarningItem('Notify all system administrators'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isLockdownActive) {
    return CustomButton(
      text: isLockdownActive ? 'DISABLE LOCKDOWN' : 'TRIGGER EMERGENCY LOCKDOWN',
      icon: isLockdownActive ? Icons.lock_open : Icons.lock,
      backgroundColor: isLockdownActive ? Colors.green : AppColors.dangerRed,
      onPressed: isLockdownActive ? _disableLockdown : _startCountdown,
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms);
  }

  Widget _buildCountdownConfirmation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerRed, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'CONFIRM LOCKDOWN',
            style: TextStyle(
              color: AppColors.dangerRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lockdown will activate in $_countdownSeconds seconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'CANCEL',
                  icon: Icons.cancel,
                  backgroundColor: Colors.grey[700]!,
                  onPressed: _cancelCountdown,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'ACTIVATE NOW',
                  icon: Icons.lock,
                  backgroundColor: AppColors.dangerRed,
                  onPressed: () {
                    _cancelCountdown();
                    _triggerLockdown();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}