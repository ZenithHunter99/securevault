import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/policy.dart';
import '../../providers/policy_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_styles.dart';
import '../components/app_bar.dart';
import '../components/secure_vault_drawer.dart';

class PolicyCenterScreen extends StatelessWidget {
  const PolicyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SecureVaultAppBar(title: 'Policy Center'),
      drawer: const SecureVaultDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<PolicyProvider>(
      builder: (context, policyProvider, _) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _buildPolicyList(context, policyProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.backgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Policies',
            style: AppTextStyles.heading.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and monitor security policies enforced by SecureVault',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('✅ Active', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem('⚠️ Violated', Colors.orange),
        const SizedBox(width: 16),
        _buildLegendItem('❌ Off', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPolicyList(BuildContext context, PolicyProvider policyProvider) {
    final policies = policyProvider.policies;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final policy = policies[index];
        return _buildPolicyCard(context, policy, policyProvider);
      },
    );
  }

  Widget _buildPolicyCard(BuildContext context, Policy policy, PolicyProvider policyProvider) {
    String statusIcon;
    Color statusColor;
    
    if (policy.isActive && !policy.isViolated) {
      statusIcon = '✅';
      statusColor = Colors.green;
    } else if (policy.isViolated) {
      statusIcon = '⚠️';
      statusColor = Colors.orange;
    } else {
      statusIcon = '❌';
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: policy.isViolated ? Colors.orange : Colors.grey.shade300,
          width: policy.isViolated ? 1.5 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      statusIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.name,
                        style: AppTextStyles.subtitle,
                      ),
                      Text(
                        _getStatusText(policy),
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!policy.isCritical)
                  Switch(
                    value: policy.isActive,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      policyProvider.togglePolicy(policy.id, value);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              policy.description,
              style: AppTextStyles.body,
            ),
            if (policy.isViolated && policy.violationDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        policy.violationDetails!,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (policy.isCritical) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Critical policy - cannot be disabled',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            if (policy.isViolated && !policy.isCritical) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Action to resolve violation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resolving policy violation...'),
                    ),
                  );
                },
                child: const Text('Resolve Issue'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(Policy policy) {
    if (policy.isViolated) return 'Policy Violated';
    if (policy.isActive) return 'Active';
    return 'Disabled';
  }
}