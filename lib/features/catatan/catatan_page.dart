import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  final TextEditingController controller = TextEditingController();

  static const String keyCatatan = 'catatan_tersimpan';

  @override
  void initState() {
    super.initState();
    ambilCatatan();
  }

  Future<void> ambilCatatan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyCatatan);

    controller.text = data ?? '';
  }

  Future<void> simpanCatatan(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCatatan, value);
  }

  Future<void> hapusCatatan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCatatan);

    controller.clear();
  }

  @override
  void dispose() {
    simpanCatatan(controller.text);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD6B18B);
    const textColor = Color(0xFF5A4032);
    const borderColor = Color(0xFF8A5A22);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: simpanCatatan,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 18,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis catatan...',
                hintStyle: const TextStyle(color: textColor),
                filled: true,
                fillColor: bgColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: borderColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}