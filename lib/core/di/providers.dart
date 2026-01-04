import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/local/app_database.dart';

// IMPORTANT: The 'OrderingTerm' class comes from 'package:drift/drift.dart'
// Make sure this import is present to avoid "undefined name" errors

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Participants Provider - Riverpod 3.x syntax
final participantsProvider = StreamProvider<List<Participant>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.participants).watch();
});

// Selected Participants Provider
final selectedParticipantsProvider = StateProvider<Set<int>>((ref) => <int>{});

// Health Events Provider - Riverpod 3.x family syntax
final healthEventsProvider = StreamProvider.autoDispose
    .family<List<HealthEvent>, int>((ref, participantId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.healthEvents)
        ..where((t) => t.participantId.equals(participantId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
      .watch();
});

// Metrics Provider - Riverpod 3.x family syntax
final metricsProvider =
    StreamProvider.autoDispose.family<List<Metric>, int>((ref, participantId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.metrics)
        ..where((t) => t.participantId.equals(participantId)))
      .watch();
});

// Metric Data Points Provider - Riverpod 3.x family syntax
final metricDataPointsProvider = StreamProvider.autoDispose
    .family<List<MetricDataPoint>, int>((ref, metricId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.metricDataPoints)
        ..where((t) => t.metricId.equals(metricId))
        ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
      .watch();
});

//Theme Provider
final themeProvider = StateProvider<bool>((ref) => false);
