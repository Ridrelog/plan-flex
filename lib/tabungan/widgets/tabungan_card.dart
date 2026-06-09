import 'dart:io';

import 'package:flutter/material.dart';

class TabunganCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final String Function(num value) formatRupiah;

  const TabunganCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    final target = (item['target'] as num).toDouble();
    final terkumpul = (item['terkumpul'] as num).toDouble();
    final hari = item['hari'] as int;

    final progress = target == 0 ? 0.0 : terkumpul / target;
    final persen = (progress * 100).clamp(0, 100);
    final sisa = target - terkumpul;
    final perHari = sisa <= 0 ? 0 : sisa / hari;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['gambar'] != null && item['gambar'].toString().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(
                    File(item['gambar']),
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F2E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.savings_rounded, color: Color(0xFF235347)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF051F20),
                          ),
                        ),
                        const Text(
                          'Progress celengan',
                          style: TextStyle(
                            color: Color(0xFF56746B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF8EB69B)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${formatRupiah(terkumpul)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF051F20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'dari target Rp ${formatRupiah(target)}',
                      style: const TextStyle(
                        color: Color(0xFF56746B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        minHeight: 12,
                        backgroundColor: const Color(0xFFD7E8DC),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF235347)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(icon: Icons.percent_rounded, text: '${persen.toStringAsFixed(0)}% terkumpul'),
                  _InfoPill(
                    icon: sisa <= 0 ? Icons.check_circle_rounded : Icons.flag_rounded,
                    text: sisa <= 0 ? 'Target tercapai' : 'Sisa Rp ${formatRupiah(sisa)}',
                  ),
                  _InfoPill(
                    icon: Icons.today_rounded,
                    text: 'Rp ${formatRupiah(perHari)} / hari',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2E9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF235347)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF051F20),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
