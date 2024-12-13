import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';

  // ตรวจสอบความถูกต้องของฟิลด์อีเมล
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ตรวจสอบความถูกต้องของฟิลด์รหัสผ่าน
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // บันทึกผู้ใช้ใน Firestore
  Future<void> registerAndSaveUserData() async {
    if (_formKey.currentState!.validate()) {
      String msg = "Registration failed";
      try {
        // ลงทะเบียนผู้ใช้ใหม่ใน Firebase Authentication
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final user = userCredential.user;

        if (user != null) {
          // เพิ่มข้อมูลผู้ใช้ลง Firestore
          final userData = {
            'email': _email,
            'name': _name,
            'createdAt': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('panisara_users')
              .doc(user.uid)
              .set(userData);

          msg = "Registration Successful";
          Navigator.pushNamed(context, '/movies');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          msg = 'The email is already in use.';
        } else if (e.code == 'weak-password') {
          msg = 'The password provided is too weak.';
        }
      } catch (e) {
        msg = 'Error: ${e.toString()}';
      }

      // แสดงข้อความผลลัพธ์
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  icon: const Icon(Icons.email),
                  hintText: 'Please enter your email.',
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  icon: const Icon(Icons.lock),
                  hintText: 'Please enter your password.',
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
                onPressed: registerAndSaveUserData,
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
