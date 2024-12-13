import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> loginAndSaveUserData() async {
    if (_formKey.currentState!.validate()) {
      String msg = "Invalid credentials";
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final user = userCredential.user;

        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('panisara_users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            final panisaraUser = PanisaraUsers(
              email: user.email ?? '',
              uid: user.uid,
            );
            await panisaraUser.save();
          }

          msg = "Login Successful";
          Navigator.pushNamed(context, '/movies');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          msg = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          msg = 'Wrong password provided.';
        }
      } catch (e) {
        msg = 'An error occurred: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Please enter your email',
                  labelText: 'Email',
                ),
                validator: validateEmail,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: 'Please enter your password',
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: validatePassword,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: loginAndSaveUserData,
                child: const Text(
                  'Log in',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanisaraUsers {
  String email;
  String uid;
  String name;

  PanisaraUsers({
    required this.email,
    required this.uid,
    this.name = '',
  });


  factory PanisaraUsers.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PanisaraUsers(
      email: data['email'] ?? '',
      uid: snapshot.id,
 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
   
    };
  }

  // บันทึกข้อมูลลง Firestore
  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('panisara_users')
        .doc(uid)
        .set(toMap());
  }
}
