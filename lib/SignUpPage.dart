import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final loginTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  void dispose() {
    loginTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: loginTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'login',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'e-mail',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordTextController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'password',
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  var db = FirebaseFirestore.instance;
                  final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailTextController.text.trim());
                  QuerySnapshot snap = await db.collection("users").where("login", isEqualTo: loginTextController.text.trim()).get();
                  if(list.isNotEmpty) {
                    throw FirebaseAuthException(code: 'email-already-in-use');
                  }
                  if(snap.docs.isNotEmpty) {
                    throw FirebaseAuthException(code: 'login-already-in-use');
                  } else if (passwordTextController.text.isNotEmpty) {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailTextController.text.trim(),
                        password: passwordTextController.text.trim(),
                      );
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final user = <String, dynamic>{
                        "uid": uid,
                        "login": loginTextController.text.trim(),
                        "email": emailTextController.text.trim(),
                        "no_todos": 3
                      };
                      db.collection("users").add(user);
                      loginTextController.clear();
                      emailTextController.clear();
                      passwordTextController.clear();
                      if (!mounted) return;
                      Navigator.pop(context);
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar("E-mail already in use!"));
                  }
                  if (e.code == 'login-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar("Login already in use!"));
                  }
                }
              },
              child: const Text('Sign up')
          )
        ],
      ),
    );
  }
}
