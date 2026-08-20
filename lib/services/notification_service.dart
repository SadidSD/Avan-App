import 'package:flutter/material.dart';
import 'storage_service.dart';

class ReminderSettings {
  final bool isMorningEnabled;
  final bool isEveningEnabled;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;
  final String frequency; // '2x Daily', 'Morning Only', 'Evening Only', '4x Daily'

  const ReminderSettings({
    this.isMorningEnabled = true,
    this.isEveningEnabled = true,
    this.morningTime = const TimeOfDay(hour: 8, minute: 0),
    this.eveningTime = const TimeOfDay(hour: 21, minute: 30),
    this.frequency = '2x Daily',
  });

  ReminderSettings copyWith({
    bool? isMorningEnabled,
    bool? isEveningEnabled,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    String? frequency,
  }) {
    return ReminderSettings(
      isMorningEnabled: isMorningEnabled ?? this.isMorningEnabled,
      isEveningEnabled: isEveningEnabled ?? this.isEveningEnabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      frequency: frequency ?? this.frequency,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StorageService _storage = StorageService();
  ReminderSettings _settings = const ReminderSettings();

  ReminderSettings get settings => _settings;

  Future<void> init() async {
    await _storage.init();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final morningEnabled = _storage.getBool('reminder_morning_enabled', defaultValue: true);
    final eveningEnabled = _storage.getBool('reminder_evening_enabled', defaultValue: true);
    final morningHour = _storage.getInt('reminder_morning_hour', defaultValue: 8);
    final morningMinute = _storage.getInt('reminder_morning_min', defaultValue: 0);
    final eveningHour = _storage.getInt('reminder_evening_hour', defaultValue: 21);
    final eveningMinute = _storage.getInt('reminder_evening_min', defaultValue: 30);
    final freq = _storage.getString('reminder_frequency', defaultValue: '2x Daily');

    _settings = ReminderSettings(
      isMorningEnabled: morningEnabled,
      isEveningEnabled: eveningEnabled,
      morningTime: TimeOfDay(hour: morningHour, minute: morningMinute),
      eveningTime: TimeOfDay(hour: eveningHour, minute: eveningMinute),
      frequency: freq,
    );
  }

  Future<void> updateSettings(ReminderSettings newSettings) async {
    _settings = newSettings;
    await _storage.setBool('reminder_morning_enabled', newSettings.isMorningEnabled);
    await _storage.setBool('reminder_evening_enabled', newSettings.isEveningEnabled);
    await _storage.setInt('reminder_morning_hour', newSettings.morningTime.hour);
    await _storage.setInt('reminder_morning_min', newSettings.morningTime.minute);
    await _storage.setInt('reminder_evening_hour', newSettings.eveningTime.hour);
    await _storage.setInt('reminder_evening_min', newSettings.eveningTime.minute);
    await _storage.setString('reminder_frequency', newSettings.frequency);

    debugPrint("Scheduled Reminders: Morning ${newSettings.morningTime.formatTimeOfDay()} (${newSettings.isMorningEnabled}), Evening ${newSettings.eveningTime.formatTimeOfDay()} (${newSettings.isEveningEnabled})");
  }
}

extension TimeOfDayFormat on TimeOfDay {
  String formatTimeOfDay() {
    final h = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final m = minute.toString().padLeft(2, '0');
    final periodStr = period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $periodStr';
  }
}
