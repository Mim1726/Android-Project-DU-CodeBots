import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('First Flutter Application'),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
