import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import '../models/regulatory_models.dart';
import '../utils/logger.dart';
import '../utils/config.dart';

/// Service responsible for communicating with the regulatory bodies' APIs (RBI/NPCI)
/// 
/// This is a mock implementation for development and testing purposes.
/// In production, this would connect to actual regulatory endpoints.
class RegulatoryApiService {
  final Logger _logger = Logger('RegulatoryApiService');
  final String _baseUrl;
  final String _apiKey;
  final String _apiSecret;
  final Random _random = Random();

  /// Constructs a RegulatoryApiService with the necessary credentials
  RegulatoryApiService({
    String? baseUrl,
    String? apiKey,
    String? apiSecret,
  }) : 
    _baseUrl = baseUrl ?? AppConfig.regulatoryApiBaseUrl,
    _apiKey = apiKey ?? AppConfig.regulatoryApiKey,
    _apiSecret = apiSecret ?? AppConfig.regulatoryApiSecret;

  /// Generates a secure authorization header for API requests
  Map<String, String> _getAuthHeaders() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    
    // Create signature using HMAC SHA-256
    final signaturePayload = "$timestamp:$nonce:$_apiKey";
    final hmacSha256 = Hmac(sha256, utf8.encode(_apiSecret));
    final signature = hmacSha256.convert(utf8.encode(signaturePayload)).toString();

