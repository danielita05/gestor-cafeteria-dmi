import 'package:flutter/material.dart';

import 'core/http_client.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final ApiClient clientePrueba = ApiClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder<dynamic>(
            future: clientePrueba.get('/orders'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Text('${snapshot.data}');
            },
          ),
        ),
      ),
    );
  }
}
