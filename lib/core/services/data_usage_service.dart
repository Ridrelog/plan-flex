import 'package:flutter/services.dart';

class DataUsageService {
  static const MethodChannel _channel = MethodChannel('data_usage_channel');

  static Future<Map<String, dynamic>> getTodayUsage() async {
    final result = await _channel.invokeMethod('getTodayUsage');
    return Map<String, dynamic>.from(result);
  }

  static Future<Map<String, dynamic>> getMonthUsage() async {
    final result = await _channel.invokeMethod('getMonthUsage');
    return Map<String, dynamic>.from(result);
  }

  static Future<void> openUsageSettings() async {
    await _channel.invokeMethod('openUsageSettings');
  }

  static Future<bool> hasUsagePermission() async {
    final result = await _channel.invokeMethod('hasUsagePermission');
    return result == true;
  }
}