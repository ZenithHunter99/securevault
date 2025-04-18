import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecureAppStoreScreen extends StatefulWidget {
  const SecureAppStoreScreen({super.key});

  @override
  State<SecureAppStoreScreen> createState() => _SecureAppStoreScreenState();
}

class _SecureAppStoreScreenState extends State<SecureAppStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure App Store'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RBI Approved'),
            Tab(text: 'UPI'),
            Tab(text: 'Wallets'),
            Tab(text: 'Credit Apps'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppGrid(mockRbiApps),
                _buildAppGrid(mockUpiApps),
                _buildAppGrid(mockWalletApps),
                _buildAppGrid(mockCreditApps),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AppRequestDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Request Addition'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAppGrid(List<FinancialApp> apps) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppCard(app: apps[index]);
      },
    );
  }
}

class AppCard extends StatelessWidget {
  final FinancialApp app;

  const AppCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: app.complianceLevel == ComplianceLevel.rbiCertified
              ? Colors.green.shade300
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to app details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppDetailsScreen(app: app),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      app.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildComplianceBadge(app.complianceLevel),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                    Text(
                      app.developer,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRatingStars(app.rating),
                        const SizedBox(width: 4),
                        Text(
                          app.rating.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceBadge(ComplianceLevel level) {
    Color backgroundColor;
    String label;
    IconData icon;

    switch (level) {
      case ComplianceLevel.rbiCertified:
        backgroundColor = Colors.green;
        label = 'RBI Certified';
        icon = Icons.verified;
        break;
      case ComplianceLevel.pciDss:
        backgroundColor = Colors.blue;
        label = 'PCI-DSS';
        icon = Icons.shield;
        break;
      case ComplianceLevel.basic:
        backgroundColor = Colors.orange;
        label = 'Verified';
        icon = Icons.check_circle;
        break;
    }

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 16, color: Colors.amber);
        }
      }),
    );
  }
}

