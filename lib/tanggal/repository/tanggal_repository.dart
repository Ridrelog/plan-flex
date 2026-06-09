import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/services/note_database_service.dart';
import '../model/holiday_info.dart';

class TanggalRepository {
  Future<Map<String, String>> getAllNotes() async {
    return NoteDatabaseService.instance.getAllNotes();
  }

  Future<void> saveNote({
    required String key,
    required String note,
  }) async {
    await NoteDatabaseService.instance.saveNote(key, note);
  }

  Future<void> deleteNote(String key) async {
    await NoteDatabaseService.instance.deleteNote(key);
  }

  Future<Map<String, HolidayInfo>> fetchHolidays(int year) async {
    final url = Uri.parse(
      'https://hari-libur-api.vercel.app/api?year=$year',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) return {};

      final List data = jsonDecode(response.body);
      final Map<String, HolidayInfo> result = {};

      for (final item in data) {
        final json = Map<String, dynamic>.from(item as Map);
        final date = json['date'].toString();
        result[date] = HolidayInfo.fromJson(json);
      }

      return result;
    } catch (e) {
      debugPrint('Gagal mengambil data libur: $e');
      return {};
    }
  }
}
