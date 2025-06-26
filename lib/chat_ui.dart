import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat UI',
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
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
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _messages.add({"type": "image", "data": image.path});
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _messages.add({"type": "file", "data": file.path});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat UI", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img.png',
              fit: BoxFit.contain, // Changed from cover to contain
              alignment: Alignment.center,
            ),
          ),

          // Blur overlay with dark tint
          /*Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),*/

          // Main content column
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    Widget content;

                    if (message['type'] == 'text') {
                      content = Text(
                        message['data'],
                        style: TextStyle(color: Colors.white),
                      );
                    } else if (message['type'] == 'image') {
                      content = ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          File(message['data']),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      );
                    }else if (message['type'] == 'file') {
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
                    }

                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: content,
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.file_upload, color: Colors.blue),
                      onPressed: _pickFile,
                    ),
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.keyboard_voice, color: Colors.blue),
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
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
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
