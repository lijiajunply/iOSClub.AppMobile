import 'package:flutter/material.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  State<WikiPage> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WikiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki'),
      ),
      body: const Center(
        child: Text('Wiki'),
      ),
    );
  }

}