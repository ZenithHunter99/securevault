// lib/ui/screens/security/security_alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_bar.dart';

// ThreatSeverity enum
enum ThreatSeverity { Critical, High, Medium, Low }

// ThreatEvent model
class ThreatEvent {
  final String id;
  final DateTime timestamp;
  final String appAffected;
  final String threatType;
  final ThreatSeverity severity;
  final String description;

  ThreatEvent({
    required this.id,
    required this.timestamp,
    required this.appAffected,
    required this.threatType,
    required this.severity,
    required this.description,
  });
}

// Mock Data Service
class MockDataService {
  final Random _random = Random();
  
  Future<List<ThreatEvent>> getThreatEvents() async {
    // Generate mock security threat events
    final List<ThreatEvent> events = [];
    
    // Threat types
    final threatTypes = [
      'Screen Recording',
      'Network Scanning',
      'Unauthorized Access',
      'Data Exfiltration',
      'Malware Detected',
    ];
    
    // App names
    final appNames = [
      'Chrome Browser',
      'System Service',
      'Network Manager',
      'File Manager',
      'Unknown Process',
      'Media Player',
      'Firefox Browser',
      'Package Installer',
    ];
    
    // Generate 20-35 random events
    final count = _random.nextInt(15) + 20;
    
    for (int i = 0; i < count; i++) {
      final severity = ThreatSeverity.values[_random.nextInt(ThreatSeverity.values.length)];
      
      // Create random timestamp within the last 30 days, newer events more common
      final daysAgo = _exponentialRandom(30);
      final hoursAgo = _random.nextInt(24);
      final minutesAgo = _random.nextInt(60);
      
      final timestamp = DateTime.now().subtract(
        Duration(days: daysAgo, hours: hoursAgo, minutes: minutesAgo),
      );
      
      events.add(ThreatEvent(
        id: 'THREAT-${10000 + i}',
        timestamp: timestamp,
        appAffected: appNames[_random.nextInt(appNames.length)],
        threatType: threatTypes[_random.nextInt(threatTypes.length)],
        severity: severity,
        description: _generateDescription(severity),
      ));
    }
    
    return events;
  }
  
  // Generate more recent events with higher probability
  int _exponentialRandom(int max) {
    final double exp = _random.nextDouble();
    return (exp * exp * max).floor();
  }
  
  String _generateDescription(ThreatSeverity severity) {
    switch (severity) {
      case ThreatSeverity.Critical:
        return 'Active security breach detected. Immediate action required.';
      case ThreatSeverity.High:
        return 'Suspicious activity identified that may compromise container security.';
      case ThreatSeverity.Medium:
        return 'Potential security issue detected requiring investigation.';
      case ThreatSeverity.Low:
        return 'Minor security event logged for auditing purposes.';
    }
  }
}

// Main Security Alerts Screen Widget
class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  final MockDataService _dataService = MockDataService();
  List<ThreatEvent> _threatEvents = [];
  List<ThreatEvent> _filteredEvents = [];
  bool _autoRefresh = false;
  String _selectedSeverity = 'All';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;
  late final DateFormat _dateFormat;
  late final DateFormat _timeFormat;
  
  // For the refresh timer
  final int _refreshInterval = 30; // seconds
  int _refreshCountdown = 30;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('MMM dd, yyyy');
    _timeFormat = DateFormat('HH:mm:ss');
    _loadEvents();

    // Start refreshing if auto-refresh is enabled
    Future.delayed(const Duration(milliseconds: 100), () {
      _startCountdown();
    });
  }

  void _startCountdown() {
    if (!_autoRefresh || _isCountingDown) return;
    
    _isCountingDown = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _refreshCountdown--;
        if (_refreshCountdown <= 0) {
          _refreshCountdown = _refreshInterval;
          _loadEvents();
        }
      });
      
      _isCountingDown = false;
      _startCountdown();
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Get mock data
    final events = await _dataService.getThreatEvents();
    
    setState(() {
      _threatEvents = events;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _threatEvents.where((event) {
        // Apply severity filter
        if (_selectedSeverity != 'All' && 
            event.severity.toString() != 'ThreatSeverity.$_selectedSeverity') {
          return false;
        }
        
        // Apply date filter
        final eventDate = event.timestamp;
        return eventDate.isAfter(_startDate) && 
               eventDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();
      
      // Sort by timestamp (most recent first)
      _filteredEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppScaffold(
      appBar: CustomAppBar(
        title: 'Security Alerts',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Refresh now',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(theme),
          _buildAutoRefreshBar(theme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.security,
                              size: 64,
                              color: theme.colorScheme.secondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No security alerts found',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : _buildAlertsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Filters', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSeverityDropdown(theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateRangeSelector(theme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Severity', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSeverity,
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value!;
                  _applyFilters();
                });
              },
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Severities')),
                DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                DropdownMenuItem(value: 'High', child: Text('High')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Low', child: Text('Low')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final DateTimeRange? result = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              initialDateRange: DateTimeRange(
                start: _startDate,
                end: _endDate,
              ),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: theme.colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (result != null) {
              setState(() {
                _startDate = result.start;
                _endDate = result.end;
                _applyFilters();
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.dividerColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoRefreshBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Switch(
            value: _autoRefresh,
            onChanged: (value) {
              setState(() {
                _autoRefresh = value;
                _refreshCountdown = _refreshInterval;
                if (_autoRefresh) {
                  _startCountdown();
                }
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Auto-refresh',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          if (_autoRefresh)
            Text(
              'Next refresh in $_refreshCountdown s',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          const Spacer(),
          Text(
            '${_filteredEvents.length} alerts',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredEvents.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildAlertItem(event, theme);
      },
    );
  }

  Widget _buildAlertItem(ThreatEvent event, ThemeData theme) {
    Color severityColor;
    IconData severityIcon;
    IconData threatIcon;
    
    // Set color based on severity
    switch (event.severity) {
      case ThreatSeverity.Critical:
        severityColor = Colors.red;
        severityIcon = Icons.warning_amber;
        break;
      case ThreatSeverity.High:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case ThreatSeverity.Medium:
        severityColor = Colors.amber;
        severityIcon = Icons.info;
        break;
      case ThreatSeverity.Low:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
        break;
    }
    
    // Set icon based on threat type
    switch (event.threatType) {
      case 'Screen Recording':
        threatIcon = Icons.screen_record;
        break;
      case 'Network Scanning':
        threatIcon = Icons.wifi_scan;
        break;
      case 'Unauthorized Access':
        threatIcon = Icons.no_encryption;
        break;
      case 'Data Exfiltration':
        threatIcon = Icons.file_download;
        break;
      case 'Malware Detected':
        threatIcon = Icons.bug_report;
        break;
      default:
        threatIcon = Icons.security;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        // Navigate to details view would go here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing details for alert ID: ${event.id}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            threatIcon,
            size: 28,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 1.5),
              ),
              child: Icon(
                severityIcon,
                size: 14,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              event.threatType,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: severityColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              event.severity.toString().split('.').last,
              style: theme.textTheme.bodySmall?.copyWith(
                color: severityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.apps,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'App: ${event.appAffected}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${_dateFormat.format(event.timestamp)} at ${_timeFormat.format(event.timestamp)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}