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

class chatScreen extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;

  const chatScreen({super.key, required this.recipeId, required this.recipeTitle});

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Set<String> _likedMessageIds = {};
  String? _replyingTo;
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
        .collection('review');

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
        .collection('review')
        .doc(questionId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        // _messages = snapshot.docs.map((doc) => doc.data()).toList();
        _messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'id': doc.id, // this allows us to uniquely reference each message
          };
        }).toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent);
          }
        });
      });
    });
  }

  Future<void> _sendMessage({String text = '', String imageUrl = '', String fileUrl = ''}) async {
    String messageText = _controller.text.trim();
    if (messageText.isEmpty && text.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    /*if(questionId == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait")),
      );
      return;
    }*/

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final senderUsername = userDoc.data()?['username'] ?? 'user';

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('review')
        .doc(questionId)
        .collection('messages')
        .add({
      'text': text.isNotEmpty ? text : messageText,
      'senderId': user.uid,
      'senderEmail': user.email ?? '',
      'senderUsername': senderUsername,
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
    final messageId = msg['id'] ?? ''; // Store message ID when adding messages
    final isLiked = _likedMessageIds.contains(messageId);
    final isDev = msg['senderType'] == 'developer';
    final timestamp = msg['timestamp']?.toDate();
    final timeAgo = timestamp != null ? timeago.format(timestamp) : '';
    //final senderEmail = msg['senderEmail'] ?? 'User';
    //final initial = senderEmail.isNotEmpty ? senderEmail[0].toUpperCase() : '?';

    final senderUsername = msg['senderUsername'] ?? 'User';
    final initial = senderUsername.isNotEmpty ? senderUsername[0].toUpperCase() : '?';

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
                //Text(senderEmail, style: const TextStyle(fontWeight: FontWeight.bold)),

                Text(senderUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    //IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 18, color: Colors.deepOrange)),

                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: Colors.deepOrange,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isLiked) {
                            _likedMessageIds.remove(messageId);
                          } else {
                            _likedMessageIds.add(messageId);
                          }
                        });
                      },
                    ),

                    //IconButton(onPressed: () {}, icon: const Icon(Icons.reply, size: 18, color: Colors.deepOrange)),

                    IconButton(
                      icon: const Icon(Icons.reply, size: 18, color: Colors.deepOrange),
                      onPressed: () {
                        setState(() {
                          _replyingTo = msg['text'] ?? '';
                          _controller.text = "@${msg['senderUsername'] ?? 'User'}: ";
                        });
                      },
                    ),


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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(widget.recipeTitle),
      ),
      body: Column(
        children: [
          if (_replyingTo != null)
            Container(
              color: Colors.deepOrange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("Replying to: $_replyingTo")),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyingTo = null;
                      });
                    },
                  )
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Container(width: double.infinity,
                color: Colors.deepOrange,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.file_upload, color: Colors.white),
                      onPressed: _pickFile,
                    ),
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.keyboard_voice, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Voice message coming soon 🎤")),
                        );
                      },
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 40,
                          maxHeight: 150,
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          cursorColor: Colors.blue,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.black),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.deepOrange),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color:Colors.deepOrange),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.deepOrange),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(text: _controller.text.trim()),
                    ),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
