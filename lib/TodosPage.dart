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
    final titleTextController = TextEditingController();
    final descTextController = TextEditingController();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where("email", isEqualTo: user.email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
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
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Add Todo'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleTextController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                      TextField(
                        controller: descTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                        ),
                      )
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: (){
                        final todo = <String, dynamic>{
                          "uid": data?['uid'],
                          "title": titleTextController.text.trim(),
                          "desc": descTextController.text.trim(),
                          "isDone": false
                        };
                        db.collection("todos").add(todo);
                        int todosLeft = data?['no_todos']-1;
                        db.collection("users").doc(data?.id).update({"no_todos": todosLeft});
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              )
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('todos').where("uid", isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Column(
                    children: [
                      Center(child: Text("Hello ${data?['login']} ${data?['no_todos']}")),
                      Expanded(
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                            return CheckboxListTile(
                              title: Text(data['title']),
                              subtitle: Text(data['desc']),
                              value: data['isDone'],
                              onChanged: (a) => db.collection("todos").doc(document.id).update({"isDone": a}),
                              secondary: const IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: null,
                              ),
                            );
                          })
                              .toList()
                              .cast(),
                        ),
                      )
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }
              }
            )
        );
      }
    );
  }
}
