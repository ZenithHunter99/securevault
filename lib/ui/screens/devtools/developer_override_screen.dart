import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../../../core/providers/developer_mode_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class DeveloperOverrideScreen extends StatefulWidget {
  static const String routeName = '/developer-override';

  const DeveloperOverrideScreen({super.key});

  @override
  _DeveloperOverrideScreenState createState() => _DeveloperOverrideScreenState();
}

class _DeveloperOverrideScreenState extends State<DeveloperOverrideScreen> {
  final List<String> _logs = [];
  bool _authenticatedMode = false;
  final TextEditingController _passcodeController = TextEditingController();
  static const String _developerPasscode = "dev4321";

  @override
  void initState() {
    super.initState();
    _addLog("Developer override screen initialized");
  }

  void _addLog(String message) {
    setState(() {
      _logs.add("[${DateTime.now().toIso8601String()}] $message");
      developer.log(message, name: 'DevOverride');
    });
  }

  void _authenticateDevMode() {
    if (_passcodeController.text == _developerPasscode) {
      setState(() {
        _authenticatedMode = true;
        _addLog("Developer mode authenticated");
      });
    } else {
      _addLog("Authentication failed");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid developer passcode'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exitDevMode() {
    final devProvider = Provider.of<DeveloperModeProvider>(context, listen: false);
    devProvider.disableAllDevFeatures();
    
    setState(() {
      _authenticatedMode = false;
      _addLog("Developer mode deactivated");
    });
    
    _passcodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: CustomAppBar(
        title: "Developer Override",
      ),
      body: _authenticatedMode ? _buildDevModeScreen() : _buildAuthScreen(),
    );
  }

  Widget _buildAuthScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.developer_mode,
            size: 72,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            "Developer Authentication Required",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _passcodeController,
            decoration: const InputDecoration(
              labelText: "Developer Passcode",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _authenticateDevMode(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _authenticateDevMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Authenticate"),
          ),
        ],
      ),
    );
  }

  Widget _buildDevModeScreen() {
    final devProvider = Provider.of<DeveloperModeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          // Caution tape on top
          _buildCautionTape(),
          
          // Main content with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warning header
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "⚠️ INTERNAL MODE ⚠️",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Developer toggles
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Developer Overrides",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildToggleOption(
                          "Simulate Rooted Device",
                          devProvider.simulateRootedDevice,
                          (value) {
                            devProvider.setSimulateRootedDevice(value);
                            _addLog("Rooted device simulation: $value");
                          },
                        ),
                        _buildToggleOption(
                          "Inject Fake Threat",
                          devProvider.injectFakeThreat,
                          (value) {
                            devProvider.setInjectFakeThreat(value);
                            _addLog("Fake threat injection: $value");
                          },
                        ),
                        _buildToggleOption(
                          "Disable Policy Enforcement",
                          devProvider.disablePolicyEnforcement,
                          (value) {
                            devProvider.setDisablePolicyEnforcement(value);
                            _addLog("Policy enforcement disabled: $value");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Developer logs
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Text(
                            "Developer Logs",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black,
                            child: ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  _logs[_logs.length - 1 - index],
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Exit dev mode button
                ElevatedButton.icon(
                  onPressed: _exitDevMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text(
                    "EXIT DEVELOPER MODE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Caution tape on bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCautionTape(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCautionTape() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: 40,
            color: index % 2 == 0 ? Colors.yellow : Colors.black,
            child: index % 2 == 0
                ? const Center(
                    child: Text(
                      "⚠️",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }
}