import 'package:flutter/material.dart';

class SmallInfo extends StatelessWidget {
  final String value;
  final IconData icon;

  const SmallInfo({Key? key, required this.value, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 30),
        Text(value, style: TextStyle(fontSize: 24))
      ],
    );
  }
}
