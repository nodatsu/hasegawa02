import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await signInFirebase();
  runApp(const MyApp());
}

Future<void> signInFirebase() async {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'test01@gmail.com',
    password: '8nnDp82xM',
  );
  if (FirebaseAuth.instance.currentUser != null) {
    print('########## ログイン失敗');
  }
}

Future<void> signOutFirebase() async {
  await FirebaseAuth.instance.signOut();
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
    final User user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('ぽーとふぉりお'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users/${user.uid}/portfolio')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(children: [
              Text('てきすと'),
              OutlinedButton(
                onPressed: () async {
                  await addPicture();
                },
                child: Text('画像追加'),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Column(
                            children: [
                              Ink.image(
                                image: NetworkImage(
                                  snapshot.data!.docs[index]
                                      .get('imageURL'),
                                ),
                                height: 240,
                                fit: BoxFit.contain,
                              ),
                              Padding(
                                padding: EdgeInsets.all(16).copyWith(bottom: 0),
                                child: Text(
                                  snapshot.data!.docs[index]
                                      .get('createdAt')
                                      .toDate()
                                      .toLocal()
                                      .toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }))
            ]);
          }),
    );
  }

  Future<void> addPicture() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      final User user = FirebaseAuth.instance.currentUser!;

      // Storageに登録
      final int timestamp = DateTime.now().microsecondsSinceEpoch;
      final File file = File(result.files.single.path!);
      final String name = file.path.split('/').last;
      final String path = '${timestamp}_$name';
      final TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/portfolio')
          .child(path)
          .putFile(file);

      // Firestoreに登録
      final String imageURL = await task.ref.getDownloadURL();
      final data = {
        'imageURL': imageURL,
        'createdAt': Timestamp.now(),
      };
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/portfolio')
          .doc()
          .set(data);
    }
  }
}