    return {
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
      'X-Request-ID': _generateUniqueId(),
    };
  }

  /// Fetches the current compliance status of the application
  /// 
  /// Returns details about compliance with various regulatory requirements
  Future<ComplianceStatusResponse> fetchComplianceStatus() async {
    _logger.info('Fetching compliance status from regulatory API');
    
    // In a real implementation, this would make an actual API call
    // await http.get(Uri.parse('$_baseUrl/v1/compliance/status'), headers: _getAuthHeaders());
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    
    // Mock response
    final mockResponse = ComplianceStatusResponse(
      overallStatus: _randomElement(['COMPLIANT', 'PARTIALLY_COMPLIANT', 'REVIEW_NEEDED']),
      lastUpdated: _getCurrentTimestamp(),
      complianceItems: [
        ComplianceItem(
          policyId: 'RBI_KYC_2023',
          name: 'Know Your Customer Guidelines',
          status: 'COMPLIANT',
          lastVerified: _getPastTimestamp(days: 3),
          nextVerificationDue: _getFutureTimestamp(days: 27),
          requiredActions: [],
        ),
        ComplianceItem(
          policyId: 'NPCI_UPI_SEC_2024',
          name: 'UPI Security Protocol 2024',
          status: _randomElement(['COMPLIANT', 'PARTIALLY_COMPLIANT']),
          lastVerified: _getPastTimestamp(days: 5),
          nextVerificationDue: _getFutureTimestamp(days: 25),
          requiredActions: _randomElement(['COMPLIANT', 'PARTIALLY_COMPLIANT']) == 'COMPLIANT' 
              ? [] 
              : ['Update encryption standards', 'Implement additional authentication layers'],
        ),
        ComplianceItem(
          policyId: 'RBI_FRAUD_PREVENTION_2024',
          name: 'Fraud Prevention Framework',
          status: _randomElement(['COMPLIANT', 'PARTIALLY_COMPLIANT', 'NON_COMPLIANT']),
          lastVerified: _getPastTimestamp(days: 10),
          nextVerificationDue: _getFutureTimestamp(days: 20),
          requiredActions: _randomElement(['COMPLIANT', 'PARTIALLY_COMPLIANT', 'NON_COMPLIANT']) == 'COMPLIANT' 
              ? [] 
              : ['Enhance transaction monitoring systems', 'Implement fraud detection algorithms'],
        ),
      ],
      certifications: [
        Certification(
          id: 'CERT_ISO27001',
          name: 'ISO 27001 Information Security',
          issueDate: _getPastTimestamp(days: 180),
          expiryDate: _getFutureTimestamp(days: 185),
          status: 'VALID',
        ),
        Certification(
          id: 'CERT_PCI_DSS',
          name: 'PCI DSS Compliance',
          issueDate: _getPastTimestamp(days: 90),
          expiryDate: _getFutureTimestamp(days: 275),
          status: 'VALID',
        ),
      ],
    );
    
    _logger.info('Compliance status retrieved successfully');
    return mockResponse;
  }

  /// Submits audit logs to the regulatory authority
  /// 
  /// [auditData] Contains the audit information to be submitted
  Future<AuditSubmissionResponse> submitAuditLog(AuditLogRequest auditData) async {
    _logger.info('Submitting audit log to regulatory API');
    
    // Validate the audit data
    if (auditData.entries.isEmpty) {
      throw Exception('Audit log cannot be empty');
    }
    
    // In a real implementation, this would make an actual API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/v1/audit/submit'),
    //   headers: _getAuthHeaders(),
    //   body: json.encode(auditData.toJson()),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));
    
    // Mock response
    final mockResponse = AuditSubmissionResponse(
      submissionId: _generateUniqueId(),
      timestamp: _getCurrentTimestamp(),
      status: 'ACCEPTED',
      message: 'Audit log received successfully',
      receiptHash: _generateSha256Hash(json.encode(auditData.toJson())),
    );
    
    _logger.info('Audit log submitted successfully with ID: ${mockResponse.submissionId}');
    return mockResponse;
  }

  /// Retrieves the latest regulatory policy updates
  /// 
  /// [lastSyncTimestamp] Optional timestamp to fetch only updates since then
  Future<PolicyUpdatesResponse> getPolicyUpdates({String? lastSyncTimestamp}) async {
    _logger.info('Fetching policy updates from regulatory API');
    
    // In a real implementation, this would make an actual API call
    // final queryParams = lastSyncTimestamp != null ? {'since': lastSyncTimestamp} : {};
    // await http.get(
    //   Uri.parse('$_baseUrl/v1/policies/updates').replace(queryParameters: queryParams),
    //   headers: _getAuthHeaders(),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 350 + _random.nextInt(650)));
    
    // Mock response
    final mockResponse = PolicyUpdatesResponse(
      lastUpdated: _getCurrentTimestamp(),
      policyUpdates: [
        PolicyUpdate(
          policyId: 'RBI_KYC_2023',
          version: '2.3.1',
          releaseDate: _getPastTimestamp(days: 15),
          effectiveDate: _getFutureTimestamp(days: 45),
          status: 'ANNOUNCED',
          title: 'KYC Process Enhancement',
          description: 'Additional verification steps for high-value accounts',
          complianceDeadline: _getFutureTimestamp(days: 90),
          documentLinks: [
            'https://rbi.gov.in/docs/kyc/2023/v2.3.1-guidelines.pdf',
            'https://rbi.gov.in/docs/kyc/2023/implementation-notes.pdf',
          ],
        ),
        PolicyUpdate(
          policyId: 'NPCI_UPI_SEC_2024',
          version: '3.0.0',
          releaseDate: _getPastTimestamp(days: 30),
          effectiveDate: _getPastTimestamp(days: 5),
          status: 'ACTIVE',
          title: 'UPI Security Protocol Upgrade',
          description: 'Major security framework update with enhanced encryption requirements',
          complianceDeadline: _getFutureTimestamp(days: 10),
          documentLinks: [
            'https://npci.org.in/policies/upi-security/v3.0.0.pdf',
          ],
        ),
        PolicyUpdate(
          policyId: 'RBI_FRAUD_PREVENTION_2024',
          version: '1.0.0',
          releaseDate: _getPastTimestamp(days: 60),
          effectiveDate: _getPastTimestamp(days: 15),
          status: 'ACTIVE',
          title: 'Fraud Prevention Framework',
          description: 'New comprehensive framework for preventing digital payment fraud',
          complianceDeadline: _getFutureTimestamp(days: 5),
          documentLinks: [
            'https://rbi.gov.in/docs/fraud-prevention/2024/framework-v1.pdf',
            'https://rbi.gov.in/docs/fraud-prevention/2024/implementation-guide.pdf',
          ],
        ),
      ],
    );
    
    _logger.info('Policy updates fetched successfully');
    return mockResponse;
  }

  /// Verifies the compliance for a specific transaction
  /// 
  /// [transactionId] The ID of the transaction to check
  /// [transactionAmount] The amount of the transaction
  /// [paymentMode] The payment method used
  Future<TransactionComplianceResponse> verifyTransactionCompliance({
    required String transactionId,
    required double transactionAmount,
    required String paymentMode,
  }) async {
    _logger.info('Verifying transaction compliance for ID: $transactionId');
    
    final payload = {
      'transactionId': transactionId,
      'amount': transactionAmount,
      'paymentMode': paymentMode,
      'timestamp': _getCurrentTimestamp(),
    };
    
    // In a real implementation, this would make an actual API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/v1/transactions/verify-compliance'),
    //   headers: _getAuthHeaders(),
    //   body: json.encode(payload),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
    
    // Mock response based on transaction amount
    bool isHighRisk = transactionAmount > 100000;
    bool needsAdditionalVerification = transactionAmount > 50000 || _random.nextBool();
    
    final mockResponse = TransactionComplianceResponse(
      transactionId: transactionId,
      timestamp: _getCurrentTimestamp(),
      complianceStatus: isHighRisk ? 'REQUIRES_REVIEW' : 'COMPLIANT',
      riskLevel: isHighRisk ? 'HIGH' : (needsAdditionalVerification ? 'MEDIUM' : 'LOW'),
      requiredChecks: isHighRisk ? [
        'ENHANCED_KYC',
        'SOURCE_OF_FUNDS',
        'REGULATORY_REPORTING'
      ] : (needsAdditionalVerification ? [
        'TRANSACTION_LIMITS',
        'DAILY_LIMITS'
      ] : []),
      regulatoryReportingRequired: isHighRisk,
      referenceId: _generateUniqueId(),
    );
    
    _logger.info('Transaction compliance verified: ${mockResponse.complianceStatus}');
    return mockResponse;
  }

  /// Registers a new payment instrument with regulatory authority
  /// 
  /// [instrumentData] Contains details about the payment instrument
  Future<InstrumentRegistrationResponse> registerPaymentInstrument(PaymentInstrumentRequest instrumentData) async {
    _logger.info('Registering payment instrument with regulatory authority');
    
    // In a real implementation, this would make an actual API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/v1/instruments/register'),
    //   headers: _getAuthHeaders(),
    //   body: json.encode(instrumentData.toJson()),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    
    // Mock response
    final mockResponse = InstrumentRegistrationResponse(
      instrumentId: _generateUniqueId(),
      registrationTimestamp: _getCurrentTimestamp(),
      status: 'REGISTERED',
      validUntil: _getFutureTimestamp(days: 365 * 3), // 3 years validity
      regulatoryReference: 'REG-${_random.nextInt(1000).toString().padLeft(6, '0')}',
      verificationStatus: _randomElement(['VERIFIED', 'PENDING_VERIFICATION']),
    );
    
    _logger.info('Payment instrument registered with ID: ${mockResponse.instrumentId}');
    return mockResponse;
  }

  /// Submits regulatory reports as required by compliance policies
  /// 
  /// [reportData] The report data to submit
  /// [reportType] The type of regulatory report
  Future<ReportSubmissionResponse> submitRegulatoryReport({
    required Map<String, dynamic> reportData,
    required String reportType,
  }) async {
    _logger.info('Submitting regulatory report of type: $reportType');
    
    final payload = {
      'reportType': reportType,
      'submissionDate': _getCurrentTimestamp(),
      'reportingEntity': AppConfig.organizationId,
      'reportPeriod': {
        'startDate': _getPastTimestamp(days: 30),
        'endDate': _getCurrentTimestamp(),
      },
      'reportData': reportData,
    };
    
    // In a real implementation, this would make an actual API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/v1/reports/submit'),
    //   headers: _getAuthHeaders(),
    //   body: json.encode(payload),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(900)));
    
    // Mock response
    final mockResponse = ReportSubmissionResponse(
      submissionId: _generateUniqueId(),
      timestamp: _getCurrentTimestamp(),
      reportType: reportType,
      status: 'ACCEPTED',
      processingStatus: 'QUEUED_FOR_PROCESSING',
      acknowledgementCode: 'ACK-${DateTime.now().year}-${_random.nextInt(100000).toString().padLeft(6, '0')}',
      receiptTimestamp: _getCurrentTimestamp(),
    );
    
    _logger.info('Regulatory report submitted with ID: ${mockResponse.submissionId}');
    return mockResponse;
  }

  /// Retrieves the latest regulatory alerts and notices
  Future<RegulatoryAlertsResponse> getRegulatoryAlerts() async {
    _logger.info('Fetching regulatory alerts and notices');
    
    // In a real implementation, this would make an actual API call
    // await http.get(
    //   Uri.parse('$_baseUrl/v1/regulatory/alerts'),
    //   headers: _getAuthHeaders(),
    // );
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));
    
    // Mock response
    final mockResponse = RegulatoryAlertsResponse(
      timestamp: _getCurrentTimestamp(),
      alerts: [
        RegulatoryAlert(
          alertId: 'ALERT-${_random.nextInt(10000)}',
          issueDate: _getPastTimestamp(days: 2),
          severity: _randomElement(['HIGH', 'MEDIUM', 'LOW']),
          title: 'Security Protocol Update Notice',
          description: 'All payment processors must update their security protocols by the specified deadline.',
          category: 'SECURITY',
          source: 'RBI',
          actionRequired: true,
          deadlineDate: _getFutureTimestamp(days: 30),
          referenceLinks: [
            'https://rbi.gov.in/notifications/2024/security-update-requirements.pdf',
          ],
        ),
        RegulatoryAlert(
          alertId: 'ALERT-${_random.nextInt(10000)}',
          issueDate: _getPastTimestamp(days: 5),
          severity: _randomElement(['HIGH', 'MEDIUM', 'LOW']),
          title: 'Fraud Prevention Advisory',
          description: 'Advisory on emerging fraud patterns in digital payments ecosystem.',
          category: 'FRAUD_PREVENTION',
          source: 'NPCI',
          actionRequired: false,
          deadlineDate: null,
          referenceLinks: [
            'https://npci.org.in/advisories/fraud-prevention-2024-05.pdf',
          ],
        ),
        RegulatoryAlert(
          alertId: 'ALERT-${_random.nextInt(10000)}',
          issueDate: _getPastTimestamp(days: 15),
          severity: _randomElement(['HIGH', 'MEDIUM', 'LOW']),
          title: 'Upcoming Regulatory Changes',
          description: 'Notice of proposed changes to digital payment regulations effective next quarter.',
          category: 'REGULATORY_CHANGE',
          source: 'RBI',
          actionRequired: true,
          deadlineDate: _getFutureTimestamp(days: 90),
          referenceLinks: [
            'https://rbi.gov.in/regulatory-framework/proposed-changes-2024-Q3.pdf',
          ],
        ),
      ],
    );
    
    _logger.info('Regulatory alerts fetched successfully');
    return mockResponse;
  }

  /// Helper method to generate a current timestamp in ISO 8601 format
  String _getCurrentTimestamp() {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now().toUtc());
  }

  /// Helper method to generate a past timestamp in ISO 8601 format
  String _getPastTimestamp({required int days}) {
    final date = DateTime.now().subtract(Duration(days: days));
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(date.toUtc());
  }

  /// Helper method to generate a future timestamp in ISO 8601 format
  String _getFutureTimestamp({required int days}) {
    final date = DateTime.now().add(Duration(days: days));
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(date.toUtc());
  }

  /// Helper method to generate a unique ID
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _random.nextInt(1000000).toString().padLeft(6, '0');
    return '$timestamp-$random';
  }

  /// Helper method to generate a nonce for API authentication
  String _generateNonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Helper method to generate a SHA-256 hash
  String _generateSha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Helper method to pick a random element from a list
  T _randomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }
}

