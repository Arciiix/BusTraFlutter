import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key, this.error}) : super(key: key);

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.red[400], size: 52),
        Text("Błąd", style: TextStyle(color: Colors.red[400], fontSize: 52)),
        Text(error ?? "Nieznany błąd",
            style: TextStyle(color: Colors.black, fontSize: 24))
      ],
    )));
  }
}
