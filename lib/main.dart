import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/TodosPage.dart';
import 'package:todo_app/firebase_options.dart';
import 'SignUpPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  Future signIn(BuildContext context) async {
    try {
      var db = FirebaseFirestore.instance;
      var snap = await db.collection("users").where("login", isEqualTo: emailTextController.text.trim()).get();
      if(snap.docs.isNotEmpty) {
        DocumentSnapshot doc=snap.docs.first;
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: doc['email'],
            password: passwordTextController.text.trim()
        );
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text.trim(),
          password: passwordTextController.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(snackBar("Wrong password!"));
      }
    }
  }

  SnackBar snackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
            color: Colors.red
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return const TodosPage();
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Sign in"),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                      child: Center(
                        child: TextField(
                          controller: emailTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'e-mail',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                      child: Center(
                        child: TextField(
                          controller: passwordTextController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'password',
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        signIn(context);
                      },
                      child: const Text("Sign in"),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text('Sign up')
                    )
                  ],
                )
            );
          }
        }
    );
  }
}