/// Represents a request to register a payment instrument
class PaymentInstrumentRequest {
  final String instrumentType;
  final String issuerId;
  final String accountId;
  final Map<String, dynamic> instrumentDetails;
  final String ownerType;
  final Map<String, dynamic> ownerDetails;

  PaymentInstrumentRequest({
    required this.instrumentType,
    required this.issuerId,
    required this.accountId,
    required this.instrumentDetails,
    required this.ownerType,
    required this.ownerDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'instrumentType': instrumentType,
      'issuerId': issuerId,
      'accountId': accountId,
      'instrumentDetails': instrumentDetails,
      'ownerType': ownerType,
      'ownerDetails': ownerDetails,
    };
  }
}

/// Represents a request to submit audit logs
class AuditLogRequest {
  final List<AuditLogEntry> entries;
  final String sourceSystem;
  final String sourceId;

  AuditLogRequest({
    required this.entries,
    required this.sourceSystem,
    required this.sourceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'sourceSystem': sourceSystem,
      'sourceId': sourceId,
    };
  }
}

/// Represents a single audit log entry
class AuditLogEntry {
  final String eventType;
  final String timestamp;
  final String userId;
  final String actionType;
  final Map<String, dynamic> details;

  AuditLogEntry({
    required this.eventType,
    required this.timestamp,
    required this.userId,
    required this.actionType,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'timestamp': timestamp,
      'userId': userId,
      'actionType': actionType,
      'details': details,
    };
  }
}

