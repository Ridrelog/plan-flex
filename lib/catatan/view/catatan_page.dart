import 'package:flutter/material.dart';

import '../repository/catatan_repository.dart';
import '../widgets/catatan_editor.dart';

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  final TextEditingController controller = TextEditingController();
  final CatatanRepository repository = CatatanRepository();

  @override
  void initState() {
    super.initState();
    ambilCatatan();
  }

  Future<void> ambilCatatan() async {
    controller.text = await repository.ambilCatatan();
  }

  Future<void> simpanCatatan(String value) async {
    await repository.simpanCatatan(value);
  }

  Future<void> hapusCatatan() async {
    await repository.hapusCatatan();
    controller.clear();
  }

  @override
  void dispose() {
    repository.simpanCatatan(controller.text);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4FBF6), Color(0xFFEAF6EE)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFD7E8DC)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFE5F2E9),
                  child: Icon(Icons.auto_stories_rounded, color: Color(0xFF235347)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan Harian',
                        style: TextStyle(
                          color: Color(0xFF051F20),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tulis ide, tugas, atau rencana kamu di sini.',
                        style: TextStyle(
                          color: Color(0xFF56746B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: CatatanEditor(
              controller: controller,
              onChanged: simpanCatatan,
            ),
          ),
        ],
      ),
    );
  }
}
