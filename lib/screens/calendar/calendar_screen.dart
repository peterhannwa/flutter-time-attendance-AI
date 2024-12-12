import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/calendar_event.dart';
import '../../models/attendance.dart';
import '../../services/calendar_service.dart';
import '../../services/auth_service.dart';
import 'event_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  final AuthService _authService = AuthService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _selectedEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final today = DateTime.now();
      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 0);

      for (var day = startOfMonth; day.isBefore(endOfMonth); day = day.add(const Duration(days: 1))) {
        final events = await _calendarService.getEventsForDay(day);
        if (events.isNotEmpty) {
          setState(() {
            _events[day] = events;
          });
        }
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _markAttendance(AttendanceStatus status) async {
    try {
      final attendance = Attendance(
        employeeId: _authService.currentUser!.id,
        date: DateTime.now(),
        status: status,
        checkIn: status == AttendanceStatus.present ? DateTime.now() : null,
      );

      await _calendarService.markAttendance(attendance);

      final event = CalendarEvent(
        title: 'Attendance: ${status.toString().split('.').last}',
        description: 'Marked attendance for ${DateTime.now().toString().split(' ')[0]}',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 8)),
        type: EventType.attendance,
        createdBy: _authService.currentUser!.id,
      );

      await _calendarService.addEvent(event);
      _loadEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          PopupMenuButton<AttendanceStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: _markAttendance,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AttendanceStatus.present,
                child: Text('Mark Present'),
              ),
              const PopupMenuItem(
                value: AttendanceStatus.workFromHome,
                child: Text('Work From Home'),
              ),
              const PopupMenuItem(
                value: AttendanceStatus.onLeave,
                child: Text('On Leave'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              final dayEvents = _events[DateTime(day.year, day.month, day.day)] ?? [];
              return dayEvents;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadSelectedEvents();
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              markersMaxCount: 3,
              markersAlignment: Alignment.bottomCenter,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    width: 6,
                    height: 6,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedEvents.isEmpty
                    ? const Center(child: Text('No events for this day'))
                    : ListView.builder(
                        itemCount: _selectedEvents.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final event = _selectedEvents[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                _getEventIcon(event.type),
                                color: _getEventColor(event.type),
                              ),
                              title: Text(event.title),
                              subtitle: Text(
                                '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                                '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                              ),
                              trailing: event.isComplete
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailsScreen(event: event),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadSelectedEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = _events[_selectedDay!] ?? [];
      setState(() => _selectedEvents = events);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.people;
      case EventType.task:
        return Icons.task;
      case EventType.reminder:
        return Icons.notification_important;
      case EventType.holiday:
        return Icons.celebration;
      case EventType.birthday:
        return Icons.cake;
      case EventType.leave:
        return Icons.event_busy;
      case EventType.attendance:
        return Icons.how_to_reg;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Colors.blue;
      case EventType.task:
        return Colors.orange;
      case EventType.reminder:
        return Colors.purple;
      case EventType.holiday:
        return Colors.red;
      case EventType.birthday:
        return Colors.pink;
      case EventType.leave:
        return Colors.grey;
      case EventType.attendance:
        return Colors.green;
    }
  }
}
