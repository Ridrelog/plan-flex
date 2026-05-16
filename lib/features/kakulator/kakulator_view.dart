import 'package:flutter/material.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  String input = '';
  String hasil = '0';

  void tekanTombol(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        hasil = '0';
      } else if (value == '⌫') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == '=') {
        hitung();
      } else {
        input += value;
      }
    });
  }

  void hitung() {
    try {
      String ekspresi = input;
      double result = 0;

      if (ekspresi.contains('+')) {
        final angka = ekspresi.split('+');
        result = double.parse(angka[0]) + double.parse(angka[1]);
      } else if (ekspresi.contains('-')) {
        final angka = ekspresi.split('-');
        result = double.parse(angka[0]) - double.parse(angka[1]);
      } else if (ekspresi.contains('×')) {
        final angka = ekspresi.split('×');
        result = double.parse(angka[0]) * double.parse(angka[1]);
      } else if (ekspresi.contains('÷')) {
        final angka = ekspresi.split('÷');
        result = double.parse(angka[0]) / double.parse(angka[1]);
      }

      hasil = result.toStringAsFixed(0);
    } catch (e) {
      hasil = 'Error';
    }
  }

  Widget tombol(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFFE7D3B5),
            foregroundColor: const Color(0xFF2E211C),
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () => tekanTombol(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD6B18B);
    const darkColor = Color(0xFF2E211C);
    const operatorColor = Color(0xFFB98963);
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: const TextStyle(fontSize: 32, color: darkColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasil,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    tombol('C', color: operatorColor),
                    tombol('⌫', color: operatorColor),
                    tombol('÷', color: operatorColor),
                    tombol('×', color: operatorColor),
                  ],
                ),
                Row(
                  children: [
                    tombol('7'),
                    tombol('8'),
                    tombol('9'),
                    tombol('-', color: operatorColor),
                  ],
                ),
                Row(
                  children: [
                    tombol('4'),
                    tombol('5'),
                    tombol('6'),
                    tombol('+', color: operatorColor),
                  ],
                ),
                Row(
                  children: [
                    tombol('1'),
                    tombol('2'),
                    tombol('3'),
                    tombol('=', color: operatorColor),
                  ],
                ),
                Row(children: [tombol('0'), tombol('.')]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
