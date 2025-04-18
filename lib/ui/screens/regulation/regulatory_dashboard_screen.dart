import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:upayments/lib/core/models/audit_log.dart';
import 'package:upayments/lib/core/models/compliance_item.dart';
import 'package:upayments/lib/core/providers/regulatory_provider.dart';
import 'package:upayments/lib/ui/widgets/app_drawer.dart';
import 'package:upayments/lib/ui/widgets/custom_app_bar.dart';
import 'package:upayments/lib/utils/constants.dart';
import 'package:upayments/lib/utils/ui_helpers.dart';

class RegulatoryDashboardScreen extends StatefulWidget {
  static const String routeName = '/regulatory-dashboard';

  const RegulatoryDashboardScreen({super.key});

  @override
  _RegulatoryDashboardScreenState createState() => _RegulatoryDashboardScreenState();
}

class _RegulatoryDashboardScreenState extends State<RegulatoryDashboardScreen> {
  bool _isDownloadingLogs = false;
  
  @override
  void initState() {
    super.initState();
    // Load necessary data when screen initializes
    Future.microtask(() => 
      Provider.of<RegulatoryProvider>(context, listen: false).loadComplianceData()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Regulatory Compliance',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RegulatoryProvider>(context, listen: false).loadComplianceData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing compliance data...'))
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<RegulatoryProvider>(
        builder: (ctx, regulatoryProvider, child) {
          if (regulatoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildComplianceOverviewCard(regulatoryProvider),
                const SizedBox(height: 16),
                _buildPolicySyncCard(regulatoryProvider),
                const SizedBox(height: 16),
                _buildAuditLogsCard(regulatoryProvider),
                const SizedBox(height: 16),
                _buildRegulatoryAPIStatusCard(regulatoryProvider),
                const SizedBox(height: 16),
                _buildAuditTimeline(regulatoryProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplianceOverviewCard(RegulatoryProvider provider) {
    final compliantCount = provider.complianceItems
        .where((item) => item.isCompliant)
        .length;
    final totalCount = provider.complianceItems.length;
    final compliancePercentage = totalCount > 0 
        ? (compliantCount / totalCount * 100).toStringAsFixed(1) 
        : '0.0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/rbi_logo.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'RBI/NPCI Compliance Checklist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Compliance Rate: $compliancePercentage%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getComplianceStatusColor(double.parse(compliancePercentage)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getComplianceStatusText(double.parse(compliancePercentage)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: totalCount > 0 ? compliantCount / totalCount : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getComplianceStatusColor(double.parse(compliancePercentage)),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.complianceItems.length,
                  itemBuilder: (ctx, index) {
                    final item = provider.complianceItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.isCompliant ? Colors.green : Colors.red,
                            ),
                            child: Center(
                              child: Icon(
                                item.isCompliant ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySyncCard(RegulatoryProvider provider) {
    final syncStatus = provider.isPolicySynced;
    final lastSyncTime = provider.lastPolicySyncTime != null
        ? DateFormat('MMM d, yyyy HH:mm').format(provider.lastPolicySyncTime!)
        : 'Never';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: syncStatus ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  syncStatus ? Icons.sync : Icons.sync_problem,
                  size: 32,
                  color: syncStatus ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Policy Sync Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    syncStatus ? 'Synchronized' : 'Out of Sync',
                    style: TextStyle(
                      color: syncStatus ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last synced: $lastSyncTime',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<RegulatoryProvider>(context, listen: false).syncPolicies();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing policies...'))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sync Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogsCard(RegulatoryProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Icon(Icons.description, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Audit Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.auditLogs.length} logs available',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isDownloadingLogs
                          ? null
                          : () async {
                              setState(() {
                                _isDownloadingLogs = true;
                              });
                              
                              try {
                                await provider.downloadAuditLogs();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Audit logs downloaded successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to download logs: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isDownloadingLogs = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isDownloadingLogs
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.download, size: 16),
                      label: Text(_isDownloadingLogs ? 'Downloading...' : 'Download'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: provider.auditLogs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No audit logs available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.auditLogs.length > 3
                              ? 3
                              : provider.auditLogs.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
                          itemBuilder: (ctx, index) {
                            final log = provider.auditLogs[index];
                            return ListTile(
                              title: Text(
                                log.eventType,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                log.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                DateFormat('MMM d, HH:mm').format(log.timestamp),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            );
                          },
                        ),
                ),
                if (provider.auditLogs.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to detailed audit logs screen
                          Navigator.pushNamed(context, '/audit-logs');
                        },
                        child: Text(
                          'View All ${provider.auditLogs.length} Logs',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatoryAPIStatusCard(RegulatoryProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.api, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  'Regulatory API Integration Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.apiIntegrationStatuses.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                itemBuilder: (ctx, index) {
                  final status = provider.apiIntegrationStatuses[index];
                  return ListTile(
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      status.apiName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(status.description),
                    trailing: Text(
                      status.isActive ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: status.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTimeline(RegulatoryProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.tertiaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Icon(Icons.history, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Audit Timeline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: provider.auditEvents.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No audit events recorded',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.auditEvents.length,
                    itemBuilder: (ctx, index) {
                      final event = provider.auditEvents[index];
                      final bool isLastItem = index == provider.auditEvents.length - 1;
                      
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline line and dot
                            Column(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getAuditEventColor(event.status),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                if (!isLastItem)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Event content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getAuditEventColor(event.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            event.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getAuditEventColor(event.status),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy').format(event.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getComplianceStatusColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getComplianceStatusText(double percentage) {
    if (percentage >= 90) {
      return 'Compliant';
    } else if (percentage >= 70) {
      return 'Action Needed';
    } else {
      return 'Critical';
    }
  }

  Color _getAuditEventColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}