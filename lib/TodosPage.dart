import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where("email", isEqualTo: user.email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        var data = snapshot.data?.docs.first;
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
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: (){},
            ),
            body: Column(
              children: [
                Center(child: Text("Hello ${data?['login']} ${data?['no_todos']}"))
              ],
            )
        );
      }
    );
  }
}
