import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';
import '../models/attendance.dart';
import 'notification_service.dart';

class CalendarService extends ChangeNotifier {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  static const String _eventsKey = 'calendar_events';
  static const String _attendanceKey = 'attendance_records';
  SharedPreferences? _prefs;
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Event Methods
  Future<List<CalendarEvent>> getAllEvents() async {
    if (_prefs == null) await initialize();
    final String? data = _prefs?.getString(_eventsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => CalendarEvent.fromJson(json)).toList();
  }

  Future<List<CalendarEvent>> getEventsForDay(DateTime date) async {
    final events = await getAllEvents();
    return events.where((event) {
      final start = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final end = DateTime(event.endTime.year, event.endTime.month, event.endTime.day);
      final target = DateTime(date.year, date.month, date.day);
      return (target.isAtSameMomentAs(start) || target.isAfter(start)) &&
             (target.isAtSameMomentAs(end) || target.isBefore(end));
    }).toList();
  }

  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end) async {
    final events = await getAllEvents();
    return events.where((event) {
      return (event.startTime.isAtSameMomentAs(start) || event.startTime.isAfter(start)) &&
             (event.endTime.isAtSameMomentAs(end) || event.endTime.isBefore(end));
    }).toList();
  }

  Future<void> addEvent(CalendarEvent event) async {
    final events = await getAllEvents();
    events.add(event);
    await _saveEvents(events);

    // Schedule notification
    if (event.isUpcoming) {
      _notificationService.scheduleNotification(
        title: event.title,
        body: event.description,
        scheduledDate: event.startTime.subtract(const Duration(minutes: 15)),
      );
    }
    notifyListeners();
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await _saveEvents(events);
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final events = await getAllEvents();
    events.removeWhere((e) => e.id == eventId);
    await _saveEvents(events);
    notifyListeners();
  }

  Future<void> _saveEvents(List<CalendarEvent> events) async {
    if (_prefs == null) await initialize();
    final String data = json.encode(events.map((e) => e.toJson()).toList());
    await _prefs?.setString(_eventsKey, data);
  }

  // Attendance Methods
  Future<List<Attendance>> getAllAttendance() async {
    if (_prefs == null) await initialize();
    final String? data = _prefs?.getString(_attendanceKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Attendance.fromJson(json)).toList();
  }

  Future<List<Attendance>> getAttendanceForEmployee(
    String employeeId,
    DateTime start,
    DateTime end,
  ) async {
    final records = await getAllAttendance();
    return records.where((record) {
      return record.employeeId == employeeId &&
             (record.date.isAtSameMomentAs(start) || record.date.isAfter(start)) &&
             (record.date.isAtSameMomentAs(end) || record.date.isBefore(end));
    }).toList();
  }

  Future<void> markAttendance(Attendance attendance) async {
    final records = await getAllAttendance();
    final index = records.indexWhere((r) =>
        r.employeeId == attendance.employeeId &&
        r.date.year == attendance.date.year &&
        r.date.month == attendance.date.month &&
        r.date.day == attendance.date.day);

    if (index != -1) {
      records[index] = attendance;
    } else {
      records.add(attendance);
    }

    await _saveAttendance(records);
    notifyListeners();
  }

  Future<void> _saveAttendance(List<Attendance> records) async {
    if (_prefs == null) await initialize();
    final String data = json.encode(records.map((r) => r.toJson()).toList());
    await _prefs?.setString(_attendanceKey, data);
  }

  Future<Map<String, int>> getAttendanceStats(
    String employeeId,
    DateTime start,
    DateTime end,
  ) async {
    final records = await getAttendanceForEmployee(employeeId, start, end);
    final stats = <String, int>{};

    for (final record in records) {
      final status = record.status.toString().split('.').last;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  Future<double> getAttendancePercentage(
    String employeeId,
    DateTime start,
    DateTime end,
  ) async {
    final records = await getAttendanceForEmployee(employeeId, start, end);
    if (records.isEmpty) return 0.0;

    final presentCount = records.where((r) =>
        r.status == AttendanceStatus.present ||
        r.status == AttendanceStatus.workFromHome
    ).length;

    return (presentCount / records.length) * 100;
  }

  Future<List<Attendance>> getLateArrivals(
    String employeeId,
    DateTime start,
    DateTime end,
  ) async {
    final records = await getAttendanceForEmployee(employeeId, start, end);
    return records.where((r) => r.isLate).toList();
  }

  Future<List<Attendance>> getEarlyCheckouts(
    String employeeId,
    DateTime start,
    DateTime end,
  ) async {
    final records = await getAttendanceForEmployee(employeeId, start, end);
    return records.where((r) => r.isEarlyCheckout).toList();
  }
}
