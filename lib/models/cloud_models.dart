import 'package:json_annotation/json_annotation.dart';

part 'cloud_models.g.dart';

@JsonSerializable()
class AuditLogEntry {
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @JsonKey(name: 'event')
  final String event;

  @JsonKey(name: 'deviceId')
  final String deviceId;

  @JsonKey(name: 'severity')
  final String severity;

  AuditLogEntry({
    required this.timestamp,
    required this.event,
    required this.deviceId,
    required this.severity,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);

  Map<String, dynamic> toJson() => _$AuditLogEntryToJson(this);
}

@JsonSerializable()
class RemoteCommand {
  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'targetDevice')
  final String targetDevice;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'executedTime')
  final DateTime? executedTime;

  RemoteCommand({
    required this.type,
    required this.targetDevice,
    required this.status,
    this.executedTime,
  });

  factory RemoteCommand.fromJson(Map<String, dynamic> json) =>
      _$RemoteCommandFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteCommandToJson(this);
}

@JsonSerializable()
class CompliancePolicy {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'required')
  final bool required;

  @JsonKey(name: 'compliant')
  final bool compliant;

  CompliancePolicy({
    required this.id,
    required this.description,
    required this.required,
    required this.compliant,
  });

  factory CompliancePolicy.fromJson(Map<String, dynamic> json) =>
      _$CompliancePolicyFromJson(json);

  Map<String, dynamic> toJson() => _$CompliancePolicyToJson(this);
}