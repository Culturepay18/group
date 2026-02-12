import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ImagePage(),
    );
  }
}

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image locale'),
      ),
      body: Center(
        child: Image.asset(
          'assets/images/op.jpeg',
          width: 320,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Text("Impossible de charger l'image.");
          },
        ),
      ),
    );
  }
}
