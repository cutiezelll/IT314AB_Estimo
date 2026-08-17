import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 30, 0, 39)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ' My First Flutter Application'),
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
      // Change the background color here
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), 
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/kourerin.png',
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Zelon Matthew C. Estimo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 166, 0),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'BSIT - 3',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 209, 136, 0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Divider(),
            ),
            const Text(
              '"✨ My First Flutter Application ✨"',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(221, 255, 145, 0),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Date: 2026-08-11',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 153, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}