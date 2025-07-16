import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String recipeId;

  const ChatScreen({super.key, required this.recipeId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String? questionId;

  @override
  void initState() {
    super.initState();
    //recipeId = widget.recipeId;
    _initChat();
  }

  Future<void> _initChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final qaRef = FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('qa');

    final existing = await qaRef
        .where('askedBy', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      questionId = existing.docs.first.id;
    } else {
      questionId = const Uuid().v4();
      await qaRef.doc(questionId).set({
        'askedBy': user.uid,
        'createdAt': Timestamp.now(),
      });
    }

    // Listen to messages
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

  Future<void> _sendMessage({
    String text = '',
    String imageUrl = '',
    String fileUrl = '',
  }) async {
    String messageText = _controller.text.trim();
    if (messageText.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String senderId = user.uid;
    String senderEmail = user.email ?? "";
    if (text.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)// make sure this exists!
        .collection('qa')
        .doc(questionId) // also make sure this exists!
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderType': 'user',
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'type': imageUrl.isNotEmpty
          ? 'image'
          : fileUrl.isNotEmpty
          ? 'file'
          : 'text',
      'timestamp': FieldValue.serverTimestamp(),
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

    final ref = FirebaseStorage.instance
        .ref('qa_uploads/files/$name');
    await ref.putFile(File(path));
    final url = await ref.getDownloadURL();

    await _sendMessage(fileUrl: url);
  }


  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['senderType'] == 'user';
    final isDev = msg['senderType'] == 'developer';

    Widget content;
    if (msg['imageUrl'] != null && msg['imageUrl'] != '') {
      content = Image.network(msg['imageUrl'], width: 150, height: 150, fit: BoxFit.cover);
    } else if (msg['fileUrl'] != null && msg['fileUrl'] != '') {
      content = GestureDetector(
        onTap: () => OpenFile.open(msg['fileUrl']),
        child: Text(
          "📎 File",
          style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white),
        ),
      );
    } else {
      content = Text(msg['text'], style: const TextStyle(color: Colors.white));
    }

    return Align(
      alignment: isDev ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDev ? Colors.white: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Q & A", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            /*child: SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/img_1.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),*/
          ),


          // Main content column
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  //itemBuilder: (ctx, index) => _buildMessage(_messages[index]),
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    Widget content;

                    final String? text = message['text'];
                    final String? imageUrl = message['imageUrl'];
                    final String? fileUrl = message['fileUrl'];

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      content = Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      );
                    } else if (fileUrl != null && fileUrl.isNotEmpty) {
                      content = GestureDetector(
                        onTap: () => OpenFile.open(fileUrl),
                        child: Text(
                          "📎 File",
                          style: TextStyle(
                            color: message['senderType'] == 'developer' ? Colors.black : Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    } else if (text != null && text.isNotEmpty) {
                      content = Text(
                        text,
                        style: TextStyle(
                          color: message['senderType'] == 'developer' ? Colors.black : Colors.white,),
                      );
                    } else {
                      content = Text(
                          "Unknown message",
                          style: TextStyle(
                            color: message['senderType'] == 'developer' ? Colors.black : Colors.white,));
                    }

                    return Align(
                      alignment: message['senderType'] == 'user'? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message['senderType'] == 'user' ? Colors.deepOrange: Color(0xFFF1C40F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: content,
                      ),
                    );
                  },
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
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(text: _controller.text.trim()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


