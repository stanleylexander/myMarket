import 'package:flutter/material.dart';

class HomePenjual extends StatelessWidget {
  const HomePenjual({super.key});

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePenjual'),
      ),
      body: const Center(
        child: Text("This is HomePenjual "),
      ),
    );
  }
}
