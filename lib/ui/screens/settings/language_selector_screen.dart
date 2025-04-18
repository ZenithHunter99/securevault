import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class LanguageSelectorScreen extends StatefulWidget {
  static const String routeName = '/language-selector';

  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  bool _languageChanged = false;
  late String _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': 'assets/flags/gb.svg'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी', 'flag': 'assets/flags/in.svg'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা', 'flag': 'assets/flags/bd.svg'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்', 'flag': 'assets/flags/in.svg'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు', 'flag': 'assets/flags/in.svg'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ', 'flag': 'assets/flags/in.svg'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം', 'flag': 'assets/flags/in.svg'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी', 'flag': 'assets/flags/in.svg'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ', 'flag': 'assets/flags/in.svg'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી', 'flag': 'assets/flags/in.svg'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو', 'flag': 'assets/flags/pk.svg'},
    {'code': 'or', 'name': 'Odia', 'nativeName': 'ଓଡ଼ିଆ', 'flag': 'assets/flags/in.svg'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Select Language', style: theme.textTheme.titleLarge),
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = language['code'] == _selectedLanguage;
                
                return LanguageCard(
                  language: language,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language['code']!;
                      _languageChanged = _selectedLanguage != languageProvider.currentLanguageCode;
                    });
                  },
                );
              },
            ),
          ),
          if (_languageChanged)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    languageProvider.setLanguage(_selectedLanguage);
                    _showRestartDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply and Restart App',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text(
            'The app needs to restart to apply the language change. Would you like to restart now?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                // In a real app, you'd implement app restart logic here
                // For now, we'll just simulate by returning to home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Restart Now'),
            ),
          ],
        );
      },
    );
  }
}

class LanguageCard extends StatelessWidget {
  final Map<String, String> language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: isSelected 
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 24,
                child: SvgPicture.asset(
                  language['flag']!,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name']!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language['nativeName']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}