import 'package:flutter/material.dart';

class AnimatedHeader extends StatelessWidget {
  const AnimatedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.blue,
      alignment: Alignment.center,
      child: const Text(
        'GigTrust Dashboard',
        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}