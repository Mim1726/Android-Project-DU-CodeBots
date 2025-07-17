// dChatReplyPage.dart
import 'dart:io';
import 'package:flutter/material.dart';          // ← dart:ui import removed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

class DChatReplyPage extends StatefulWidget {
  final String recipeId;
  final String questionId;

  const DChatReplyPage({
    super.key,
    required this.recipeId,
    required this.questionId,
  });

  @override
  State<DChatReplyPage> createState() => _DChatReplyPageState();
}

class _DChatReplyPageState extends State<DChatReplyPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa')
        .doc(widget.questionId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> updatedMessages = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Mark user messages as seen
        if (data['senderType'] == 'user' && (data['seen'] != true)) {
          doc.reference.update({'seen': true});
        }

        updatedMessages.add(data);
      }

      setState(() {
        _messages = updatedMessages;
      });
    });
  }

  Future<void> _sendMessage({
    String text = '',
    String imageUrl = '',
    String fileUrl = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (text.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa')
        .doc(widget.questionId)
        .collection('messages')
        .add({
      'text': text,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'senderType': 'developer',
      'senderId': user.uid,
      'senderEmail': user.email ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'type': imageUrl.isNotEmpty
          ? 'image'
          : fileUrl.isNotEmpty
          ? 'file'
          : 'text',
    });

    _controller.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final ref = FirebaseStorage.instance
        .ref('qa_uploads/images/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(file.path));
    final url = await ref.getDownloadURL();

    await _sendMessage(imageUrl: url);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;
    final ref = FirebaseStorage.instance.ref('qa_uploads/files/$name');
    await ref.putFile(File(path));
    final url = await ref.getDownloadURL();

    await _sendMessage(fileUrl: url);
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isDev = msg['senderType'] == 'developer';
    final text = msg['text'] ?? '';
    final imageUrl = msg['imageUrl'] ?? '';
    final fileUrl = msg['fileUrl'] ?? '';

    Widget content;
    if (imageUrl.isNotEmpty) {
      content = Image.network(
        imageUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (fileUrl.isNotEmpty) {
      content = GestureDetector(
        onTap: () => OpenFile.open(fileUrl),
        child: Text(
          '📎 File',
          style: TextStyle(
            color: isDev ? Colors.white : Colors.black,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      content = Text(
        text,
        style: TextStyle(
          color: isDev ? Colors.white : Colors.black,
        ),
      );
    }

    return Align(
      alignment: isDev ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDev ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDev
              ? null
              : Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Developer Reply',
          style: TextStyle(color: Colors.deepOrange),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
        elevation: 2,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Plain white overlay (no blur)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7), // Change opacity as desired
            ),
          ),

          // Chat UI
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    return _buildMessage(message);
                  },
                ),
              ),
              Container(
                color: Colors.deepOrange,
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.file_upload, color: Colors.white),
                      onPressed: _pickFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Type message...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () =>
                          _sendMessage(text: _controller.text.trim()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
