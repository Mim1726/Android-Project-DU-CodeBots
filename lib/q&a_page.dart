import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String recipeId;

  const ChatScreen({super.key, required this.recipeId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? questionId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final qaRef = FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa');

    final existing =
    await qaRef.where('askedBy', isEqualTo: user.uid).limit(1).get();

    if (existing.docs.isNotEmpty) {
      questionId = existing.docs.first.id;
    } else {
      questionId = const Uuid().v4();
      await qaRef.doc(questionId).set({
        'askedBy': user.uid,
        'createdAt': Timestamp.now(),
      });
    }

    FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa')
        .doc(questionId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  Future<void> _sendMessage({
    String text = '',
    String imageUrl = '',
    String fileUrl = '',
  }) async {
    if (text.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa')
        .doc(questionId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': user.uid,
      'senderEmail': user.email ?? "",
      'senderType': 'user',
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'type': imageUrl.isNotEmpty
          ? 'image'
          : fileUrl.isNotEmpty
          ? 'file'
          : 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
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
    final isUser = msg['senderType'] == 'user';
    final text = msg['text'] ?? '';
    final imageUrl = msg['imageUrl'] ?? '';
    final fileUrl = msg['fileUrl'] ?? '';
    final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();
    final formattedTime = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp).format(context)
        : '';

    Widget content;
    if (imageUrl.isNotEmpty) {
      content = Image.network(imageUrl,
          width: 150, height: 150, fit: BoxFit.cover);
    } else if (fileUrl.isNotEmpty) {
      content = GestureDetector(
        onTap: () => OpenFile.open(fileUrl),
        child: Text(
          "📎 File",
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      );
    } else {
      content = Text(
        text,
        style: TextStyle(color: isUser ? Colors.white : Colors.black),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message Bubble
            GestureDetector(
              onLongPress: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null &&
                    msg['senderId'] == user.uid &&
                    msg['docId'] != null) {
                  final confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("Delete Message?"),
                      content: Text("Do you want to delete this message?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text("Cancel")),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text("Delete")),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('recipes')
                        .doc(widget.recipeId)
                        .collection('qa')
                        .doc(questionId)
                        .collection('messages')
                        .doc(msg['docId'])
                        .delete();
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUser ? Colors.deepOrange : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                  isUser ? null : Border.all(color: Colors.grey.shade300),
                ),
                child: content,
              ),
            ),

            // Metadata (Time & Seen)
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (formattedTime.isNotEmpty)
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                if (isUser && msg['seen'] == true) ...[
                  const SizedBox(width: 6),
                  Text(
                    "Seen",
                    style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Q & A",
          style: TextStyle(color: Colors.deepOrange),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message =
                    _messages[_messages.length - 1 - index];
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
                    IconButton(
                      icon: const Icon(Icons.keyboard_voice,
                          color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Voice message coming soon 🎤")),
                        );
                      },
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
