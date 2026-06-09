import 'package:flutter/material.dart';

import '../model/kalkulator_model.dart';
import '../repository/kalkulator_repository.dart';
import '../widgets/kalkulator_button.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final KalkulatorRepository repository = KalkulatorRepository();

  KalkulatorModel state = const KalkulatorModel(input: '', hasil: '0');

  void tekanTombol(String value) {
    setState(() {
      if (value == 'C') {
        state = const KalkulatorModel(input: '', hasil: '0');
      } else if (value == '⌫') {
        if (state.input.isNotEmpty) {
          state = state.copyWith(
            input: state.input.substring(0, state.input.length - 1),
          );
        }
      } else if (value == '=') {
        state = state.copyWith(hasil: repository.hitung(state.input));
      } else {
        state = state.copyWith(input: state.input + value);
      }
    });
  }

  Widget tombol(String text, {Color? color}) {
    return KalkulatorButton(
      text: text,
      color: color,
      onPressed: tekanTombol,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF4FBF6);
    const darkColor = Color(0xFF051F20);
    const operatorColor = Color(0xFF235347);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4FBF6), Color(0xFFEAF6EE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD7E8DC)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF235347).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            state.input.isEmpty ? '0' : state.input,
                            style: const TextStyle(
                              fontSize: 30,
                              color: Color(0xFF56746B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            state.hasil,
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: darkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F2E9),
                  borderRadius: BorderRadius.circular(30),
                ),
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
        ),
      ),
    );
  }
}
