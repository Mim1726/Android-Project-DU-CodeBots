import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:open_file/open_file.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;

  const ChatScreen({super.key, required this.recipeId, required this.recipeTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
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

    final existing = await qaRef.where('askedBy', isEqualTo: user.uid).limit(1).get();

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
        _messages = snapshot.docs.map((doc) => doc.data()).toList();
      });
    });
  }

  Future<void> _sendMessage({String text = '', String imageUrl = '', String fileUrl = ''}) async {
    String messageText = _controller.text.trim();
    if (messageText.isEmpty && text.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa')
        .doc(questionId)
        .collection('messages')
        .add({
      'text': text.isNotEmpty ? text : messageText,
      'senderId': user.uid,
      'senderEmail': user.email ?? '',
      'senderType': 'user',
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    });

    _controller.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final ref = FirebaseStorage.instance.ref('qa_uploads/images/${DateTime.now().millisecondsSinceEpoch}');
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
    final timestamp = msg['timestamp']?.toDate();
    final timeAgo = timestamp != null ? timeago.format(timestamp) : '';
    final senderEmail = msg['senderEmail'] ?? 'User';
    final initial = senderEmail.isNotEmpty ? senderEmail[0].toUpperCase() : '?';

    Widget content;
    if (msg['imageUrl'] != null && msg['imageUrl'] != '') {
      content = Image.network(msg['imageUrl'], width: 150, height: 150, fit: BoxFit.cover);
    } else if (msg['fileUrl'] != null && msg['fileUrl'] != '') {
      content = GestureDetector(
        onTap: () => OpenFile.open(msg['fileUrl']),
        child: const Text("📎 File", style: TextStyle(decoration: TextDecoration.underline, color: Colors.deepOrange)),
      );
    } else {
      content = Text(msg['text'] ?? '', style: const TextStyle(color: Colors.black));
    }

    return Align(
      alignment: isDev ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDev ? Colors.white : Colors.deepOrange.shade50,
          border: Border.all(color: Colors.deepOrange.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(initial, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(senderEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            content,
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 18, color: Colors.deepOrange)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.reply, size: 18, color: Colors.deepOrange)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Material(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.recipeTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'most_relevant', child: Text("Most Relevant")),
                        DropdownMenuItem(value: 'recent', child: Text("Recent")),
                        DropdownMenuItem(value: 'all', child: Text("All Comments")),
                      ],
                      onChanged: (value) {},
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessage(message);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black26)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.file_upload, color: Colors.deepOrange), onPressed: _pickFile),
                  IconButton(icon: const Icon(Icons.image, color: Colors.deepOrange), onPressed: _pickImage),
                  IconButton(
                    icon: const Icon(Icons.keyboard_voice, color: Colors.deepOrange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Voice message coming soon 🎤")),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepOrange),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepOrange),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepOrange),
                    onPressed: () => _sendMessage(text: _controller.text.trim()),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
