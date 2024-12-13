import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:panisara_final_app/api/post.dart';
import 'package:panisara_final_app/firebase_options.dart';
import 'package:panisara_final_app/login.dart';

import 'package:panisara_final_app/movies.dart';
import 'package:panisara_final_app/register.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'panisara_final_app',
      theme: ThemeData(
        primaryColor: Colors.grey[850],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey[850]!,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const MyHomePage(title: ''),
        '/movies': (context) => MoviesPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(
              title: '',
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        backgroundColor: Colors.grey[650], 
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/movies'); 
          },
          child: const Text('Go to Movie'),
        ),
      ),
    );
  }
}
