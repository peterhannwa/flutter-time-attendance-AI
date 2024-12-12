import 'package:uuid/uuid.dart';

enum EventType {
  meeting,
  task,
  reminder,
  holiday,
  birthday,
  leave,
  attendance
}

enum EventPriority {
  low,
  medium,
  high
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final EventPriority priority;
  final bool isAllDay;
  final String createdBy;
  final List<String> attendees;
  final String? location;
  final Map<String, dynamic>? metadata;
  final bool isRecurring;
  final String? recurrenceRule;
  final String? color;

  CalendarEvent({
    String? id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.priority = EventPriority.medium,
    this.isAllDay = false,
    required this.createdBy,
    this.attendees = const [],
    this.location,
    this.metadata,
    this.isRecurring = false,
    this.recurrenceRule,
    this.color,
  }) : id = id ?? const Uuid().v4();

  bool get isUpcoming =>
      startTime.isAfter(DateTime.now()) ||
      (startTime.day == DateTime.now().day && !isComplete);

  bool get isComplete => endTime.isBefore(DateTime.now());

  bool get isInProgress =>
      startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());

  Duration get duration => endTime.difference(startTime);

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    EventPriority? priority,
    bool? isAllDay,
    String? createdBy,
    List<String>? attendees,
    String? location,
    Map<String, dynamic>? metadata,
    bool? isRecurring,
    String? recurrenceRule,
    String? color,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isAllDay: isAllDay ?? this.isAllDay,
      createdBy: createdBy ?? this.createdBy,
      attendees: attendees ?? this.attendees,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.toString(),
      'priority': priority.toString(),
      'isAllDay': isAllDay,
      'createdBy': createdBy,
      'attendees': attendees,
      'location': location,
      'metadata': metadata,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'color': color,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: EventType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      isAllDay: json['isAllDay'],
      createdBy: json['createdBy'],
      attendees: List<String>.from(json['attendees']),
      location: json['location'],
      metadata: json['metadata'],
      isRecurring: json['isRecurring'],
      recurrenceRule: json['recurrenceRule'],
      color: json['color'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
