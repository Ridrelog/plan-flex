class HolidayInfo {
  final String name;
  final bool isNationalHoliday;
  final bool isJointLeave;

  HolidayInfo({
    required this.name,
    required this.isNationalHoliday,
    required this.isJointLeave,
  });

  factory HolidayInfo.fromJson(Map<String, dynamic> json) {
    final event = json['event'].toString();

    return HolidayInfo(
      name: event,
      isNationalHoliday: json['is_national_holiday'] == true,
      isJointLeave: event.toLowerCase().contains('cuti bersama'),
    );
  }
}
