import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// App Status Enum
enum AppStatus {
  safe,
  suspicious,
  blocked,
}

// Financial App Model
class FinancialApp {
  final String id;
  final String name;
  final String logoUrl;
  final AppStatus status;
  final DateTime lastScan;

  const FinancialApp({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.status,
    required this.lastScan,
  });

  Color get statusColor {
    switch (status) {
      case AppStatus.safe:
        return AppColors.safeGreen;
      case AppStatus.suspicious:
        return AppColors.suspiciousYellow;
      case AppStatus.blocked:
        return AppColors.blockedRed;
      default:
        return AppColors.safeGreen;
    }
  }

  String get statusText {
    switch (status) {
      case AppStatus.safe:
        return 'Safe';
      case AppStatus.suspicious:
        return 'Suspicious';
      case AppStatus.blocked:
        return 'Blocked';
      default:
        return 'Unknown';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case AppStatus.safe:
        return Icons.verified;
      case AppStatus.suspicious:
        return Icons.warning;
      case AppStatus.blocked:
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }
}

// Theme Colors
class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03A9F4);
  
  // Status colors
  static const Color safeGreen = Color(0xFF4CAF50);
  static const Color suspiciousYellow = Color(0xFFFFC107);
  static const Color blockedRed = Color(0xFFF44336);
  
  // Background colors
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  
  // Misc
  static const Color divider = Color(0xFFBDBDBD);
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data for financial apps
  final List<FinancialApp> _financialApps = [
    FinancialApp(
      id: '1',
      name: 'SBI Bank',
      logoUrl: 'assets/images/sbi_logo.png',
      status: AppStatus.safe,
      lastScan: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FinancialApp(
      id: '2',
      name: 'Paytm',
      logoUrl: 'assets/images/paytm_logo.png',
      status: AppStatus.suspicious,
      lastScan: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FinancialApp(
      id: '3',
      name: 'HDFC Bank',
      logoUrl: 'assets/images/hdfc_logo.png',
      status: AppStatus.safe,
      lastScan: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    FinancialApp(
      id: '4',
      name: 'PhonePe',
      logoUrl: 'assets/images/phonepe_logo.png',
      status: AppStatus.safe,
      lastScan: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    FinancialApp(
      id: '5',
      name: 'Google Pay',
      logoUrl: 'assets/images/gpay_logo.png',
      status: AppStatus.blocked,
      lastScan: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    FinancialApp(
      id: '6',
      name: 'ICICI Bank',
      logoUrl: 'assets/images/icici_logo.png',
      status: AppStatus.safe,
      lastScan: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  void _openAddAppDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Verified App'),
          content: const Text('Select a financial app to add to your SecureVault dashboard.'),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                // Add app logic would go here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count apps by status
    int safeApps = _financialApps.where((app) => app.status == AppStatus.safe).length;
    int suspiciousApps = _financialApps.where((app) => app.status == AppStatus.suspicious).length;
    int blockedApps = _financialApps.where((app) => app.status == AppStatus.blocked).length;
    
    // Determine overall security status
    String securityStatus = 'Secure';
    Color statusColor = AppColors.safeGreen;
    
    if (blockedApps > 0) {
      securityStatus = 'At Risk';
      statusColor = AppColors.blockedRed;
    } else if (suspiciousApps > 0) {
      securityStatus = 'Warning';
      statusColor = AppColors.suspiciousYellow;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh app statuses
          await Future.delayed(const Duration(seconds: 1));
          // In a real app, you would fetch updated data here
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSecurityStatusCard(
                securityStatus, 
                statusColor, 
                _financialApps.length, 
                safeApps, 
                suspiciousApps, 
                blockedApps
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return _buildAppCard(_financialApps[index]);
                  },
                  childCount: _financialApps.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAppDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Verified App'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSecurityStatusCard(
    String status, 
    Color statusColor,
    int totalApps,
    int safeApps,
    int suspiciousApps,
    int blockedApps,
  ) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'Secure' 
                    ? Icons.security 
                    : status == 'Warning' 
                        ? Icons.warning 
                        : Icons.error,
                color: statusColor,
                size: 42,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    'Last scan: ${_getLastScanTime()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusCounter('Total', totalApps, Colors.blue),
              _buildStatusCounter('Safe', safeApps, AppColors.safeGreen),
              _buildStatusCounter('Suspicious', suspiciousApps, AppColors.suspiciousYellow),
              _buildStatusCounter('Blocked', blockedApps, AppColors.blockedRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAppCard(FinancialApp app) {
    final formatter = DateFormat('h:mm a');
    final lastScanFormatted = formatter.format(app.lastScan);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to detail page for this app
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  app.logoUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: app.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: app.statusColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              app.statusIcon,
                              color: app.statusColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app.statusText,
                              style: TextStyle(
                                color: app.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        lastScanFormatted,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastScanTime() {
    return '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  }
}