import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../models/encrypted_note.dart';
import '../../../services/encryption_service.dart';

class EncryptedNotesScreen extends StatefulWidget {
  const EncryptedNotesScreen({super.key});

  @override
  _EncryptedNotesScreenState createState() => _EncryptedNotesScreenState();
}

class _EncryptedNotesScreenState extends State<EncryptedNotesScreen> {
  final EncryptionService _encryptionService = EncryptionService();
  
  // Mock list of encrypted notes
  List<EncryptedNote> _notes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }
  
  Future<void> _loadNotes() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data
    setState(() {
      _notes = [
        EncryptedNote(
          id: '1',
          encryptedTitle: 'Operation Blueprint',
          encryptedContent: 'Deployment coordinates: 34.0522° N, 118.2437° W. Awaiting confirmation.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          modifiedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        EncryptedNote(
          id: '2',
          encryptedTitle: 'Asset Protocol Alpha',
          encryptedContent: 'Access codes changed. New rotation schedule implemented. Verify with command.',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        EncryptedNote(
          id: '3',
          encryptedTitle: 'Security Clearance Updates',
          encryptedContent: 'Personnel with level B access must renew credentials by EOQ. New biometric systems pending installation.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          modifiedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _isLoading = false;
    });
  }

  void _viewNoteDetails(EncryptedNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NoteDetailScreen(
          note: note,
          encryptionService: _encryptionService,
          onUpdate: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
          },
          onDelete: (noteId) {
            setState(() {
              _notes.removeWhere((n) => n.id == noteId);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _createNewNote() {
    final newNote = EncryptedNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      encryptedTitle: '',
      encryptedContent: '',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NoteDetailScreen(
          note: newNote,
          encryptionService: _encryptionService,
          isNew: true,
          onUpdate: (updatedNote) {
            setState(() {
              _notes.insert(0, updatedNote);
            });
          },
          onDelete: (_) {
            // Do nothing for new notes that are canceled
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFF00FF7F)),
            SizedBox(width: 10),
            Text(
              'ENCRYPTED VAULT',
              style: TextStyle(
                color: Color(0xFFEEEEEE),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF7F)),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadNotes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00FF7F),
              ),
            )
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Color(0xFF444444),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No secure notes found',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create a new encrypted note',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notes.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFF333333),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return _NoteListItem(
                      note: note,
                      encryptionService: _encryptionService,
                      onTap: () => _viewNoteDetails(note),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FF7F),
        onPressed: _createNewNote,
        child: const Icon(
          Icons.add,
          color: Color(0xFF121212),
        ),
      ),
    );
  }
}

class _NoteListItem extends StatelessWidget {
  final EncryptedNote note;
  final EncryptionService encryptionService;
  final VoidCallback onTap;

