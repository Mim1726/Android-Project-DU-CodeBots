import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat UI',
      home: ChatScreen(recipeId: 'butter-chicken'),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

  final devEmails = [
    'ishratjahan7711@gmail.com',
    'sumitasmia515@gmail.com',
    'mimrobo1726@gmail.com',
    'anikasanzida31593@gmail.com',
  ];

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

  /*void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"type": "text", "data": text});
      });
      _controller.clear();
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }*/


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

    /*// Update local UI
    setState(() {
      if (text.isNotEmpty) {
        _messages.add({"type": "text", "data": text});
      } else if (imageUrl.isNotEmpty) {
        _messages.add({"type": "image", "data": imageUrl});
      } else if (fileUrl.isNotEmpty) {
        _messages.add({"type": "file", "data": fileUrl});
      }
    });

    setState(() {
      _messages.add({"type": "text", "data": messageText});
    });*/

    _controller.clear();
  }


  /*Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _messages.add({"type": "image", "data": image.path});
      });
    }
  }*/

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

  /*Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _messages.add({"type": "file", "data": file.path});
      });
    }
  }*/

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
        title: Text("Chat UI", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFFB7351F),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
            // Background image
            //Positioned.fill(
              child: Image.asset(
                'assets/img_1.png',
                fit: BoxFit.contain, // Changed from cover to contain
                alignment: Alignment.center,
              ),
            ),
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
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      } else if (text != null && text.isNotEmpty) {
                        content = Text(
                          text,
                         style: TextStyle(color: Colors.white),
                        );
                      } else {
                        content = Text("Unknown message", style: TextStyle(color: Colors.white));
                      }

                    /*if (message['type'] == 'text') {
                      content = Text(
                        message['data'],
                        style: TextStyle(color: Colors.white),
                      );
                    } else if (message['type'] == 'image') {
                      content = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message['data']),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else if (message['type'] == 'file') {
                      content = GestureDetector(
                        onTap: () async {
                          final result = await OpenFile.open(message['data']);
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Couldn't open file.")),
                            );
                          }
                        },
                        child: Text(
                          "📎 File: ${message['data'].split('/').last}",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    } else {
                      content = Text("Unknown message",
                          style: TextStyle(color: Colors.white));
                    }*/

                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFB7351F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: content,
                        ),
                      );
                    },
                  ),
              ),

              /*Container(
                height: 8,
                color: Colors.green[100], // 👈 Change this color as well
              ),*/

              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Container(width: double.infinity,
                  color: Color(0xFFB7351F),
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
                                borderSide: BorderSide(color: Color(0xFFB7351F)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Color(0xFFB7351F)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Color(0xFFB7351F)),
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

