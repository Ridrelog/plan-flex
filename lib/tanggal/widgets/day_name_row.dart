import 'package:flutter/material.dart';

class DayNameRow extends StatelessWidget {
  const DayNameRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Sen'),
        Text('Sel'),
        Text('Rab'),
        Text('Kam'),
        Text('Jum'),
        Text('Sab'),
        Text(
          'Min',
          style: TextStyle(
            color: const Color(0xFF235347),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
