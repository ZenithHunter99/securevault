import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../../services/backup_service.dart';

class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  _CloudBackupScreenState createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  bool _wifiOnlyBackup = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backupService = Provider.of<BackupService>(context);
    final lastBackupTime = backupService.lastBackupTime;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Secure Cloud Backup',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildLastBackupCard(lastBackupTime, theme),
            const SizedBox(height: 16),
            _buildBackupActionsCard(theme),
            const SizedBox(height: 16),
            _buildBackupOptionsCard(theme),
            const SizedBox(height: 16),
            _buildRestoreCard(theme),
            if (_errorMessage != null || _successMessage != null)
              const SizedBox(height: 16),
            if (_errorMessage != null)
              _buildStatusMessage(_errorMessage!, Colors.red),
            if (_successMessage != null)
              _buildStatusMessage(_successMessage!, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enterprise-grade Vault Protection',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your data is encrypted with industry-leading algorithms and stored securely in the cloud.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildLastBackupCard(DateTime? lastBackupTime, ThemeData theme) {
    final formattedDate = lastBackupTime != null
        ? DateFormat('MMM dd, yyyy \'at\' h:mm a').format(lastBackupTime)
        : 'No previous backup found';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Backup Status',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  lastBackupTime != null ? Icons.check_circle : Icons.info_outline,
                  color: lastBackupTime != null ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Encrypted Snapshot',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupActionsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Manual Protection',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Initiate an immediate secure backup of all your essential data to our encrypted cloud storage.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isBackingUp ? null : _performBackup,
                icon: _isBackingUp
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.lock),
                label: Text(_isBackingUp ? 'Securing Data...' : 'Backup Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOptionsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Backup Configuration',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Automated Secure Backup Over WiFi Only'),
              subtitle: const Text(
                  'Preserves your data allocation by restricting automated backups to WiFi networks'),
              value: _wifiOnlyBackup,
              onChanged: (value) {
                setState(() {
                  _wifiOnlyBackup = value;
                });
                // TODO: Save preference to storage
              },
              secondary: Icon(
                Icons.wifi,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restore,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Recovery',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Restore your encrypted data snapshot from secure cloud storage.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isRestoring ? null : _performRestore,
                icon: _isRestoring
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.settings_backup_restore),
                label: Text(_isRestoring ? 'Restoring Data...' : 'Restore Secure Backup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            color == Colors.green ? Icons.check_circle : Icons.error,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup() async {
    setState(() {
      _isBackingUp = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Simulate backup operation
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual backup logic
      // final backupService = Provider.of<BackupService>(context, listen: false);
      // await backupService.performBackup();
      
      setState(() {
        _successMessage = 'Encrypted snapshot securely preserved in cloud storage';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Backup operation could not be completed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isBackingUp = false;
      });
    }
  }

  Future<void> _performRestore() async {
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Simulate restore operation
      await Future.delayed(const Duration(seconds: 3));
      
      // TODO: Implement actual restore logic
      // final backupService = Provider.of<BackupService>(context, listen: false);
      // await backupService.performRestore();
      
      setState(() {
        _successMessage = 'Data restoration successfully completed';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Restore operation could not be completed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }
}