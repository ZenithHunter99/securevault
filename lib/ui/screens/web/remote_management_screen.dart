import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:geolocator/geolocator.dart';

class RemoteManagementScreen extends StatefulWidget {
  const RemoteManagementScreen({super.key});

  @override
  _RemoteManagementScreenState createState() => _RemoteManagementScreenState();
}

class _RemoteManagementScreenState extends State<RemoteManagementScreen> {
  // Mock data for linked devices
  final List<Device> _devices = [
    Device(
      id: '1',
      name: 'iPhone 13',
      battery: 85,
      os: 'iOS 18.1',
      location: 'New York, NY',
      status: 'Online',
    ),
    Device(
      id: '2',
      name: 'Galaxy S23',
      battery: 62,
      os: 'Android 15',
      location: 'San Francisco, CA',
      status: 'Offline',
    ),
    Device(
      id: '3',
      name: 'Pixel 8',
      battery: 45,
      os: 'Android 15',
      location: 'London, UK',
      status: 'Online',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize web-specific settings
    setUrlStrategy(PathUrlStrategy());
    // Simulate real-time updates
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    // Simulate periodic updates for battery and location
    // In a real app, this would be WebSocket or polling
  }

  void _executeCommand(String deviceId, String command) {
    // Simulate command execution
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$command sent to device $deviceId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Management Center'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Linked Devices',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return DeviceCard(
                    device: device,
                    onCommand: _executeCommand,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Device {
  final String id;
  final String name;
  final int battery;
  final String os;
  final String location;
  final String status;

  Device({
    required this.id,
    required this.name,
    required this.battery,
    required this.os,
    required this.location,
    required this.status,
  });
}

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function(String, String) onCommand;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  device.status == 'Online' ? Icons.wifi : Icons.wifi_off,
                  color: device.status == 'Online' ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Battery: ${device.battery}%'),
            Text('OS: ${device.os}'),
            Text('Location: ${device.location}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildCommandButton('Wipe', Colors.red),
                _buildCommandButton('Lock', Colors.orange),
                _buildCommandButton('Alert', Colors.blue),
                _buildCommandButton('Logs', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandButton(String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => onCommand(device.id, label),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}