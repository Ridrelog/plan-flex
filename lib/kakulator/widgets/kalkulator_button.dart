import 'package:flutter/material.dart';

class KalkulatorButton extends StatelessWidget {
  final String text;
  final Color? color;
  final ValueChanged<String> onPressed;

  const KalkulatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isOperator = color != null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isOperator ? color : Colors.white,
            foregroundColor: isOperator ? Colors.white : const Color(0xFF051F20),
            elevation: isOperator ? 2 : 0,
            shadowColor: const Color(0xFF235347).withOpacity(0.18),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: isOperator ? Colors.transparent : const Color(0xFFD7E8DC),
              ),
            ),
          ),
          onPressed: () => onPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
