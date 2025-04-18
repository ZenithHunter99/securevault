import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../widgets/cyberpunk_button.dart';
import '../../theme/app_colors.dart';

class LogEntry {
  final String message;
  final DateTime timestamp;
  final LogType type;

  LogEntry({
    required this.message,
    required this.timestamp,
    required this.type,
  });
}

enum LogType {
  securityEvent,
  policyViolation,
  lockdownTrigger,
  system
}

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> with SingleTickerProviderStateMixin {
  final List<LogEntry> _allLogs = [];
  List<LogEntry> _filteredLogs = [];
  final ScrollController _scrollController = ScrollController();
  late Timer _logGenerationTimer;
  bool _autoScroll = true;
  bool _showSecurityEvents = true;
  bool _showPolicyViolations = true;
  bool _showLockdownTriggers = true;
  
  // Blinking cursor animation
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize blinking cursor animation
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_cursorController);
    
    // Generate initial logs
    _generateInitialLogs();
    _applyFilters();
    
    // Start periodic log generation
    _logGenerationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _generateRandomLog();
      if (_autoScroll && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });
    
    // Listen to scroll events to detect if user has manually scrolled up
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final bool isBottom = _scrollController.position.pixels >= 
            _scrollController.position.maxScrollExtent - 50;
        if (_autoScroll != isBottom) {
          setState(() {
            _autoScroll = isBottom;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _logGenerationTimer.cancel();
    _scrollController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  void _generateInitialLogs() {
    final List<String> initialLogs = [
      "System initialization complete",
      "Secure boot verification passed",
      "Loading security modules...",
      "Network interfaces scanning completed",
      "Perimeter defense activated",
      "Firewall rules updated",
      "Intrusion detection system online",
      "User authentication service started",
      "Policy engine initialized",
      "Secure connections established",
    ];

    final List<LogType> initialTypes = [
      LogType.system,
      LogType.securityEvent,
      LogType.system,
      LogType.system,
      LogType.securityEvent,
      LogType.policyViolation,
      LogType.securityEvent,
      LogType.system,
      LogType.policyViolation,
      LogType.lockdownTrigger,
    ];

    // Create logs with past timestamps
    DateTime now = DateTime.now();
    for (int i = 0; i < initialLogs.length; i++) {
      _allLogs.add(LogEntry(
        message: initialLogs[i],
        timestamp: now.subtract(Duration(minutes: initialLogs.length - i)),
        type: initialTypes[i],
      ));
    }
  }

  void _generateRandomLog() {
    final List<String> securityEvents = [
      "Unauthorized access attempt detected from IP 192.168.1.45",
      "Suspicious port scanning activity detected",
      "Biometric authentication failed - retry limit exceeded",
      "New device connected to network - MAC:F4:5C:89:B2:A3:E1",
      "Security certificate verification failed",
      "Encrypted communication channel established",
    ];

    final List<String> policyViolations = [
      "User attempted to access restricted area",
      "Data exfiltration attempt blocked",
      "Policy violation: Unauthorized software installation",
      "Resource usage exceeds allocated threshold",
      "Access violation: Insufficient clearance level",
      "Configuration drift detected in security parameters",
    ];

    final List<String> lockdownTriggers = [
      "CRITICAL: Multiple authentication failures detected",
      "ALERT: Brute force attack detected, initiating lockdown",
      "EMERGENCY: Perimeter breach at sector 7",
      "WARNING: System integrity compromised",
      "DANGER: Malicious code execution attempted",
      "CRITICAL: Manual override initiated by admin",
    ];

    final random = DateTime.now().millisecondsSinceEpoch % 3;
    LogType type;
    String message;

    switch (random) {
      case 0:
        type = LogType.securityEvent;
        message = securityEvents[DateTime.now().second % securityEvents.length];
        break;
      case 1:
        type = LogType.policyViolation;
        message = policyViolations[DateTime.now().second % policyViolations.length];
        break;
      default:
        type = LogType.lockdownTrigger;
        message = lockdownTriggers[DateTime.now().second % lockdownTriggers.length];
    }

    setState(() {
      _allLogs.add(LogEntry(
        message: message,
        timestamp: DateTime.now(),
        type: type,
      ));
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        if (log.type == LogType.securityEvent && !_showSecurityEvents) return false;
        if (log.type == LogType.policyViolation && !_showPolicyViolations) return false;
        if (log.type == LogType.lockdownTrigger && !_showLockdownTriggers) return false;
        return true;
      }).toList();
    });
  }

  void _clearLogs() {
    setState(() {
      _allLogs.clear();
      _filteredLogs.clear();
    });
  }

  Future<void> _downloadLogs() async {
    // In a real app, this would save logs to a file
    // For now, we'll just show a snackbar
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs downloaded to device storage'),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Add a fake log entry for the download
    setState(() {
      _allLogs.add(LogEntry(
        message: "Log archive exported to secure storage",
        timestamp: DateTime.now(),
        type: LogType.system,
      ));
      _applyFilters();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.securityEvent:
        return AppColors.accentBlue;
      case LogType.policyViolation:
        return AppColors.accentYellow;
      case LogType.lockdownTrigger:
        return AppColors.accentRed;
      case LogType.system:
        return AppColors.accentGreen;
    }
  }

  String _getLogPrefix(LogType type) {
    switch (type) {
      case LogType.securityEvent:
        return "[SEC]";
      case LogType.policyViolation:
        return "[POL]";
      case LogType.lockdownTrigger:
        return "[LCK]";
      case LogType.system:
        return "[SYS]";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSecondary,
        title: const Text(
          'SYSTEM LOGS',
          style: TextStyle(
            fontFamily: 'ShareTechMono',
            letterSpacing: 2.0,
            color: AppColors.accentGreen,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.accentBlue),
            onPressed: () {
              // Show advanced settings dialog
              // In a real app, this could show additional filtering options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildLogList(),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.darkSecondary.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Security Events',
                    selected: _showSecurityEvents,
                    onSelected: (value) {
                      setState(() {
                        _showSecurityEvents = value;
                        _applyFilters();
                      });
                    },
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Policy Violations',
                    selected: _showPolicyViolations,
                    onSelected: (value) {
                      setState(() {
                        _showPolicyViolations = value;
                        _applyFilters();
                      });
                    },
                    color: AppColors.accentYellow,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Lockdown Triggers',
                    selected: _showLockdownTriggers,
                    onSelected: (value) {
                      setState(() {
                        _showLockdownTriggers = value;
                        _applyFilters();
                      });
                    },
                    color: AppColors.accentRed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required Color color,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : color,
          fontFamily: 'ShareTechMono',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppColors.darkBackground,
      selectedColor: color,
      checkmarkColor: Colors.black,
      side: BorderSide(color: color, width: 1),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildLogList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildTerminalHeader(),
          Expanded(
            child: _filteredLogs.isEmpty
                ? _buildEmptyLogs()
                : _buildLogsListView(),
          ),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.accentGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '// SECURE TERMINAL //  ',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontFamily: 'ShareTechMono',
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              'cyberguard@defense:~# tail -f /var/log/system.log',
              style: TextStyle(
                color: AppColors.accentGreen.withOpacity(0.7),
                fontFamily: 'ShareTechMono',
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.terminal,
            size: 60,
            color: AppColors.accentGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No logs to display',
            style: TextStyle(
              color: AppColors.accentGreen.withOpacity(0.7),
              fontFamily: 'ShareTechMono',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust filters or wait for new logs',
            style: TextStyle(
              color: AppColors.accentGreen.withOpacity(0.5),
              fontFamily: 'ShareTechMono',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsListView() {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent
          ],
          stops: const [0.0, 0.05, 0.95, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _filteredLogs.length,
        itemBuilder: (context, index) {
          final log = _filteredLogs[index];
          final timeFormat = DateFormat('HH:mm:ss');
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${timeFormat.format(log.timestamp)}] ',
                  style: const TextStyle(
                    color: Color(0xFF7D8CA3),
                    fontFamily: 'ShareTechMono',
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${_getLogPrefix(log.type)} ',
                  style: TextStyle(
                    color: _getLogColor(log.type),
                    fontFamily: 'ShareTechMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    log.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'ShareTechMono',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSecondary.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: AppColors.accentGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CyberpunkButton(
            onPressed: _downloadLogs,
            icon: Icons.download,
            label: 'Download Logs',
            color: AppColors.accentBlue,
            height: 36,
          ),
          CyberpunkButton(
            onPressed: _clearLogs,
            icon: Icons.delete_outline,
            label: 'Clear Logs',
            color: AppColors.accentRed,
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.darkBackground,
      child: Row(
        children: [
          Icon(
            _autoScroll ? Icons.auto_mode : Icons.lock_outline,
            size: 14,
            color: _autoScroll ? AppColors.accentGreen : AppColors.accentYellow,
          ),
          const SizedBox(width: 8),
          Text(
            _autoScroll ? 'AUTO-SCROLL ACTIVE' : 'SCROLL LOCKED',
            style: TextStyle(
              color: _autoScroll ? AppColors.accentGreen : AppColors.accentYellow,
              fontFamily: 'ShareTechMono',
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            'LOGS: ${_filteredLogs.length}/${_allLogs.length}',
            style: const TextStyle(
              color: AppColors.accentBlue,
              fontFamily: 'ShareTechMono',
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          // Blinking cursor
          FadeTransition(
            opacity: _cursorAnimation,
            child: const Text(
              '█',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontFamily: 'ShareTechMono',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}