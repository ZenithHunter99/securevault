import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

import 'package:secureguard/services/security_service.dart';
import 'package:secureguard/models/device_state.dart';
import 'package:secureguard/models/security_policy.dart';
import 'package:secureguard/models/threat_event.dart';
import 'package:secureguard/services/device_service.dart';
import 'package:secureguard/services/policy_service.dart';

@GenerateMocks([DeviceService, PolicyService])
import 'security_service_test.mocks.dart';

void main() {
  late SecurityService securityService;
  late MockDeviceService mockDeviceService;
  late MockPolicyService mockPolicyService;
  
  late StreamController<DeviceState> deviceStateController;
  late SecurityPolicy testPolicy;
  
  setUp(() {
    mockDeviceService = MockDeviceService();
    mockPolicyService = MockPolicyService();
    deviceStateController = StreamController<DeviceState>.broadcast();
    
    // Mock device service to return our controlled stream
    when(mockDeviceService.deviceStateStream)
        .thenAnswer((_) => deviceStateController.stream);
    
    // Create a test policy that has some constraints
    testPolicy = SecurityPolicy(
      id: 'test-policy-1',
      name: 'Test Policy',
      rules: [
        SecurityRule(
          id: 'rule-1',
          condition: 'location.outsideAllowedZones == true',
          threatLevel: ThreatLevel.high,
          description: 'Device outside allowed zones',
        ),
        SecurityRule(
          id: 'rule-2',
          condition: 'connectivity.isRoaming == true',
          threatLevel: ThreatLevel.medium, 
          description: 'Device is roaming',
        ),
        SecurityRule(
          id: 'rule-3',
          condition: 'connectivity.isUsingPublicWifi == true && apps.sensitiveAppsRunning.isNotEmpty',
          threatLevel: ThreatLevel.high,
          description: 'Using sensitive apps on public WiFi',
        ),
      ],
    );
    
    // Mock policy service to return our test policy
    when(mockPolicyService.getCurrentPolicy()).thenAnswer((_) => testPolicy);
    
    // Create security service with our mocks
    securityService = SecurityService(
      deviceService: mockDeviceService,
      policyService: mockPolicyService,
    );
  });
  
  tearDown(() {
    deviceStateController.close();
  });
  
  test('SecurityService should emit high threat when device location violates policy', () async {
    // Create an expected ThreatEvent
    final expectedThreat = ThreatEvent(
      ruleId: 'rule-1',
      threatLevel: ThreatLevel.high,
      description: 'Device outside allowed zones',
      timestamp: any,
      deviceState: any,
    );
    
    // Listen to threat events
    final threatEvents = <ThreatEvent>[];
    final subscription = securityService.threatStream.listen(threatEvents.add);
    
    // Start security monitoring
    await securityService.startMonitoring();
    
    // Simulate a device state change that triggers the location violation
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 37.7749,
        longitude: -122.4194,
        outsideAllowedZones: true, // This will trigger rule-1
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: false,
        isUsingPublicWifi: false,
        networkType: NetworkType.mobile,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.mail',
        sensitiveAppsRunning: [],
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit for event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify threat event was emitted
    expect(threatEvents, hasLength(1));
    expect(threatEvents[0].ruleId, equals('rule-1'));
    expect(threatEvents[0].threatLevel, equals(ThreatLevel.high));
    
    await subscription.cancel();
  });
  
  test('SecurityService should emit medium threat when device is roaming', () async {
    // Listen to threat events
    final threatEvents = <ThreatEvent>[];
    final subscription = securityService.threatStream.listen(threatEvents.add);
    
    // Start security monitoring
    await securityService.startMonitoring();
    
    // Simulate a device state change that triggers the roaming violation
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 40.7128,
        longitude: -74.0060,
        outsideAllowedZones: false,
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: true, // This will trigger rule-2
        isUsingPublicWifi: false,
        networkType: NetworkType.mobile,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.browser',
        sensitiveAppsRunning: [],
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit for event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify threat event was emitted
    expect(threatEvents, hasLength(1));
    expect(threatEvents[0].ruleId, equals('rule-2'));
    expect(threatEvents[0].threatLevel, equals(ThreatLevel.medium));
    
    await subscription.cancel();
  });
  
  test('SecurityService should emit high threat when using sensitive apps on public WiFi', () async {
    // Listen to threat events
    final threatEvents = <ThreatEvent>[];
    final subscription = securityService.threatStream.listen(threatEvents.add);
    
    // Start security monitoring
    await securityService.startMonitoring();
    
    // Simulate a device state change that triggers the sensitive apps on public WiFi violation
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 34.0522,
        longitude: -118.2437,
        outsideAllowedZones: false,
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: false,
        isUsingPublicWifi: true, // Part of rule-3 condition
        networkType: NetworkType.wifi,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.banking',
        sensitiveAppsRunning: ['com.example.banking'], // Part of rule-3 condition
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit for event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify threat event was emitted
    expect(threatEvents, hasLength(1));
    expect(threatEvents[0].ruleId, equals('rule-3'));
    expect(threatEvents[0].threatLevel, equals(ThreatLevel.high));
    
    await subscription.cancel();
  });
  
  test('SecurityService should not emit threat when no policy violations occur', () async {
    // Listen to threat events
    final threatEvents = <ThreatEvent>[];
    final subscription = securityService.threatStream.listen(threatEvents.add);
    
    // Start security monitoring
    await securityService.startMonitoring();
    
    // Simulate a device state change with no policy violations
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 51.5074,
        longitude: -0.1278,
        outsideAllowedZones: false, // No violation
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: false, // No violation
        isUsingPublicWifi: false, // No violation
        networkType: NetworkType.wifi,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.calendar',
        sensitiveAppsRunning: [], // No violation
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit for event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify no threat events were emitted
    expect(threatEvents, isEmpty);
    
    await subscription.cancel();
  });
  
  test('SecurityService should stop monitoring when stopMonitoring is called', () async {
    // Setup a way to check if events are still processed
    final threatEvents = <ThreatEvent>[];
    final subscription = securityService.threatStream.listen(threatEvents.add);
    
    // Start monitoring
    await securityService.startMonitoring();
    
    // Trigger a violation to verify monitoring is working
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 37.7749,
        longitude: -122.4194,
        outsideAllowedZones: true, // Violation
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: false,
        isUsingPublicWifi: false,
        networkType: NetworkType.mobile,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.app',
        sensitiveAppsRunning: [],
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit for event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify threat was detected
    expect(threatEvents, hasLength(1));
    threatEvents.clear();
    
    // Stop monitoring
    await securityService.stopMonitoring();
    
    // Trigger another violation
    deviceStateController.add(DeviceState(
      deviceId: 'test-device',
      location: LocationInfo(
        latitude: 37.7749,
        longitude: -122.4194,
        outsideAllowedZones: true, // Violation
      ),
      connectivity: ConnectivityInfo(
        isOnline: true,
        isRoaming: false,
        isUsingPublicWifi: false,
        networkType: NetworkType.mobile,
      ),
      apps: AppInfo(
        foregroundApp: 'com.example.app',
        sensitiveAppsRunning: [],
      ),
      timestamp: DateTime.now(),
    ));
    
    // Wait a bit
    await Future.delayed(Duration(milliseconds: 100));
    
    // Verify no new threats were detected after stopping
    expect(threatEvents, isEmpty);
    
    await subscription.cancel();
  });
}