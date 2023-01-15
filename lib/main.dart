import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'はせがわアプリ',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ぽーとふぉりお'),
      ),
      body: Column(
        children: [
          Text('てきすと'),
          OutlinedButton(
            onPressed: () async {
              await signInFirebase();
              // await addPicture();
              await signOutFirebase();
            },
            child: Text('画像追加'),
          ),
        ],
      ),
    );
  }

  Future<void> signInFirebase() async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'test01@gmail.com',
      password: '8nnDp82xM',
    );
    if (FirebaseAuth.instance.currentUser != null) {
    }
  }

  Future<void> signOutFirebase() async {
    await FirebaseAuth.instance.signOut();
  }
}
