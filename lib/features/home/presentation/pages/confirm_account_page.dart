import 'package:flutter/material.dart';

class ConfirmAccountPage extends StatelessWidget {
  const ConfirmAccountPage({super.key});



  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Enter tel number'),
          TextField(decoration: InputDecoration(hint: Text('12345567890')),)
        ],
      ),
    );
  }
}