  const _NoteListItem({
    required this.note,
    required this.encryptionService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM/dd/yyyy – HH:mm').format(note.modifiedAt);
    final decryptedTitle = encryptionService.mockDecrypt(note.encryptedTitle);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      tileColor: const Color(0xFF1A1A1A),
      title: Row(
        children: [
          const Icon(
            Icons.lock,
            size: 16,
            color: Color(0xFF00FF7F),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              decryptedTitle.isEmpty ? 'Untitled Note' : decryptedTitle,
              style: const TextStyle(
                color: Color(0xFFEEEEEE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 14,
              color: Color(0xFF888888),
            ),
            const SizedBox(width: 4),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.enhanced_encryption,
                    size: 12,
                    color: Color(0xFF00FF7F),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'AES-256',
                    style: TextStyle(
                      color: Color(0xFF00FF7F),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _NoteDetailScreen extends StatefulWidget {
  final EncryptedNote note;
  final EncryptionService encryptionService;
  final Function(EncryptedNote) onUpdate;
  final Function(String) onDelete;
  final bool isNew;

  const _NoteDetailScreen({
    required this.note,
    required this.encryptionService,
    required this.onUpdate,
    required this.onDelete,
    this.isNew = false,
  });

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<_NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _isEncrypting = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isNew;
    
    // Initialize controllers with decrypted content
    _titleController = TextEditingController(
      text: widget.encryptionService.mockDecrypt(widget.note.encryptedTitle),
    );
    _contentController = TextEditingController(
      text: widget.encryptionService.mockDecrypt(widget.note.encryptedContent),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveNote() async {
    setState(() {
      _isEncrypting = true;
    });

    // Simulate encryption delay
    await Future.delayed(const Duration(milliseconds: 800));

    final updatedNote = EncryptedNote(
      id: widget.note.id,
      encryptedTitle: widget.encryptionService.mockEncrypt(_titleController.text),
      encryptedContent: widget.encryptionService.mockEncrypt(_contentController.text),
      createdAt: widget.note.createdAt,
      modifiedAt: DateTime.now(),
    );

    widget.onUpdate(updatedNote);

    setState(() {
      _isEncrypting = false;
      _isEditing = false;
    });
    
    if (widget.isNew) {
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'Confirm Deletion',
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
          ],
        ),
        content: const Text(
          'This note will be permanently deleted and cannot be recovered. Continue?',
          style: TextStyle(color: Color(0xFFCCCCCC)),
        ),
        actions: [
          TextButton(
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFF888888)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(widget.note.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decryptedTitle = _isEditing
        ? _titleController.text
        : widget.encryptionService.mockDecrypt(widget.note.encryptedTitle);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF00FF7F)),
            const SizedBox(width: 10),
            Text(
              decryptedTitle.isEmpty ? 'NEW SECURE NOTE' : 'SECURE NOTE',
              style: const TextStyle(
                color: Color(0xFFEEEEEE),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isNew && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _showDeleteConfirmation,
            ),
          if (_isEditing)
            _isEncrypting
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF00FF7F),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_outlined, color: Color(0xFF00FF7F)),
                    onPressed: _saveNote,
                  )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF00FF7F)),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: _isEncrypting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Color(0xFF00FF7F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _EncryptionAnimation(),
                  const SizedBox(height: 20),
                  Text(
                    'Encrypting Note Data',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 16,
                              color: Color(0xFF00FF7F),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TITLE',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF333333),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '🔒 Encrypted',
                                style: TextStyle(
                                  color: Color(0xFF00FF7F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                                controller: _titleController,
                                style: const TextStyle(
                                  color: Color(0xFFEEEEEE),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Enter note title',
                                  hintStyle: TextStyle(color: Color(0xFF666666)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                            : Text(
                                decryptedTitle.isEmpty ? 'Untitled Note' : decryptedTitle,
                                style: const TextStyle(
                                  color: Color(0xFFEEEEEE),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '🕓 Last Modified: ${DateFormat('MM/dd/yyyy – HH:mm').format(widget.note.modifiedAt)}',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                size: 16,
                                color: Color(0xFF00FF7F),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CONTENT',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF333333),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.enhanced_encryption,
                                      size: 12,
                                      color: Color(0xFF00FF7F),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'AES-256',
                                      style: TextStyle(
                                        color: Color(0xFF00FF7F),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _isEditing
                                ? TextField(
                                    controller: _contentController,
                                    maxLines: null,
                                    expands: true,
                                    style: const TextStyle(
                                      color: Color(0xFFEEEEEE),
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter note content',
                                      hintStyle: TextStyle(color: Color(0xFF666666)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Text(
                                      widget.encryptionService.mockDecrypt(widget.note.encryptedContent),
                                      style: const TextStyle(
                                        color: Color(0xFFEEEEEE),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
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
}

class _EncryptionAnimation extends StatefulWidget {
  const _EncryptionAnimation();

  @override
  _EncryptionAnimationState createState() => _EncryptionAnimationState();
}

class _EncryptionAnimationState extends State<_EncryptionAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _encryptionText = [];
  final int _maxChars = 60;
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,./<>?';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          if (_encryptionText.length < _maxChars) {
            _encryptionText.add(_chars[math.Random().nextInt(_chars.length)]);
          } else {
            _encryptionText[math.Random().nextInt(_maxChars)] = _chars[math.Random().nextInt(_chars.length)];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _encryptionText.join(''),
      style: const TextStyle(
        color: Color(0xFF00FF7F),
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    );
  }
}