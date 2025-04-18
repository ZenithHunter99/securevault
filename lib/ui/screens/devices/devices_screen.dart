import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/device_model.dart';
import '../../../services/device_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class TrustedDevicesScreen extends StatefulWidget {
  const TrustedDevicesScreen({super.key});

  @override
  _TrustedDevicesScreenState createState() => _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends State<TrustedDevicesScreen> {
  bool _isLoading = true;
  List<DeviceModel> _devices = [];
  late DeviceService _deviceService;
  DeviceModel? _currentDevice;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _deviceService = Provider.of<DeviceService>(context, listen: false);
      final devices = await _deviceService.getDevices();
      final currentDevice = await _deviceService.getCurrentDevice();

      setState(() {
        _devices = devices;
        _currentDevice = currentDevice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Failed to load devices: ${e.toString()}");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _unlinkDevice(DeviceModel device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Unlink Device",
        content: "Are you sure you want to unlink this device? This action cannot be undone.",
        confirmText: "Unlink",
        cancelText: "Cancel",
        isDestructive: true,
      ),
    );

    if (confirmed ?? false) {
      try {
        await _deviceService.unlinkDevice(device.id);
        _showSuccessSnackBar("Device unlinked successfully");
        _loadDevices();
      } catch (e) {
        _showErrorSnackBar("Failed to unlink device: ${e.toString()}");
      }
    }
  }

  Future<void> _toggleDeviceLock(DeviceModel device) async {
    final bool isLocking = device.status != DeviceStatus.locked;
    final actionText = isLocking ? "lock" : "unlock";
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "${isLocking ? 'Lock' : 'Unlock'} Device",
        content: "Are you sure you want to $actionText this device?",
        confirmText: isLocking ? "Lock" : "Unlock",
        cancelText: "Cancel",
        isDestructive: isLocking,
      ),
    );

    if (confirmed ?? false) {
      try {
        if (isLocking) {
          await _deviceService.lockDevice(device.id);
          _showSuccessSnackBar("Device locked successfully");
        } else {
          await _deviceService.unlockDevice(device.id);
          _showSuccessSnackBar("Device unlocked successfully");
        }
        _loadDevices();
      } catch (e) {
        _showErrorSnackBar("Failed to $actionText device: ${e.toString()}");
      }
    }
  }

  Widget _buildDeviceStatusIndicator(DeviceStatus status) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case DeviceStatus.active:
        icon = Icons.check_circle;
        color = Colors.green;
        label = "Active";
        break;
      case DeviceStatus.locked:
        icon = Icons.lock;
        color = Colors.red;
        label = "Locked";
        break;
      case DeviceStatus.inactive:
        icon = Icons.warning;
        color = Colors.amber;
        label = "Inactive";
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTypeIcon(DeviceType type) {
    IconData icon;
    String label;

    switch (type) {
      case DeviceType.mobile:
        icon = Icons.smartphone;
        label = "Mobile";
        break;
      case DeviceType.tablet:
        icon = Icons.tablet_mac;
        label = "Tablet";
        break;
      case DeviceType.desktop:
        icon = Icons.computer;
        label = "Desktop";
        break;
      case DeviceType.browser:
        icon = Icons.public;
        label = "Browser";
        break;
      case DeviceType.other:
        icon = Icons.devices_other;
        label = "Other";
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formatLastAccess(DateTime lastAccess) {
    final now = DateTime.now();
    final difference = now.difference(lastAccess);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(lastAccess);
    }
  }

  Widget _buildDeviceCard(DeviceModel device) {
    final isCurrentDevice = _currentDevice?.id == device.id;
    final bool canLock = device.status != DeviceStatus.locked;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentDevice
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildDeviceTypeIcon(device.type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildDeviceStatusIndicator(device.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Last active: ${_formatLastAccess(device.lastAccess)}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (isCurrentDevice)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Current Device",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isCurrentDevice
                      ? null
                      : () => _unlinkDevice(device),
                  icon: const Icon(Icons.link_off),
                  label: const Text("Unlink"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _toggleDeviceLock(device),
                  icon: Icon(
                    canLock ? Icons.lock : Icons.lock_open,
                  ),
                  label: Text(
                    canLock ? "Lock Device" : "Unlock Device",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canLock
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No devices found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "There are no devices linked to your account",
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeHelper = ThemeHelper.of(context);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: "Trusted Devices",
        showBackButton: true,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeHelper.trustEcosystemBackgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDevices,
                child: _devices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          return _buildDeviceCard(_devices[index]);
                        },
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDevices,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}