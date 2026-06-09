import 'package:flutter/material.dart';

class CatatanEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CatatanEditor({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD7E8DC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF235347).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 17,
          height: 1.5,
          color: Color(0xFF051F20),
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'Mulai tulis catatan...',
          hintStyle: TextStyle(color: Color(0xFF8CA79C)),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
        ),
      ),
    );
  }
}
