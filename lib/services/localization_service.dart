import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  // Singleton instance
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // Current language code (default to English)
  String _currentLanguageCode = 'en';
  
  // Cached translations
  Map<String, dynamic> _translations = {};
  
  // List of supported languages
  final List<LanguageInfo> supportedLanguages = [
    LanguageInfo('en', 'English', 'English'),
    LanguageInfo('hi', 'हिन्दी', 'Hindi'),
    LanguageInfo('bn', 'বাংলা', 'Bengali'),
    LanguageInfo('te', 'తెలుగు', 'Telugu'),
    LanguageInfo('mr', 'मराठी', 'Marathi'),
    LanguageInfo('ta', 'தமிழ்', 'Tamil'),
    LanguageInfo('gu', 'ગુજરાતી', 'Gujarati'),
    LanguageInfo('kn', 'ಕನ್ನಡ', 'Kannada'),
    LanguageInfo('ml', 'മലയാളം', 'Malayalam'),
    LanguageInfo('pa', 'ਪੰਜਾਬੀ', 'Punjabi'),
    LanguageInfo('or', 'ଓଡ଼ିଆ', 'Odia'),
    LanguageInfo('as', 'অসমীয়া', 'Assamese'),
    LanguageInfo('ur', 'اردو', 'Urdu'),
  ];

  // Getter for current language code
  String get currentLanguageCode => _currentLanguageCode;
  
  // Getter for current language info
  LanguageInfo get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLanguageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  // Initialize the service
  Future<void> init() async {
    await _loadSavedLanguage();
    await loadTranslations(_currentLanguageCode);
  }

  // Load the saved language preference
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString('language_code') ?? _getDeviceLanguage();
    
    // If the saved language is not supported, default to English
    if (!supportedLanguages.any((lang) => lang.code == _currentLanguageCode)) {
      _currentLanguageCode = 'en';
    }
  }
  
  // Get device language if available and supported
  String _getDeviceLanguage() {
    final deviceLocale = window.locale.languageCode;
    if (supportedLanguages.any((lang) => lang.code == deviceLocale)) {
      return deviceLocale;
    }
    return 'en'; // Default to English
  }

  // Change the current language
  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.any((lang) => lang.code == languageCode)) {
      return;
    }
    
    _currentLanguageCode = languageCode;
    
    // Save the language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    // Load the translations for the new language
    await loadTranslations(languageCode);
  }

  // Load translations for a specific language
  Future<void> loadTranslations(String languageCode) async {
    try {
      // Load the language file from assets
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      _translations = jsonDecode(jsonString);
    } catch (e) {
      print('Error loading translations: $e');
      // If loading fails, try to load English as fallback
      if (languageCode != 'en') {
        try {
          final jsonString = await rootBundle.loadString('assets/translations/en.json');
          _translations = jsonDecode(jsonString);
        } catch (e) {
          print('Error loading fallback translations: $e');
          // If even English fails, use empty translations
          _translations = {};
        }
      } else {
        // If English fails, use empty translations
        _translations = {};
      }
    }
  }

  // Translate a key
  String translate(String key) {
    // Split the key by dots for nested access
    final keys = key.split('.');
    
    // Navigate through the translation map
    dynamic value = _translations;
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        // Key not found, return the key itself
        return key;
      }
    }
    
    // Return the translated string or the key if value is not a string
    return value is String ? value : key;
  }
  
  // Get a widget for language selection
  Widget buildLanguageSelector(BuildContext context, {Function? onChanged}) {
    return DropdownButton<String>(
      value: _currentLanguageCode,
      icon: const Icon(Icons.language),
      underline: Container(
        height: 2,
        color: Theme.of(context).primaryColor,
      ),
      onChanged: (String? newValue) async {
        if (newValue != null) {
          await changeLanguage(newValue);
          if (onChanged != null) {
            onChanged();
          }
        }
      },
      items: supportedLanguages.map<DropdownMenuItem<String>>((LanguageInfo language) {
        return DropdownMenuItem<String>(
          value: language.code,
          child: Text('${language.name} (${language.englishName})'),
        );
      }).toList(),
    );
  }
  
  // Check if a key exists in the current translations
  bool hasTranslation(String key) {
    final keys = key.split('.');
    
    dynamic value = _translations;
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return false;
      }
    }
    
    return value is String;
  }
}

// Class to hold language information
class LanguageInfo {
  final String code;
  final String name;
  final String englishName;
  
  LanguageInfo(this.code, this.name, this.englishName);
}

// Extension method for easier translation
extension TranslationExtension on String {
  String get tr => LocalizationService().translate(this);
}