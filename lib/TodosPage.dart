import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My TODOs'),
          actions: [
            IconButton(
                onPressed: signOut,
                icon: const Icon(Icons.logout)
            )
          ],
        ),
        body: Column(
          children: [
            Text("Hello ${user.email!}")
          ],
        )
    );
  }
}
