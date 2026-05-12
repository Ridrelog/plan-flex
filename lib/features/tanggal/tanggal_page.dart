import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/services/note_database_service.dart';

class HolidayInfo {
  final String name;
  final bool isNationalHoliday;
  final bool isJointLeave;

  HolidayInfo({
    required this.name,
    required this.isNationalHoliday,
    required this.isJointLeave,
  });
}

class TanggalPage extends StatefulWidget {
  const TanggalPage({super.key});

  @override
  State<TanggalPage> createState() => _TanggalPageState();
}

class _TanggalPageState extends State<TanggalPage> {
  DateTime now = DateTime.now();
  late Timer timer;

  Map<String, HolidayInfo> holidays = {};
  Map<String, String> notes = {};

  String selectedInfo = "Klik tanggal untuk melihat keterangan";

  @override
  void initState() {
    super.initState();
    fetchHolidays();
    loadNotes();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = DateTime.now();

      if (now.year == current.year && now.month == current.month) {
        setState(() {
          now = current;
        });
      }
    });
  }

  Future<void> loadNotes() async {
    final savedNotes = await NoteDatabaseService.instance.getAllNotes();

    setState(() {
      notes = savedNotes;
    });
  }

  Future<void> fetchHolidays() async {
    final url = Uri.parse(
      "https://hari-libur-api.vercel.app/api?year=${now.year}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final Map<String, HolidayInfo> result = {};

        for (final item in data) {
          final String date = item["date"].toString();
          final String event = item["event"].toString();

          final bool isNational = item["is_national_holiday"] == true;
          final bool isJointLeave =
              event.toLowerCase().contains("cuti bersama");

          result[date] = HolidayInfo(
            name: event,
            isNationalHoliday: isNational,
            isJointLeave: isJointLeave,
          );
        }

        setState(() {
          holidays = result;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data libur: $e");
    }
  }

  void nextMonth() {
    setState(() {
      now = DateTime(now.year, now.month + 1, 1);
      selectedInfo = "Klik tanggal untuk melihat keterangan";
    });

    fetchHolidays();
  }

  void previousMonth() {
    setState(() {
      now = DateTime(now.year, now.month - 1, 1);
      selectedInfo = "Klik tanggal untuk melihat keterangan";
    });

    fetchHolidays();
  }

  String getDateKey(int day) {
    final month = now.month.toString().padLeft(2, '0');
    final date = day.toString().padLeft(2, '0');

    return "${now.year}-$month-$date";
  }

  void openNoteDialog(String dateKey) {
    final controller = TextEditingController(
      text: notes[dateKey] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3E3D3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                notes.containsKey(dateKey) ? Icons.edit_note : Icons.note_add,
                color: const Color(0xFF8B5A2B),
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                notes.containsKey(dateKey) ? "Edit Catatan" : "Tambah Catatan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 290,
            child: TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tulis catatan...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.brown.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF8B5A2B),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (notes.containsKey(dateKey))
                    TextButton.icon(
                      onPressed: () async {
                        await NoteDatabaseService.instance.deleteNote(dateKey);

                        setState(() {
                          notes.remove(dateKey);
                          selectedInfo = "Catatan berhasil dihapus";
                        });

                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF8B5A2B),
                      size: 18,
                    ),
                    label: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Color(0xFF8B5A2B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8EBDD),
                      foregroundColor: const Color(0xFF8B5A2B),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      final text = controller.text.trim();

                      if (text.isNotEmpty) {
                        await NoteDatabaseService.instance.saveNote(
                          dateKey,
                          text,
                        );

                        setState(() {
                          notes[dateKey] = text;
                          selectedInfo = text;
                        });
                      } else {
                        await NoteDatabaseService.instance.deleteNote(dateKey);

                        setState(() {
                          notes.remove(dateKey);
                          selectedInfo = "Catatan kosong";
                        });
                      }

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void selectDate({
    required String key,
    required bool isToday,
    required bool isSunday,
    HolidayInfo? holiday,
  }) {
    setState(() {
      if (notes.containsKey(key)) {
        selectedInfo = notes[key]!;
      } else if (holiday != null) {
        selectedInfo = holiday.name;
      } else if (isToday && isSunday) {
        selectedInfo = "Hari ini: Hari Minggu";
      } else if (isToday) {
        selectedInfo = "Hari ini";
      } else if (isSunday) {
        selectedInfo = "Hari Minggu";
      } else {
        selectedInfo = "Tidak ada catatan pada tanggal ini";
      }
    });

    openNoteDialog(key);
  }

  List<MapEntry<String, String>> get monthlyNotes {
    final month = now.month.toString().padLeft(2, '0');
    final prefix = "${now.year}-$month";

    final result = notes.entries.where((item) {
      return item.key.startsWith(prefix);
    }).toList();

    result.sort((a, b) => a.key.compareTo(b.key));
    return result;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;
    final totalItems = daysInMonth + (startingWeekday - 1);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFDDB892),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 370,
                  height: 510,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: previousMonth,
                            icon: const Icon(Icons.chevron_left, size: 34),
                          ),
                          Column(
                            children: [
                              Text(
                                monthName(now.month),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${now.year}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: nextMonth,
                            icon: const Icon(Icons.chevron_right, size: 34),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${today.day}-${today.month}-${today.year}   "
                        "${today.hour.toString().padLeft(2, '0')}:"
                        "${today.minute.toString().padLeft(2, '0')}:"
                        "${today.second.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 22),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Sen"),
                          Text("Sel"),
                          Text("Rab"),
                          Text("Kam"),
                          Text("Jum"),
                          Text("Sab"),
                          Text(
                            "Min",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: totalItems,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            if (index < startingWeekday - 1) {
                              return const SizedBox();
                            }

                            final day = index - (startingWeekday - 2);
                            final key = getDateKey(day);

                            final isToday = day == today.day &&
                                now.month == today.month &&
                                now.year == today.year;

                            final isSunday =
                                DateTime(now.year, now.month, day).weekday ==
                                    DateTime.sunday;

                            final holiday = holidays[key];
                            final hasHoliday = holiday != null;
                            final hasNote = notes.containsKey(key);

                            Color bgColor = Colors.white;
                            Color textColor = Colors.black;

                            if (isSunday) {
                              bgColor = Colors.red;
                              textColor = Colors.white;
                            }

                            if (hasHoliday) {
                              if (holiday.isJointLeave &&
                                  !holiday.isNationalHoliday) {
                                bgColor = Colors.orange;
                              } else {
                                bgColor = Colors.red;
                              }

                              textColor = Colors.white;
                            }

                            if (isToday && !isSunday && !hasHoliday) {
                              bgColor = Colors.green;
                              textColor = Colors.white;
                            }

                            final tooltipMessage = [
                              if (holiday != null) holiday.name,
                              if (isSunday && holiday == null) "Hari Minggu",
                              if (hasNote) "Catatan: ${notes[key]}",
                            ].join("\n");

                            Widget dateBox = AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(
                                  isToday ? 18 : 14,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isToday ? 0.22 : 0.08,
                                    ),
                                    blurRadius: isToday ? 12 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "$day",
                                  style: TextStyle(
                                    fontSize: isToday ? 19 : 17,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            );

                            if (tooltipMessage.isNotEmpty) {
                              dateBox = Tooltip(
                                message: tooltipMessage,
                                child: dateBox,
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                selectDate(
                                  key: key,
                                  isToday: isToday,
                                  isSunday: isSunday,
                                  holiday: holiday,
                                );
                              },
                              child: Stack(
                                children: [
                                  dateBox,
                                  if (hasNote)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 370,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 20,
                            color: Color(0xFF8B5A2B),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Agenda Bulan Ini",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (monthlyNotes.isEmpty)
                        const Text(
                          "Belum ada agenda/catatan bulan ini",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Column(
                          children: monthlyNotes.map((item) {
                            final day = item.key.substring(8, 10);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8EBDD),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFF8B5A2B),
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String monthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return months[month - 1];
  }
}