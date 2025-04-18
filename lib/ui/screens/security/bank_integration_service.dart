import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Service that handles secure bank integration operations.
///
/// This service provides methods for linking and unlinking bank accounts,
/// retrieving linked accounts, and simulates various error scenarios
/// that might occur during bank integration.
class BankIntegrationService {
  /// Stores linked bank account information
  final Map<String, LinkedBankAccount> _linkedAccounts = {};
  
  /// Simulated authentication tokens with expiration times
  final Map<String, DateTime> _authTokens = {};
  
  /// Random generator for simulating errors and generating tokens
  final Random _random = Random();
  
  /// Simulates linking a bank account through secure authentication
  /// 
  /// [bankName] - Name of the bank to link
  /// [username] - Banking username
  /// [password] - Banking password
  /// [otpCode] - One-time password/verification code
  /// 
  /// Returns a [Future] with the linked bank account details on success
  /// Throws exceptions for various error cases
  Future<LinkedBankAccount> linkBank({
    required String bankName,
    required String username,
    required String password,
    required String otpCode,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)));
    
    // Simulate various error cases
    if (_random.nextDouble() < 0.05) {
      throw BankIntegrationException(
        code: 'NETWORK_ERROR',
        message: 'Failed to connect to banking servers',
        recoverable: true,
      );
    }
    
    // Validate OTP code (simulate expired OTP)
    if (otpCode == '000000' || otpCode.length != 6 || _random.nextDouble() < 0.1) {
      throw BankIntegrationException(
        code: 'INVALID_OTP',
        message: 'The verification code has expired or is invalid',
        recoverable: true,
      );
    }
    
    // Validate credentials (simulate invalid credentials)
    if (username.isEmpty || password.isEmpty || _random.nextDouble() < 0.1) {
      throw BankIntegrationException(
        code: 'INVALID_CREDENTIALS',
        message: 'The provided banking credentials are incorrect',
        recoverable: true,
      );
    }
    
    // Generate a token valid for 1 hour
    final String token = _generateAuthToken();
    _authTokens[token] = DateTime.now().add(Duration(hours: 1));
    
    // Create new linked account with random details
    final String accountId = _generateAccountId();
    final String last4 = _generateLast4Digits();
    final int secureScore = 60 + _random.nextInt(41); // 60-100
    
    final LinkedBankAccount account = LinkedBankAccount(
      id: accountId,
      bankName: bankName,
      accountLast4: last4,
      secureScore: secureScore,
      linkedTime: DateTime.now(),
      authToken: token,
    );
    
    _linkedAccounts[accountId] = account;
    
    return account;
  }
  
  /// Unlinks a previously linked bank account
  /// 
  /// [accountId] - The ID of the account to unlink
  /// 
  /// Returns a [Future<bool>] indicating success
  /// Throws exceptions for various error cases
  Future<bool> unlinkBank(String accountId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(300)));
    
    // Simulate network error
    if (_random.nextDouble() < 0.05) {
      throw BankIntegrationException(
        code: 'API_ERROR',
        message: 'Banking API temporarily unavailable',
        recoverable: true,
      );
    }
    
    // Check if account exists
    if (!_linkedAccounts.containsKey(accountId)) {
      throw BankIntegrationException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'The specified bank account was not found',
        recoverable: false,
      );
    }
    
    // Check if token is expired
    final LinkedBankAccount account = _linkedAccounts[accountId]!;
    if (!_isTokenValid(account.authToken)) {
      throw BankIntegrationException(
        code: 'SESSION_EXPIRED',
        message: 'Your banking session has expired. Please link your bank again.',
        recoverable: false,
      );
    }
    
    // Remove the account
    _linkedAccounts.remove(accountId);
    _authTokens.remove(account.authToken);
    
    return true;
  }
  
  /// Retrieves all linked bank accounts
  /// 
  /// Returns a [Future] with a list of linked bank accounts
  /// Throws exceptions for various error cases
  Future<List<LinkedBankAccount>> getLinkedAccounts() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(200)));
    
    // Simulate API error
    if (_random.nextDouble() < 0.05) {
      throw BankIntegrationException(
        code: 'SERVICE_UNAVAILABLE',
        message: 'Banking service temporarily unavailable',
        recoverable: true,
      );
    }
    
    // Filter out accounts with expired tokens
    final validAccounts = _linkedAccounts.values
        .where((account) => _isTokenValid(account.authToken))
        .toList();
    
    // If tokens have expired, remove those accounts
    _linkedAccounts.removeWhere(
        (id, account) => !_isTokenValid(account.authToken));
    
    return validAccounts;
  }
  
  /// Refreshes the authentication token for a linked bank account
  /// 
  /// [accountId] - The ID of the account to refresh
  /// [otpCode] - New OTP code for verification
  /// 
  /// Returns a [Future] with the updated bank account details
  /// Throws exceptions for various error cases
  Future<LinkedBankAccount> refreshAuthToken(String accountId, String otpCode) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 700 + _random.nextInt(500)));
    
    // Check if account exists
    if (!_linkedAccounts.containsKey(accountId)) {
      throw BankIntegrationException(
        code: 'ACCOUNT_NOT_FOUND',
        message: 'The specified bank account was not found',
        recoverable: false,
      );
    }
    
    // Validate OTP
    if (otpCode.length != 6 || _random.nextDouble() < 0.1) {
      throw BankIntegrationException(
        code: 'INVALID_OTP',
        message: 'The verification code is invalid',
        recoverable: true,
      );
    }
    
    // Generate new token
    final String newToken = _generateAuthToken();
    _authTokens[newToken] = DateTime.now().add(Duration(hours: 1));
    
    // Update account with new token
    final LinkedBankAccount oldAccount = _linkedAccounts[accountId]!;
    final LinkedBankAccount updatedAccount = LinkedBankAccount(
      id: oldAccount.id,
      bankName: oldAccount.bankName,
      accountLast4: oldAccount.accountLast4,
      secureScore: oldAccount.secureScore,
      linkedTime: oldAccount.linkedTime,
      authToken: newToken,
    );
    
    _linkedAccounts[accountId] = updatedAccount;
    
    // Clean up old token
    _authTokens.remove(oldAccount.authToken);
    
    return updatedAccount;
  }
  
  /// Checks if a token is valid (not expired)
  bool _isTokenValid(String token) {
    if (!_authTokens.containsKey(token)) return false;
    final DateTime expiryTime = _authTokens[token]!;
    return DateTime.now().isBefore(expiryTime);
  }
  
  /// Generates a random authentication token
  String _generateAuthToken() {
    final List<int> tokenBytes = List.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(tokenBytes);
  }
  
  /// Generates a random account ID
  String _generateAccountId() {
    return 'acc_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }
  
  /// Generates random last 4 digits for an account number
  String _generateLast4Digits() {
    final digits = List.generate(4, (_) => _random.nextInt(10));
    return digits.join();
  }
}

/// Model class representing a linked bank account
class LinkedBankAccount {
  final String id;
  final String bankName;
  final String accountLast4;
  final int secureScore;
  final DateTime linkedTime;
  final String authToken;
  
  LinkedBankAccount({
    required this.id,
    required this.bankName,
    required this.accountLast4,
    required this.secureScore,
    required this.linkedTime,
    required this.authToken,
  });
  
  /// Creates a map representation of the account (excluding sensitive token)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountLast4': accountLast4,
      'secureScore': secureScore,
      'linkedTime': linkedTime.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'LinkedBankAccount{id: $id, bankName: $bankName, '
        'accountLast4: $accountLast4, secureScore: $secureScore, '
        'linkedTime: $linkedTime}';
  }
}

/// Exception class for bank integration errors
class BankIntegrationException implements Exception {
  final String code;
  final String message;
  final bool recoverable;
  
  BankIntegrationException({
    required this.code,
    required this.message,
    required this.recoverable,
  });
  
  @override
  String toString() {
    return 'BankIntegrationException: [$code] $message';
  }
}