class AppDetailsScreen extends StatelessWidget {
  final FinancialApp app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Image.network(
                app.iconUrl,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, _) => Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              app.developer,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Install app logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Installing ${app.name}...'),
                            ),
                          );
                        },
                        child: const Text('Install'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildComplianceSection(app),
                  const SizedBox(height: 16),
                  const Text(
                    'About this app',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(app.description),
                  const SizedBox(height: 16),
                  const Text(
                    'Security Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSecurityFeatures(app),
                  const SizedBox(height: 16),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionsList(app),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceSection(FinancialApp app) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Compliance & Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildComplianceBadgeRow(app.complianceLevel),
            const SizedBox(height: 8),
            Text(
              'Last Audit: ${app.lastAuditDate}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            if (app.auditReport.isNotEmpty)
              TextButton(
                onPressed: () {
                  // View audit report logic
                },
                child: const Text('View Audit Report'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceBadgeRow(ComplianceLevel level) {
    final List<Widget> badges = [];

    // Always show all badges but highlight the achieved ones
    badges.add(_buildComplianceLevelBadge(
      'Basic Verification',
      Colors.green,
      active: true,
    ));

    badges.add(_buildComplianceLevelBadge(
      'PCI-DSS',
      Colors.blue,
      active: level == ComplianceLevel.pciDss || level == ComplianceLevel.rbiCertified,
    ));

    badges.add(_buildComplianceLevelBadge(
      'RBI Certified',
      Colors.purple,
      active: level == ComplianceLevel.rbiCertified,
    ));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges,
    );
  }

  Widget _buildComplianceLevelBadge(String text, Color color, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.2) : Colors.grey.shade200,
        border: Border.all(
          color: active ? color : Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: active ? color : Colors.grey.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: active ? color : Colors.grey.shade400,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeatures(FinancialApp app) {
    return Column(
      children: [
        _buildSecurityFeatureRow(
          'End-to-End Encryption',
          app.securityFeatures.contains('encryption'),
        ),
        _buildSecurityFeatureRow(
          'Biometric Authentication',
          app.securityFeatures.contains('biometric'),
        ),
        _buildSecurityFeatureRow(
          'Transaction Monitoring',
          app.securityFeatures.contains('monitoring'),
        ),
        _buildSecurityFeatureRow(
          'Fraud Protection',
          app.securityFeatures.contains('fraud_protection'),
        ),
      ],
    );
  }

  Widget _buildSecurityFeatureRow(String feature, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red.shade300,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              color: isAvailable ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList(FinancialApp app) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: app.permissions.length,
      itemBuilder: (context, index) {
        final permission = app.permissions[index];
        return ListTile(
          leading: Icon(
            _getPermissionIcon(permission),
            color: Colors.blue.shade700,
          ),
          title: Text(permission),
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  IconData _getPermissionIcon(String permission) {
    switch (permission.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'location':
        return Icons.location_on;
      case 'contacts':
        return Icons.contacts;
      case 'storage':
        return Icons.storage;
      case 'microphone':
        return Icons.mic;
      case 'sms':
        return Icons.sms;
      default:
        return Icons.apps;
    }
  }
}

class AppRequestDialog extends StatefulWidget {
  const AppRequestDialog({super.key});

  @override
  State<AppRequestDialog> createState() => _AppRequestDialogState();
}

class _AppRequestDialogState extends State<AppRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _developerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();

  @override
  void dispose() {
    _appNameController.dispose();
    _developerController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request App Addition'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _appNameController,
                decoration: const InputDecoration(
                  labelText: 'App Name',
                  hintText: 'Enter the name of the app',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _developerController,
                decoration: const InputDecoration(
                  labelText: 'Developer Name',
                  hintText: 'Enter the developer name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter developer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter a brief description of the app',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'Enter your contact email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Submit the form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request submitted successfully')),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// Models

enum ComplianceLevel {
  basic,
  pciDss,
  rbiCertified,
}

class FinancialApp {
  final String id;
  final String name;
  final String developer;
  final String description;
  final String iconUrl;
  final double rating;
  final ComplianceLevel complianceLevel;
  final List<String> securityFeatures;
  final List<String> permissions;
  final String lastAuditDate;
  final String auditReport;
  final String category;

  FinancialApp({
    required this.id,
    required this.name,
    required this.developer,
    required this.description,
    required this.iconUrl,
    required this.rating,
    required this.complianceLevel,
    required this.securityFeatures,
    required this.permissions,
    required this.lastAuditDate,
    this.auditReport = '',
    required this.category,
  });
}

// Mock Data
final List<FinancialApp> mockRbiApps = [
  FinancialApp(
    id: 'app1',
    name: 'SecurePay',
    developer: 'RBI Finance Tech',
    description: 'Official RBI certified payment app with state-of-the-art security features and fraud protection. Supports all major banks and UPI payment methods.',
    iconUrl: 'https://picsum.photos/200',
    rating: 4.8,
    complianceLevel: ComplianceLevel.rbiCertified,
    securityFeatures: ['encryption', 'biometric', 'monitoring', 'fraud_protection'],
    permissions: ['Camera', 'Location', 'Contacts'],
    lastAuditDate: '15 March 2025',
    auditReport: 'RBI-A-23421',
    category: 'RBI Approved',
  ),
  FinancialApp(
    id: 'app2',
    name: 'BankSafe',
    developer: 'National Banking Solutions',
    description: 'Official banking app with direct integration to the National Banking Network. Secure transactions and real-time account monitoring.',
    iconUrl: 'https://picsum.photos/201',
    rating: 4.7,
    complianceLevel: ComplianceLevel.rbiCertified,
    securityFeatures: ['encryption', 'biometric', 'monitoring', 'fraud_protection'],
    permissions: ['Camera', 'Location', 'Storage', 'SMS'],
    lastAuditDate: '02 April 2025',
    auditReport: 'RBI-A-23587',
    category: 'RBI Approved',
  ),
  FinancialApp(
    id: 'app3',
    name: 'GovPay',
    developer: 'Government Financial Systems',
    description: 'Official government payment app for taxes, fees, and public services. Directly integrated with government databases.',
    iconUrl: 'https://picsum.photos/202',
    rating: 4.5,
    complianceLevel: ComplianceLevel.rbiCertified,
    securityFeatures: ['encryption', 'biometric', 'monitoring'],
    permissions: ['Camera', 'Location', 'Contacts', 'Storage'],
    lastAuditDate: '20 February 2025',
    auditReport: 'RBI-A-23110',
    category: 'RBI Approved',
  ),
  FinancialApp(
    id: 'app4',
    name: 'CryptoSecure',
    developer: 'Digital Asset Solutions',
    description: 'RBI-compliant cryptocurrency trading platform with advanced security protocols and regulatory compliance.',
    iconUrl: 'https://picsum.photos/203',
    rating: 4.3,
    complianceLevel: ComplianceLevel.rbiCertified,
    securityFeatures: ['encryption', 'biometric', 'monitoring', 'fraud_protection'],
    permissions: ['Camera', 'Location', 'Storage'],
    lastAuditDate: '12 January 2025',
    auditReport: 'RBI-A-22980',
    category: 'RBI Approved',
  ),
];

final List<FinancialApp> mockUpiApps = [
  FinancialApp(
    id: 'app5',
    name: 'FastPay UPI',
    developer: 'Digital Payments Inc.',
    description: 'Fast and secure UPI payments app with wide bank support and instant transfers. Supports all major UPI handles.',
    iconUrl: 'https://picsum.photos/204',
    rating: 4.6,
    complianceLevel: ComplianceLevel.pciDss,
    securityFeatures: ['encryption', 'biometric', 'monitoring'],
    permissions: ['Camera', 'Contacts', 'SMS'],
    lastAuditDate: '10 March 2025',
    category: 'UPI',
  ),
  FinancialApp(
    id: 'app6',
    name: 'UPI Connect',
    developer: 'NextGen Payments',
    description: 'Streamlined UPI payment experience with QR code scanning and transaction history tracking.',
    iconUrl: 'https://picsum.photos/205',
    rating: 4.4,
    complianceLevel: ComplianceLevel.pciDss,
    securityFeatures: ['encryption', 'biometric'],
    permissions: ['Camera', 'Contacts', 'Storage'],
    lastAuditDate: '05 February 2025',
    category: 'UPI',
  ),
  FinancialApp(
    id: 'app7',
    name: 'PayMaster',
    developer: 'Financial Technologies',
    description: 'All-in-one UPI payment solution with bill payments, recharges, and bank transfers.',
    iconUrl: 'https://picsum.photos/206',
    rating: 4.2,
    complianceLevel: ComplianceLevel.basic,
    securityFeatures: ['encryption', 'monitoring'],
    permissions: ['Camera', 'Contacts', 'Location', 'Storage'],
    lastAuditDate: '25 January 2025',
    category: 'UPI',
  ),
  FinancialApp(
    id: 'app8',
    name: 'Money Transfer',
    developer: 'Safe Payments Ltd.',
    description: 'Simple and reliable UPI money transfer app with low transaction fees and high security.',
    iconUrl: 'https://picsum.photos/207',
    rating: 4.0,
    complianceLevel: ComplianceLevel.basic,
    securityFeatures: ['encryption'],
    permissions: ['Camera', 'Contacts'],
    lastAuditDate: '18 December 2024',
    category: 'UPI',
  ),
];

final List<FinancialApp> mockWalletApps = [
  FinancialApp(
    id: 'app9',
    name: 'SecureWallet',
    developer: 'Digital Security Solutions',
    description: 'Digital wallet with multi-currency support and high-security encryption for all transactions.',
    iconUrl: 'https://picsum.photos/208',
    rating: 4.7,
    complianceLevel: ComplianceLevel.pciDss,
    securityFeatures: ['encryption', 'biometric', 'monitoring', 'fraud_protection'],
    permissions: ['Camera', 'Location', 'Contacts', 'Storage'],
    lastAuditDate: '28 March 2025',
    category: 'Wallets',
  ),
  FinancialApp(
    id: 'app10',
    name: 'CashBag',
    developer: 'Modern Wallets Inc.',
    description: 'Mobile wallet with cashback rewards and loyalty programs. Store all your payment cards in one place.',
    iconUrl: 'https://picsum.photos/209',
    rating: 4.5,
    complianceLevel: ComplianceLevel.pciDss,
    securityFeatures: ['encryption', 'biometric'],
    permissions: ['Camera', 'Location', 'Storage'],
    lastAuditDate: '15 February 2025',
    category: 'Wallets',
  ),
  FinancialApp(
    id: 'app11',
    name: 'QuickPay',
    developer: 'Fast Financial Tech',
    description: 'Quick and easy digital wallet with tap-to-pay functionality and online shopping integration.',
    iconUrl: 'https://picsum.photos/210',
    rating: 4.3,
    complianceLevel: ComplianceLevel.basic,
    securityFeatures: ['encryption', 'monitoring'],
    permissions: ['Camera', 'Location', 'Storage', 'SMS'],
    lastAuditDate: '05 January 2025',
    category: 'Wallets',
  ),
];

final List<FinancialApp> mockCreditApps = [
  FinancialApp(
    id: 'app12',
    name: 'Credit Buddy',
    developer: 'Financial Freedom Ltd.',
    description: 'Personal credit management app with score tracking, improvement tips, and loan options.',
    iconUrl: 'https://picsum.photos/211',
    rating: 4.6,
    complianceLevel: ComplianceLevel.rbiCertified,
    securityFeatures: ['encryption', 'biometric', 'monitoring'],
    permissions: ['Camera', 'Contacts', 'Storage'],
    lastAuditDate: '20 March 2025',
    auditReport: 'RBI-A-23510',
    category: 'Credit Apps',
  ),
  FinancialApp(
    id: 'app13',
    name: 'LoanPro',
    developer: 'Credit Solutions Inc.',
    description: 'Instant loan approval app with multiple lender options and transparent interest rates.',
    iconUrl: 'https://picsum.photos/212',
    rating: 4.4,
    complianceLevel: ComplianceLevel.pciDss,
    securityFeatures: ['encryption', 'biometric'],
    permissions: ['Camera', 'Contacts', 'Storage', 'Location'],
    lastAuditDate: '10 February 2025',
    category: 'Credit Apps',
  ),
  FinancialApp(
    id: 'app14',
    name: 'CardMaster',
    developer: 'Global Credit Services',
    description: 'Credit card management app with spending analysis, bill payments, and reward tracking.',
    iconUrl: 'https://picsum.photos/213',
    rating: 4.2,
    complianceLevel: ComplianceLevel.basic,
    securityFeatures: ['encryption'],
    permissions: ['Camera', 'Storage'],
    lastAuditDate: '01 January 2025',
    category: 'Credit Apps',
  ),
];