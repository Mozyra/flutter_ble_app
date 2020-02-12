import 'package:flutter/material.dart';

import 'package:fullled/presentation/scanner_screen.dart';

class Application extends StatefulWidget {

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScannerScreen(),
    );
  }
}