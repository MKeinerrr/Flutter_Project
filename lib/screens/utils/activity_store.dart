import 'package:flutter/foundation.dart';

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.name,
    required this.timestamp,
  });

  final int id;
  final String name;
  final DateTime timestamp;
}

class ActivityStore {
  ActivityStore._();

  static final ValueNotifier<List<ActivityEntry>> entries =
      ValueNotifier<List<ActivityEntry>>(<ActivityEntry>[]);

  static void addView({required int id, required String name}) {
    final List<ActivityEntry> next = List<ActivityEntry>.from(entries.value);
    next.insert(0, ActivityEntry(id: id, name: name, timestamp: DateTime.now()));
    entries.value = next;
  }
}