/// Response for compliance status request
class ComplianceStatusResponse {
  final String overallStatus;
  final String lastUpdated;
  final List<ComplianceItem> complianceItems;
  final List<Certification> certifications;

  ComplianceStatusResponse({
    required this.overallStatus,
    required this.lastUpdated,
    required this.complianceItems,
    required this.certifications,
  });

  factory ComplianceStatusResponse.fromJson(Map<String, dynamic> json) {
    return ComplianceStatusResponse(
      overallStatus: json['overallStatus'],
      lastUpdated: json['lastUpdated'],
      complianceItems: (json['complianceItems'] as List)
          .map((item) => ComplianceItem.fromJson(item))
          .toList(),
      certifications: (json['certifications'] as List)
          .map((cert) => Certification.fromJson(cert))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallStatus': overallStatus,
      'lastUpdated': lastUpdated,
      'complianceItems': complianceItems.map((item) => item.toJson()).toList(),
      'certifications': certifications.map((cert) => cert.toJson()).toList(),
    };
  }
}

/// Individual compliance requirement item
class ComplianceItem {
  final String policyId;
  final String name;
  final String status;
  final String lastVerified;
  final String nextVerificationDue;
  final List<String> requiredActions;

  ComplianceItem({
    required this.policyId,
    required this.name,
    required this.status,
    required this.lastVerified,
    required this.nextVerificationDue,
    required this.requiredActions,
  });

