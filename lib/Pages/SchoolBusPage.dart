import 'package:flutter/material.dart';

class SchoolBusPage extends StatefulWidget {
  const SchoolBusPage({super.key});

  @override
  State<SchoolBusPage> createState() => _SchoolBusPageState();
}

class _SchoolBusPageState extends State<SchoolBusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('校车'),
      ),
      body: const Center(
        child: Text('Score Page'),
      ),
    );
  }
}
