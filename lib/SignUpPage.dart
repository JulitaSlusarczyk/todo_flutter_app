import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  SnackBar snackBar(String message, Color color) {
    return SnackBar(
      content: Text(
          message,
          style: TextStyle(
            color: color
          ),
      ),
    );
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
          TextField(
            controller: loginTextController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'login',
            ),
          ),
          TextField(
            controller: emailTextController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'e-mail',
            ),
          ),
          TextField(
            controller: passwordTextController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'password',
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailTextController.text.trim());
                  if(list.isNotEmpty) {
                    throw FirebaseAuthException(code: 'email-already-in-use');
                  } else if (passwordTextController.text.isNotEmpty) {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailTextController.text.trim(),
                      password: passwordTextController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar("E-mail already in use!", Colors.red));
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