  factory ComplianceItem.fromJson(Map<String, dynamic> json) {
    return ComplianceItem(
      policyId: json['policyId'],
      name: json['name'],
      status: json['status'],
      lastVerified: json['lastVerified'],
      nextVerificationDue: json['nextVerificationDue'],
      requiredActions: List<String>.from(json['requiredActions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policyId': policyId,
      'name': name,
      'status': status,
      'lastVerified': lastVerified,
      'nextVerificationDue': nextVerificationDue,
      'requiredActions': requiredActions,
    };
  }
}

/// Certification information
class Certification {
  final String id;
  final String name;
  final String issueDate;
  final String expiryDate;
  final String status;

  Certification({
    required this.id,
    required this.name,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      name: json['name'],
      issueDate: json['issueDate'],
      expiryDate: json['expiryDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'status': status,
    };
  }
}

/// Response for audit submission
class AuditSubmissionResponse {
  final String submissionId;
  final String timestamp;
  final String status;
  final String message;
  final String receiptHash;

  AuditSubmissionResponse({
    required this.submissionId,
    required this.timestamp,
    required this.status,
    required this.message,
    required this.receiptHash,
  });

  factory AuditSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return AuditSubmissionResponse(
      submissionId: json['submissionId'],
      timestamp: json['timestamp'],
      status: json['status'],
      message: json['message'],
      receiptHash: json['receiptHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'timestamp': timestamp,
      'status': status,
      'message': message,
      'receiptHash': receiptHash,
    };
  }
}

/// Response for policy updates request
class PolicyUpdatesResponse {
  final String lastUpdated;
  final List<PolicyUpdate> policyUpdates;

  PolicyUpdatesResponse({
    required this.lastUpdated,
    required this.policyUpdates,
  });

  factory PolicyUpdatesResponse.fromJson(Map<String, dynamic> json) {
    return PolicyUpdatesResponse(
      lastUpdated: json['lastUpdated'],
      policyUpdates: (json['policyUpdates'] as List)
          .map((update) => PolicyUpdate.fromJson(update))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': lastUpdated,
      'policyUpdates': policyUpdates.map((update) => update.toJson()).toList(),
    };
  }
}

/// Individual policy update information
class PolicyUpdate {
  final String policyId;
  final String version;
  final String releaseDate;
  final String effectiveDate;
  final String status;
  final String title;
  final String description;
  final String complianceDeadline;
  final List<String> documentLinks;

  PolicyUpdate({
    required this.policyId,
    required this.version,
    required this.releaseDate,
    required this.effectiveDate,
    required this.status,
    required this.title,
    required this.description,
    required this.complianceDeadline,
    required this.documentLinks,
  });

  factory PolicyUpdate.fromJson(Map<String, dynamic> json) {
    return PolicyUpdate(
      policyId: json['policyId'],
      version: json['version'],
      releaseDate: json['releaseDate'],
      effectiveDate: json['effectiveDate'],
      status: json['status'],
      title: json['title'],
      description: json['description'],
      complianceDeadline: json['complianceDeadline'],
      documentLinks: List<String>.from(json['documentLinks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policyId': policyId,
      'version': version,
      'releaseDate': releaseDate,
      'effectiveDate': effectiveDate,
      'status': status,
      'title': title,
      'description': description,
      'complianceDeadline': complianceDeadline,
      'documentLinks': documentLinks,
    };
  }
}

/// Response for transaction compliance verification
class TransactionComplianceResponse {
  final String transactionId;
  final String timestamp;
  final String complianceStatus;
  final String riskLevel;
  final List<String> requiredChecks;
  final bool regulatoryReportingRequired;
  final String referenceId;

  TransactionComplianceResponse({
    required this.transactionId,
    required this.timestamp,
    required this.complianceStatus,
    required this.riskLevel,
    required this.requiredChecks,
    required this.regulatoryReportingRequired,
    required this.referenceId,
  });

  factory TransactionComplianceResponse.fromJson(Map<String, dynamic> json) {
    return TransactionComplianceResponse(
      transactionId: json['transactionId'],
      timestamp: json['timestamp'],
      complianceStatus: json['complianceStatus'],
      riskLevel: json['riskLevel'],
      requiredChecks: List<String>.from(json['requiredChecks']),
      regulatoryReportingRequired: json['regulatoryReportingRequired'],
      referenceId: json['referenceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'timestamp': timestamp,
      'complianceStatus': complianceStatus,
      'riskLevel': riskLevel,
      'requiredChecks': requiredChecks,
      'regulatoryReportingRequired': regulatoryReportingRequired,
      'referenceId': referenceId,
    };
  }
}

/// Response for instrument registration
class InstrumentRegistrationResponse {
  final String instrumentId;
  final String registrationTimestamp;
  final String status;
  final String validUntil;
  final String regulatoryReference;
  final String verificationStatus;

  InstrumentRegistrationResponse({
    required this.instrumentId,
    required this.registrationTimestamp,
    required this.status,
    required this.validUntil,
    required this.regulatoryReference,
    required this.verificationStatus,
  });

  factory InstrumentRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return InstrumentRegistrationResponse(
      instrumentId: json['instrumentId'],
      registrationTimestamp: json['registrationTimestamp'],
      status: json['status'],
      validUntil: json['validUntil'],
      regulatoryReference: json['regulatoryReference'],
      verificationStatus: json['verificationStatus'],
    );
  }

Map<String, dynamic> toJson() {
    return {
      'instrumentId': instrumentId,
      'registrationTimestamp': registrationTimestamp,
      'status': status,
      'validUntil': validUntil,
      'regulatoryReference': regulatoryReference,
      'verificationStatus': verificationStatus,
    };
  }
}

/// Response for regulatory report submission
class ReportSubmissionResponse {
  final String submissionId;
  final String timestamp;
  final String reportType;
  final String status;
  final String processingStatus;
  final String acknowledgementCode;
  final String receiptTimestamp;

  ReportSubmissionResponse({
    required this.submissionId,
    required this.timestamp,
    required this.reportType,
    required this.status,
    required this.processingStatus,
    required this.acknowledgementCode,
    required this.receiptTimestamp,
  });

  factory ReportSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return ReportSubmissionResponse(
      submissionId: json['submissionId'],
      timestamp: json['timestamp'],
      reportType: json['reportType'],
      status: json['status'],
      processingStatus: json['processingStatus'],
      acknowledgementCode: json['acknowledgementCode'],
      receiptTimestamp: json['receiptTimestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'timestamp': timestamp,
      'reportType': reportType,
      'status': status,
      'processingStatus': processingStatus,
      'acknowledgementCode': acknowledgementCode,
      'receiptTimestamp': receiptTimestamp,
    };
  }
}

/// Response for regulatory alerts request
class RegulatoryAlertsResponse {
  final String timestamp;
  final List<RegulatoryAlert> alerts;

  RegulatoryAlertsResponse({
    required this.timestamp,
    required this.alerts,
  });

  factory RegulatoryAlertsResponse.fromJson(Map<String, dynamic> json) {
    return RegulatoryAlertsResponse(
      timestamp: json['timestamp'],
      alerts: (json['alerts'] as List)
          .map((alert) => RegulatoryAlert.fromJson(alert))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
    };
  }
}

/// Individual regulatory alert information
class RegulatoryAlert {
  final String alertId;
  final String issueDate;
  final String severity;
  final String title;
  final String description;
  final String category;
  final String source;
  final bool actionRequired;
  final String? deadlineDate;
  final List<String> referenceLinks;

  RegulatoryAlert({
    required this.alertId,
    required this.issueDate,
    required this.severity,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.actionRequired,
    this.deadlineDate,
    required this.referenceLinks,
  });

  factory RegulatoryAlert.fromJson(Map<String, dynamic> json) {
    return RegulatoryAlert(
      alertId: json['alertId'],
      issueDate: json['issueDate'],
      severity: json['severity'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      source: json['source'],
      actionRequired: json['actionRequired'],
      deadlineDate: json['deadlineDate'],
      referenceLinks: List<String>.from(json['referenceLinks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'issueDate': issueDate,
      'severity': severity,
      'title': title,
      'description': description,
      'category': category,
      'source': source,
      'actionRequired': actionRequired,
      'deadlineDate': deadlineDate,
      'referenceLinks': referenceLinks,
    };
  }
}