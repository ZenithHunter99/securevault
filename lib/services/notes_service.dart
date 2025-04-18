import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A model class representing an encrypted note
class SecureNote {
  String id;
  String title;
  String content;
  DateTime timestamp;
  String? encryptionKeyId;

  SecureNote({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.encryptionKeyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'encryptionKeyId': encryptionKeyId,
    };
  }

  factory SecureNote.fromJson(Map<String, dynamic> json) {
    return SecureNote(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      encryptionKeyId: json['encryptionKeyId'],
    );
  }
}

/// Service responsible for managing encrypted notes
class NotesService {
  static const String _notesKey = 'encrypted_notes';
  
  /// Mock encryption - in a real app, this would use proper encryption
  String _encryptContent(String content, String noteKeyId) {
    // This is just a placeholder for real encryption
    // In a production app, you'd use a proper encryption library
    final bytes = utf8.encode(content);
    final base64 = base64Encode(bytes);
    return base64;
  }

  /// Mock decryption - in a real app, this would use proper decryption
  String _decryptContent(String encryptedContent, String noteKeyId) {
    // This is just a placeholder for real decryption
    try {
      final bytes = base64Decode(encryptedContent);
      return utf8.decode(bytes);
    } catch (e) {
      // In case the content wasn't actually encrypted (for development)
      return encryptedContent;
    }
  }

  /// Generate a unique ID for a new note
  String _generateNoteId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Generate a mock encryption key ID
  /// In a real implementation, this would create or reference an actual encryption key
  String _generateEncryptionKeyId() {
    return "key_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Save all notes to SharedPreferences
  Future<void> _saveNotes(List<SecureNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((note) => note.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  /// Load all notes from SharedPreferences
  Future<List<SecureNote>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson == null || notesJson.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(notesJson) as List;
      final notes = jsonList
          .map((json) => SecureNote.fromJson(json))
          .toList();
      
      // Decrypt all note contents
      for (var i = 0; i < notes.length; i++) {
        if (notes[i].encryptionKeyId != null) {
          notes[i].content = _decryptContent(
              notes[i].content, 
              notes[i].encryptionKeyId!
          );
        }
      }
      
      return notes;
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  /// Add a new note with encrypted content
  Future<SecureNote> addNote(String title, String content) async {
    final notes = await getAllNotes();
    
    // Generate a unique ID and encryption key ID for the note
    final String noteId = _generateNoteId();
    final String keyId = _generateEncryptionKeyId();
    
    // Encrypt the content
    final encryptedContent = _encryptContent(content, keyId);
    
    // Create the new note
    final newNote = SecureNote(
      id: noteId,
      title: title,
      content: encryptedContent,
      timestamp: DateTime.now(),
      encryptionKeyId: keyId,
    );
    
    // Add to list and save
    notes.add(newNote);
    await _saveNotes(notes);
    
    // Return the note with decrypted content for the UI
    return SecureNote(
      id: newNote.id,
      title: newNote.title,
      content: content, // Return the original unencrypted content
      timestamp: newNote.timestamp,
      encryptionKeyId: newNote.encryptionKeyId,
    );
  }

  /// Update an existing note
  Future<bool> updateNote(String id, {String? title, String? content}) async {
    final notes = await getAllNotes();
    final index = notes.indexWhere((note) => note.id == id);
    
    if (index == -1) {
      return false;
    }
    
    // Get the existing note
    final note = notes[index];
    
    // Update the fields if provided
    if (title != null) {
      note.title = title;
    }
    
    if (content != null) {
      // Re-encrypt with the existing key
      final keyId = note.encryptionKeyId ?? _generateEncryptionKeyId();
      note.content = _encryptContent(content, keyId);
      note.encryptionKeyId = keyId;
    }
    
    // Update timestamp
    note.timestamp = DateTime.now();
    
    // Save the updated list
    await _saveNotes(notes);
    return true;
  }

  /// Delete a note by its ID
  Future<bool> deleteNote(String id) async {
    final notes = await getAllNotes();
    final initialLength = notes.length;
    
    notes.removeWhere((note) => note.id == id);
    
    if (notes.length < initialLength) {
      await _saveNotes(notes);
      return true;
    }
    
    return false;
  }

  /// Get a single note by ID
  Future<SecureNote?> getNoteById(String id) async {
    final notes = await getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete all notes (for testing or reset functionality)
  Future<void> deleteAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
  }
}