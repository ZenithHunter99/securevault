import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/models/language.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Language> _indianLanguages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'hi', name: 'हिन्दी (Hindi)'),
    Language(code: 'bn', name: 'বাংলা (Bengali)'),
    Language(code: 'te', name: 'తెలుగు (Telugu)'),
    Language(code: 'mr', name: 'मराठी (Marathi)'),
    Language(code: 'ta', name: 'தமிழ் (Tamil)'),
    Language(code: 'gu', name: 'ગુજરાતી (Gujarati)'),
    Language(code: 'kn', name: 'ಕನ್ನಡ (Kannada)'),
    Language(code: 'ml', name: 'മലയാളം (Malayalam)'),
    Language(code: 'pa', name: 'ਪੰਜਾਬੀ (Punjabi)'),
    Language(code: 'ur', name: 'اردو (Urdu)'),
    Language(code: 'or', name: 'ଓଡ଼ିଆ (Odia)'),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentLanguage = settingsService.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildSectionHeader('Security'),
            ListTile(
              leading: const Icon(Icons.lock_person, color: Colors.red),
              title: const Text('Lockdown Now'),
              subtitle: const Text('Immediately lock all vault access'),
              trailing: const Icon(Icons.warning, color: Colors.red),
              onTap: () => _showLockdownConfirmation(context, authService),
            ),
            ListTile(
              leading: const Icon(Icons.app_blocking, color: Colors.blue),
              title: const Text('Manage Trusted Apps'),
              subtitle: const Text('Control which apps can access your vault'),
              onTap: () => Navigator.pushNamed(context, '/settings/trusted-apps'),
            ),
            const Divider(),
            
            _buildSectionHeader('Language'),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: const Text('App Language'),
              subtitle: Text(currentLanguage?.name ?? 'English'),
              onTap: () => _showLanguageSelector(context, settingsService),
            ),
            const Divider(),
            
            _buildSectionHeader('About'),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.purple),
              title: const Text('Privacy Policy'),
              onTap: () => Navigator.pushNamed(context, '/settings/privacy-policy'),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('About SecureVault'),
              subtitle: const Text('Version 1.0.0'),
              onTap: () => Navigator.pushNamed(context, '/settings/about'),
            ),
            const Divider(),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _signOut(context, authService),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsService settingsService) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _indianLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _indianLanguages[index];
                    final isSelected = settingsService.currentLanguage?.code == language.code;
                    
                    return ListTile(
                      title: Text(language.name),
                      trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                      onTap: () {
                        settingsService.setLanguage(language);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLockdownConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Lockdown'),
        content: const Text(
          'This will immediately lock all vault access and require full authentication to restore access. Continue?'
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lockdown Now'),
            onPressed: () {
              authService.emergencyLockdown();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency lockdown activated'),
                  backgroundColor: Colors.red,
                )
              );
              Navigator.pushNamedAndRemoveUntil(
                context, '/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[900],
            ),
            child: const Text('Sign Out'),
            onPressed: () {
              authService.signOut();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context, '/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}