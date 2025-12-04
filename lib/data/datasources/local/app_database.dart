import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Participants Table
class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get emoji => text().withLength(min: 1, max: 10)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Health Events Table
class HealthEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get participantId => integer().references(Participants, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get category => text().withDefault(const Constant('general'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Metrics Table
class Metrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get participantId => integer().references(Participants, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get unit => text().withLength(min: 1, max: 20)();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Metric Data Points Table
class MetricDataPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get metricId => integer().references(Metrics, #id, onDelete: KeyAction.cascade)();
  RealColumn get value => real()();
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Participants, HealthEvents, Metrics, MetricDataPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Participant queries
  Future<List<Participant>> getAllParticipants() => select(participants).get();
  Future<Participant?> getParticipant(int id) => 
    (select(participants)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> addParticipant(ParticipantsCompanion participant) => 
    into(participants).insert(participant);
  Future<bool> updateParticipant(Participant participant) => 
    update(participants).replace(participant);
  Future<int> deleteParticipant(int id) => 
    (delete(participants)..where((t) => t.id.equals(id))).go();

  // Health Events queries
  Future<List<HealthEvent>> getEventsForParticipant(int participantId) =>
    (select(healthEvents)..where((t) => t.participantId.equals(participantId))
      ..orderBy([(t) => OrderingTerm.desc(t.eventDate)])).get();
  
  Future<List<HealthEvent>> getEventsForDateRange(int participantId, DateTime start, DateTime end) =>
    (select(healthEvents)
      ..where((t) => t.participantId.equals(participantId) & 
                     t.eventDate.isBiggerOrEqualValue(start) &
                     t.eventDate.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.eventDate)])).get();
  
  Future<int> addHealthEvent(HealthEventsCompanion event) => 
    into(healthEvents).insert(event);
  Future<bool> updateHealthEvent(HealthEvent event) => 
    update(healthEvents).replace(event);
  Future<int> deleteHealthEvent(int id) => 
    (delete(healthEvents)..where((t) => t.id.equals(id))).go();

  // Metrics queries
  Future<List<Metric>> getMetricsForParticipant(int participantId) =>
    (select(metrics)..where((t) => t.participantId.equals(participantId))).get();
  
  Future<int> addMetric(MetricsCompanion metric) => 
    into(metrics).insert(metric);
  Future<bool> updateMetric(Metric metric) => 
    update(metrics).replace(metric);
  Future<int> deleteMetric(int id) => 
    (delete(metrics)..where((t) => t.id.equals(id))).go();

  // Metric Data Points queries
  Future<List<MetricDataPoint>> getDataPointsForMetric(int metricId) =>
    (select(metricDataPoints)..where((t) => t.metricId.equals(metricId))
      ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)])).get();
  
  Future<int> addDataPoint(MetricDataPointsCompanion dataPoint) => 
    into(metricDataPoints).insert(dataPoint);
  Future<bool> updateDataPoint(MetricDataPoint dataPoint) => 
    update(metricDataPoints).replace(dataPoint);
  Future<int> deleteDataPoint(int id) => 
    (delete(metricDataPoints)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medigraf.sqlite'));
    return NativeDatabase(file);
  });
}