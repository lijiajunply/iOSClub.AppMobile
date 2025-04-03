import 'package:flutter/material.dart';

class iMemberPage extends StatefulWidget {
  const iMemberPage({super.key});

  @override
  State<iMemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<iMemberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('iMember'),
        ),
        body: SingleChildScrollView(
          child: Column(children: []),
        ));
  }
}
