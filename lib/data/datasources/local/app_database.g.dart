// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(Insertable<Participant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final int id;
  final String name;
  final String emoji;
  final DateTime createdAt;
  const Participant(
      {required this.id,
      required this.name,
      required this.emoji,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      createdAt: Value(createdAt),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Participant copyWith(
          {int? id, String? name, String? emoji, DateTime? createdAt}) =>
      Participant(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        createdAt: createdAt ?? this.createdAt,
      );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<DateTime> createdAt;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String emoji,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        emoji = Value(emoji);
  static Insertable<Participant> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? emoji,
      Value<DateTime>? createdAt}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HealthEventsTable extends HealthEvents
    with TableInfo<$HealthEventsTable, HealthEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES participants (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, participantId, title, description, eventDate, category, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_events';
  @override
  VerificationContext validateIntegrity(Insertable<HealthEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HealthEventsTable createAlias(String alias) {
    return $HealthEventsTable(attachedDatabase, alias);
  }
}

class HealthEvent extends DataClass implements Insertable<HealthEvent> {
  final int id;
  final int participantId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String category;
  final DateTime createdAt;
  const HealthEvent(
      {required this.id,
      required this.participantId,
      required this.title,
      this.description,
      required this.eventDate,
      required this.category,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['participant_id'] = Variable<int>(participantId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['event_date'] = Variable<DateTime>(eventDate);
    map['category'] = Variable<String>(category);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthEventsCompanion toCompanion(bool nullToAbsent) {
    return HealthEventsCompanion(
      id: Value(id),
      participantId: Value(participantId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      eventDate: Value(eventDate),
      category: Value(category),
      createdAt: Value(createdAt),
    );
  }

  factory HealthEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthEvent(
      id: serializer.fromJson<int>(json['id']),
      participantId: serializer.fromJson<int>(json['participantId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'participantId': serializer.toJson<int>(participantId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthEvent copyWith(
          {int? id,
          int? participantId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? eventDate,
          String? category,
          DateTime? createdAt}) =>
      HealthEvent(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        eventDate: eventDate ?? this.eventDate,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
      );
  HealthEvent copyWithCompanion(HealthEventsCompanion data) {
    return HealthEvent(
      id: data.id.present ? data.id.value : this.id,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthEvent(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, participantId, title, description, eventDate, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthEvent &&
          other.id == this.id &&
          other.participantId == this.participantId &&
          other.title == this.title &&
          other.description == this.description &&
          other.eventDate == this.eventDate &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class HealthEventsCompanion extends UpdateCompanion<HealthEvent> {
  final Value<int> id;
  final Value<int> participantId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> eventDate;
  final Value<String> category;
  final Value<DateTime> createdAt;
  const HealthEventsCompanion({
    this.id = const Value.absent(),
    this.participantId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthEventsCompanion.insert({
    this.id = const Value.absent(),
    required int participantId,
    required String title,
    this.description = const Value.absent(),
    required DateTime eventDate,
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : participantId = Value(participantId),
        title = Value(title),
        eventDate = Value(eventDate);
  static Insertable<HealthEvent> custom({
    Expression<int>? id,
    Expression<int>? participantId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? eventDate,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participantId != null) 'participant_id': participantId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (eventDate != null) 'event_date': eventDate,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? participantId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? eventDate,
      Value<String>? category,
      Value<DateTime>? createdAt}) {
    return HealthEventsCompanion(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthEventsCompanion(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MetricsTable extends Metrics with TableInfo<$MetricsTable, Metric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES participants (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#2196F3'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, participantId, name, unit, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metrics';
  @override
  VerificationContext validateIntegrity(Insertable<Metric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Metric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Metric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MetricsTable createAlias(String alias) {
    return $MetricsTable(attachedDatabase, alias);
  }
}

class Metric extends DataClass implements Insertable<Metric> {
  final int id;
  final int participantId;
  final String name;
  final String unit;
  final String color;
  final DateTime createdAt;
  const Metric(
      {required this.id,
      required this.participantId,
      required this.name,
      required this.unit,
      required this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['participant_id'] = Variable<int>(participantId);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MetricsCompanion toCompanion(bool nullToAbsent) {
    return MetricsCompanion(
      id: Value(id),
      participantId: Value(participantId),
      name: Value(name),
      unit: Value(unit),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Metric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Metric(
      id: serializer.fromJson<int>(json['id']),
      participantId: serializer.fromJson<int>(json['participantId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'participantId': serializer.toJson<int>(participantId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Metric copyWith(
          {int? id,
          int? participantId,
          String? name,
          String? unit,
          String? color,
          DateTime? createdAt}) =>
      Metric(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  Metric copyWithCompanion(MetricsCompanion data) {
    return Metric(
      id: data.id.present ? data.id.value : this.id,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Metric(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, participantId, name, unit, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Metric &&
          other.id == this.id &&
          other.participantId == this.participantId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class MetricsCompanion extends UpdateCompanion<Metric> {
  final Value<int> id;
  final Value<int> participantId;
  final Value<String> name;
  final Value<String> unit;
  final Value<String> color;
  final Value<DateTime> createdAt;
  const MetricsCompanion({
    this.id = const Value.absent(),
    this.participantId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MetricsCompanion.insert({
    this.id = const Value.absent(),
    required int participantId,
    required String name,
    required String unit,
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : participantId = Value(participantId),
        name = Value(name),
        unit = Value(unit);
  static Insertable<Metric> custom({
    Expression<int>? id,
    Expression<int>? participantId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participantId != null) 'participant_id': participantId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MetricsCompanion copyWith(
      {Value<int>? id,
      Value<int>? participantId,
      Value<String>? name,
      Value<String>? unit,
      Value<String>? color,
      Value<DateTime>? createdAt}) {
    return MetricsCompanion(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricsCompanion(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MetricDataPointsTable extends MetricDataPoints
    with TableInfo<$MetricDataPointsTable, MetricDataPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricDataPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _metricIdMeta =
      const VerificationMeta('metricId');
  @override
  late final GeneratedColumn<int> metricId = GeneratedColumn<int>(
      'metric_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES metrics (id) ON DELETE CASCADE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, metricId, value, recordedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_data_points';
  @override
  VerificationContext validateIntegrity(Insertable<MetricDataPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('metric_id')) {
      context.handle(_metricIdMeta,
          metricId.isAcceptableOrUnknown(data['metric_id']!, _metricIdMeta));
    } else if (isInserting) {
      context.missing(_metricIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetricDataPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricDataPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      metricId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}metric_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MetricDataPointsTable createAlias(String alias) {
    return $MetricDataPointsTable(attachedDatabase, alias);
  }
}

class MetricDataPoint extends DataClass implements Insertable<MetricDataPoint> {
  final int id;
  final int metricId;
  final double value;
  final DateTime recordedAt;
  final DateTime createdAt;
  const MetricDataPoint(
      {required this.id,
      required this.metricId,
      required this.value,
      required this.recordedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['metric_id'] = Variable<int>(metricId);
    map['value'] = Variable<double>(value);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MetricDataPointsCompanion toCompanion(bool nullToAbsent) {
    return MetricDataPointsCompanion(
      id: Value(id),
      metricId: Value(metricId),
      value: Value(value),
      recordedAt: Value(recordedAt),
      createdAt: Value(createdAt),
    );
  }

  factory MetricDataPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricDataPoint(
      id: serializer.fromJson<int>(json['id']),
      metricId: serializer.fromJson<int>(json['metricId']),
      value: serializer.fromJson<double>(json['value']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'metricId': serializer.toJson<int>(metricId),
      'value': serializer.toJson<double>(value),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MetricDataPoint copyWith(
          {int? id,
          int? metricId,
          double? value,
          DateTime? recordedAt,
          DateTime? createdAt}) =>
      MetricDataPoint(
        id: id ?? this.id,
        metricId: metricId ?? this.metricId,
        value: value ?? this.value,
        recordedAt: recordedAt ?? this.recordedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  MetricDataPoint copyWithCompanion(MetricDataPointsCompanion data) {
    return MetricDataPoint(
      id: data.id.present ? data.id.value : this.id,
      metricId: data.metricId.present ? data.metricId.value : this.metricId,
      value: data.value.present ? data.value.value : this.value,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricDataPoint(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('value: $value, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, metricId, value, recordedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricDataPoint &&
          other.id == this.id &&
          other.metricId == this.metricId &&
          other.value == this.value &&
          other.recordedAt == this.recordedAt &&
          other.createdAt == this.createdAt);
}

class MetricDataPointsCompanion extends UpdateCompanion<MetricDataPoint> {
  final Value<int> id;
  final Value<int> metricId;
  final Value<double> value;
  final Value<DateTime> recordedAt;
  final Value<DateTime> createdAt;
  const MetricDataPointsCompanion({
    this.id = const Value.absent(),
    this.metricId = const Value.absent(),
    this.value = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MetricDataPointsCompanion.insert({
    this.id = const Value.absent(),
    required int metricId,
    required double value,
    required DateTime recordedAt,
    this.createdAt = const Value.absent(),
  })  : metricId = Value(metricId),
        value = Value(value),
        recordedAt = Value(recordedAt);
  static Insertable<MetricDataPoint> custom({
    Expression<int>? id,
    Expression<int>? metricId,
    Expression<double>? value,
    Expression<DateTime>? recordedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricId != null) 'metric_id': metricId,
      if (value != null) 'value': value,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MetricDataPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? metricId,
      Value<double>? value,
      Value<DateTime>? recordedAt,
      Value<DateTime>? createdAt}) {
    return MetricDataPointsCompanion(
      id: id ?? this.id,
      metricId: metricId ?? this.metricId,
      value: value ?? this.value,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (metricId.present) {
      map['metric_id'] = Variable<int>(metricId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricDataPointsCompanion(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('value: $value, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FilesTable extends Files with TableInfo<$FilesTable, DbFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES participants (id) ON DELETE CASCADE'));
  static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  @override
  late final GeneratedColumn<String> fileId = GeneratedColumn<String>(
      'file_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('GENERAL'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fileDateMeta =
      const VerificationMeta('fileDate');
  @override
  late final GeneratedColumn<DateTime> fileDate = GeneratedColumn<DateTime>(
      'file_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        participantId,
        fileId,
        title,
        type,
        filePath,
        source,
        fileSize,
        fileDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'files';
  @override
  VerificationContext validateIntegrity(Insertable<DbFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta));
    } else if (isInserting) {
      context.missing(_fileIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('file_date')) {
      context.handle(_fileDateMeta,
          fileDate.isAcceptableOrUnknown(data['file_date']!, _fileDateMeta));
    } else if (isInserting) {
      context.missing(_fileDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      fileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      fileDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}file_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FilesTable createAlias(String alias) {
    return $FilesTable(attachedDatabase, alias);
  }
}

class DbFile extends DataClass implements Insertable<DbFile> {
  final int id;
  final int participantId;

  /// uuid из FileMetadata.id
  final String fileId;
  final String title;
  final String type;
  final String filePath;
  final String source;
  final int? fileSize;
  final DateTime fileDate;
  final DateTime createdAt;
  const DbFile(
      {required this.id,
      required this.participantId,
      required this.fileId,
      required this.title,
      required this.type,
      required this.filePath,
      required this.source,
      this.fileSize,
      required this.fileDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['participant_id'] = Variable<int>(participantId);
    map['file_id'] = Variable<String>(fileId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['file_date'] = Variable<DateTime>(fileDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      id: Value(id),
      participantId: Value(participantId),
      fileId: Value(fileId),
      title: Value(title),
      type: Value(type),
      filePath: Value(filePath),
      source: Value(source),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      fileDate: Value(fileDate),
      createdAt: Value(createdAt),
    );
  }

  factory DbFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFile(
      id: serializer.fromJson<int>(json['id']),
      participantId: serializer.fromJson<int>(json['participantId']),
      fileId: serializer.fromJson<String>(json['fileId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      source: serializer.fromJson<String>(json['source']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      fileDate: serializer.fromJson<DateTime>(json['fileDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'participantId': serializer.toJson<int>(participantId),
      'fileId': serializer.toJson<String>(fileId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'source': serializer.toJson<String>(source),
      'fileSize': serializer.toJson<int?>(fileSize),
      'fileDate': serializer.toJson<DateTime>(fileDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbFile copyWith(
          {int? id,
          int? participantId,
          String? fileId,
          String? title,
          String? type,
          String? filePath,
          String? source,
          Value<int?> fileSize = const Value.absent(),
          DateTime? fileDate,
          DateTime? createdAt}) =>
      DbFile(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        fileId: fileId ?? this.fileId,
        title: title ?? this.title,
        type: type ?? this.type,
        filePath: filePath ?? this.filePath,
        source: source ?? this.source,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        fileDate: fileDate ?? this.fileDate,
        createdAt: createdAt ?? this.createdAt,
      );
  DbFile copyWithCompanion(FilesCompanion data) {
    return DbFile(
      id: data.id.present ? data.id.value : this.id,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      fileId: data.fileId.present ? data.fileId.value : this.fileId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      source: data.source.present ? data.source.value : this.source,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      fileDate: data.fileDate.present ? data.fileDate.value : this.fileDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFile(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('fileId: $fileId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('source: $source, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileDate: $fileDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, participantId, fileId, title, type,
      filePath, source, fileSize, fileDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFile &&
          other.id == this.id &&
          other.participantId == this.participantId &&
          other.fileId == this.fileId &&
          other.title == this.title &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.source == this.source &&
          other.fileSize == this.fileSize &&
          other.fileDate == this.fileDate &&
          other.createdAt == this.createdAt);
}

class FilesCompanion extends UpdateCompanion<DbFile> {
  final Value<int> id;
  final Value<int> participantId;
  final Value<String> fileId;
  final Value<String> title;
  final Value<String> type;
  final Value<String> filePath;
  final Value<String> source;
  final Value<int?> fileSize;
  final Value<DateTime> fileDate;
  final Value<DateTime> createdAt;
  const FilesCompanion({
    this.id = const Value.absent(),
    this.participantId = const Value.absent(),
    this.fileId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.source = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FilesCompanion.insert({
    this.id = const Value.absent(),
    required int participantId,
    required String fileId,
    required String title,
    this.type = const Value.absent(),
    required String filePath,
    required String source,
    this.fileSize = const Value.absent(),
    required DateTime fileDate,
    this.createdAt = const Value.absent(),
  })  : participantId = Value(participantId),
        fileId = Value(fileId),
        title = Value(title),
        filePath = Value(filePath),
        source = Value(source),
        fileDate = Value(fileDate);
  static Insertable<DbFile> custom({
    Expression<int>? id,
    Expression<int>? participantId,
    Expression<String>? fileId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<String>? source,
    Expression<int>? fileSize,
    Expression<DateTime>? fileDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participantId != null) 'participant_id': participantId,
      if (fileId != null) 'file_id': fileId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (source != null) 'source': source,
      if (fileSize != null) 'file_size': fileSize,
      if (fileDate != null) 'file_date': fileDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FilesCompanion copyWith(
      {Value<int>? id,
      Value<int>? participantId,
      Value<String>? fileId,
      Value<String>? title,
      Value<String>? type,
      Value<String>? filePath,
      Value<String>? source,
      Value<int?>? fileSize,
      Value<DateTime>? fileDate,
      Value<DateTime>? createdAt}) {
    return FilesCompanion(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      fileId: fileId ?? this.fileId,
      title: title ?? this.title,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      source: source ?? this.source,
      fileSize: fileSize ?? this.fileSize,
      fileDate: fileDate ?? this.fileDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (fileDate.present) {
      map['file_date'] = Variable<DateTime>(fileDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('id: $id, ')
          ..write('participantId: $participantId, ')
          ..write('fileId: $fileId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('source: $source, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileDate: $fileDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $HealthEventsTable healthEvents = $HealthEventsTable(this);
  late final $MetricsTable metrics = $MetricsTable(this);
  late final $MetricDataPointsTable metricDataPoints =
      $MetricDataPointsTable(this);
  late final $FilesTable files = $FilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [participants, healthEvents, metrics, metricDataPoints, files];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('health_events', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('metrics', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('metrics',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('metric_data_points', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('files', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<int> id,
  required String name,
  required String emoji,
  Value<DateTime> createdAt,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> emoji,
  Value<DateTime> createdAt,
});

final class $$ParticipantsTableReferences
    extends BaseReferences<_$AppDatabase, $ParticipantsTable, Participant> {
  $$ParticipantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HealthEventsTable, List<HealthEvent>>
      _healthEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.healthEvents,
              aliasName: $_aliasNameGenerator(
                  db.participants.id, db.healthEvents.participantId));

  $$HealthEventsTableProcessedTableManager get healthEventsRefs {
    final manager = $$HealthEventsTableTableManager($_db, $_db.healthEvents)
        .filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_healthEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MetricsTable, List<Metric>> _metricsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.metrics,
          aliasName: $_aliasNameGenerator(
              db.participants.id, db.metrics.participantId));

  $$MetricsTableProcessedTableManager get metricsRefs {
    final manager = $$MetricsTableTableManager($_db, $_db.metrics)
        .filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_metricsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FilesTable, List<DbFile>> _filesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.files,
          aliasName:
              $_aliasNameGenerator(db.participants.id, db.files.participantId));

  $$FilesTableProcessedTableManager get filesRefs {
    final manager = $$FilesTableTableManager($_db, $_db.files)
        .filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_filesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> healthEventsRefs(
      Expression<bool> Function($$HealthEventsTableFilterComposer f) f) {
    final $$HealthEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.healthEvents,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HealthEventsTableFilterComposer(
              $db: $db,
              $table: $db.healthEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> metricsRefs(
      Expression<bool> Function($$MetricsTableFilterComposer f) f) {
    final $$MetricsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metrics,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricsTableFilterComposer(
              $db: $db,
              $table: $db.metrics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> filesRefs(
      Expression<bool> Function($$FilesTableFilterComposer f) f) {
    final $$FilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.files,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FilesTableFilterComposer(
              $db: $db,
              $table: $db.files,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> healthEventsRefs<T extends Object>(
      Expression<T> Function($$HealthEventsTableAnnotationComposer a) f) {
    final $$HealthEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.healthEvents,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HealthEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.healthEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> metricsRefs<T extends Object>(
      Expression<T> Function($$MetricsTableAnnotationComposer a) f) {
    final $$MetricsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metrics,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricsTableAnnotationComposer(
              $db: $db,
              $table: $db.metrics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> filesRefs<T extends Object>(
      Expression<T> Function($$FilesTableAnnotationComposer a) f) {
    final $$FilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.files,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FilesTableAnnotationComposer(
              $db: $db,
              $table: $db.files,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    PrefetchHooks Function(
        {bool healthEventsRefs, bool metricsRefs, bool filesRefs})> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ParticipantsCompanion(
            id: id,
            name: name,
            emoji: emoji,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String emoji,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ParticipantsCompanion.insert(
            id: id,
            name: name,
            emoji: emoji,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {healthEventsRefs = false,
              metricsRefs = false,
              filesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (healthEventsRefs) db.healthEvents,
                if (metricsRefs) db.metrics,
                if (filesRefs) db.files
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (healthEventsRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            HealthEvent>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._healthEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .healthEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantId == item.id),
                        typedResults: items),
                  if (metricsRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            Metric>(
                        currentTable: table,
                        referencedTable:
                            $$ParticipantsTableReferences._metricsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .metricsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantId == item.id),
                        typedResults: items),
                  if (filesRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            DbFile>(
                        currentTable: table,
                        referencedTable:
                            $$ParticipantsTableReferences._filesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .filesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    PrefetchHooks Function(
        {bool healthEventsRefs, bool metricsRefs, bool filesRefs})>;
typedef $$HealthEventsTableCreateCompanionBuilder = HealthEventsCompanion
    Function({
  Value<int> id,
  required int participantId,
  required String title,
  Value<String?> description,
  required DateTime eventDate,
  Value<String> category,
  Value<DateTime> createdAt,
});
typedef $$HealthEventsTableUpdateCompanionBuilder = HealthEventsCompanion
    Function({
  Value<int> id,
  Value<int> participantId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> eventDate,
  Value<String> category,
  Value<DateTime> createdAt,
});

final class $$HealthEventsTableReferences
    extends BaseReferences<_$AppDatabase, $HealthEventsTable, HealthEvent> {
  $$HealthEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias($_aliasNameGenerator(
          db.healthEvents.participantId, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HealthEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HealthEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HealthEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HealthEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthEventsTable,
    HealthEvent,
    $$HealthEventsTableFilterComposer,
    $$HealthEventsTableOrderingComposer,
    $$HealthEventsTableAnnotationComposer,
    $$HealthEventsTableCreateCompanionBuilder,
    $$HealthEventsTableUpdateCompanionBuilder,
    (HealthEvent, $$HealthEventsTableReferences),
    HealthEvent,
    PrefetchHooks Function({bool participantId})> {
  $$HealthEventsTableTableManager(_$AppDatabase db, $HealthEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> participantId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HealthEventsCompanion(
            id: id,
            participantId: participantId,
            title: title,
            description: description,
            eventDate: eventDate,
            category: category,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int participantId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime eventDate,
            Value<String> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HealthEventsCompanion.insert(
            id: id,
            participantId: participantId,
            title: title,
            description: description,
            eventDate: eventDate,
            category: category,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$HealthEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable:
                        $$HealthEventsTableReferences._participantIdTable(db),
                    referencedColumn: $$HealthEventsTableReferences
                        ._participantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$HealthEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthEventsTable,
    HealthEvent,
    $$HealthEventsTableFilterComposer,
    $$HealthEventsTableOrderingComposer,
    $$HealthEventsTableAnnotationComposer,
    $$HealthEventsTableCreateCompanionBuilder,
    $$HealthEventsTableUpdateCompanionBuilder,
    (HealthEvent, $$HealthEventsTableReferences),
    HealthEvent,
    PrefetchHooks Function({bool participantId})>;
typedef $$MetricsTableCreateCompanionBuilder = MetricsCompanion Function({
  Value<int> id,
  required int participantId,
  required String name,
  required String unit,
  Value<String> color,
  Value<DateTime> createdAt,
});
typedef $$MetricsTableUpdateCompanionBuilder = MetricsCompanion Function({
  Value<int> id,
  Value<int> participantId,
  Value<String> name,
  Value<String> unit,
  Value<String> color,
  Value<DateTime> createdAt,
});

final class $$MetricsTableReferences
    extends BaseReferences<_$AppDatabase, $MetricsTable, Metric> {
  $$MetricsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(
          $_aliasNameGenerator(db.metrics.participantId, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MetricDataPointsTable, List<MetricDataPoint>>
      _metricDataPointsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.metricDataPoints,
              aliasName: $_aliasNameGenerator(
                  db.metrics.id, db.metricDataPoints.metricId));

  $$MetricDataPointsTableProcessedTableManager get metricDataPointsRefs {
    final manager =
        $$MetricDataPointsTableTableManager($_db, $_db.metricDataPoints)
            .filter((f) => f.metricId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_metricDataPointsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MetricsTableFilterComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> metricDataPointsRefs(
      Expression<bool> Function($$MetricDataPointsTableFilterComposer f) f) {
    final $$MetricDataPointsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metricDataPoints,
        getReferencedColumn: (t) => t.metricId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricDataPointsTableFilterComposer(
              $db: $db,
              $table: $db.metricDataPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> metricDataPointsRefs<T extends Object>(
      Expression<T> Function($$MetricDataPointsTableAnnotationComposer a) f) {
    final $$MetricDataPointsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metricDataPoints,
        getReferencedColumn: (t) => t.metricId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricDataPointsTableAnnotationComposer(
              $db: $db,
              $table: $db.metricDataPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetricsTable,
    Metric,
    $$MetricsTableFilterComposer,
    $$MetricsTableOrderingComposer,
    $$MetricsTableAnnotationComposer,
    $$MetricsTableCreateCompanionBuilder,
    $$MetricsTableUpdateCompanionBuilder,
    (Metric, $$MetricsTableReferences),
    Metric,
    PrefetchHooks Function({bool participantId, bool metricDataPointsRefs})> {
  $$MetricsTableTableManager(_$AppDatabase db, $MetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> participantId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MetricsCompanion(
            id: id,
            participantId: participantId,
            name: name,
            unit: unit,
            color: color,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int participantId,
            required String name,
            required String unit,
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MetricsCompanion.insert(
            id: id,
            participantId: participantId,
            name: name,
            unit: unit,
            color: color,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MetricsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {participantId = false, metricDataPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (metricDataPointsRefs) db.metricDataPoints
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable:
                        $$MetricsTableReferences._participantIdTable(db),
                    referencedColumn:
                        $$MetricsTableReferences._participantIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (metricDataPointsRefs)
                    await $_getPrefetchedData<Metric, $MetricsTable,
                            MetricDataPoint>(
                        currentTable: table,
                        referencedTable: $$MetricsTableReferences
                            ._metricDataPointsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MetricsTableReferences(db, table, p0)
                                .metricDataPointsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.metricId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetricsTable,
    Metric,
    $$MetricsTableFilterComposer,
    $$MetricsTableOrderingComposer,
    $$MetricsTableAnnotationComposer,
    $$MetricsTableCreateCompanionBuilder,
    $$MetricsTableUpdateCompanionBuilder,
    (Metric, $$MetricsTableReferences),
    Metric,
    PrefetchHooks Function({bool participantId, bool metricDataPointsRefs})>;
typedef $$MetricDataPointsTableCreateCompanionBuilder
    = MetricDataPointsCompanion Function({
  Value<int> id,
  required int metricId,
  required double value,
  required DateTime recordedAt,
  Value<DateTime> createdAt,
});
typedef $$MetricDataPointsTableUpdateCompanionBuilder
    = MetricDataPointsCompanion Function({
  Value<int> id,
  Value<int> metricId,
  Value<double> value,
  Value<DateTime> recordedAt,
  Value<DateTime> createdAt,
});

final class $$MetricDataPointsTableReferences extends BaseReferences<
    _$AppDatabase, $MetricDataPointsTable, MetricDataPoint> {
  $$MetricDataPointsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MetricsTable _metricIdTable(_$AppDatabase db) =>
      db.metrics.createAlias(
          $_aliasNameGenerator(db.metricDataPoints.metricId, db.metrics.id));

  $$MetricsTableProcessedTableManager get metricId {
    final $_column = $_itemColumn<int>('metric_id')!;

    final manager = $$MetricsTableTableManager($_db, $_db.metrics)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_metricIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MetricDataPointsTableFilterComposer
    extends Composer<_$AppDatabase, $MetricDataPointsTable> {
  $$MetricDataPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MetricsTableFilterComposer get metricId {
    final $$MetricsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.metricId,
        referencedTable: $db.metrics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricsTableFilterComposer(
              $db: $db,
              $table: $db.metrics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricDataPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetricDataPointsTable> {
  $$MetricDataPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MetricsTableOrderingComposer get metricId {
    final $$MetricsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.metricId,
        referencedTable: $db.metrics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricsTableOrderingComposer(
              $db: $db,
              $table: $db.metrics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricDataPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetricDataPointsTable> {
  $$MetricDataPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MetricsTableAnnotationComposer get metricId {
    final $$MetricsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.metricId,
        referencedTable: $db.metrics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricsTableAnnotationComposer(
              $db: $db,
              $table: $db.metrics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricDataPointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetricDataPointsTable,
    MetricDataPoint,
    $$MetricDataPointsTableFilterComposer,
    $$MetricDataPointsTableOrderingComposer,
    $$MetricDataPointsTableAnnotationComposer,
    $$MetricDataPointsTableCreateCompanionBuilder,
    $$MetricDataPointsTableUpdateCompanionBuilder,
    (MetricDataPoint, $$MetricDataPointsTableReferences),
    MetricDataPoint,
    PrefetchHooks Function({bool metricId})> {
  $$MetricDataPointsTableTableManager(
      _$AppDatabase db, $MetricDataPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetricDataPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetricDataPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetricDataPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> metricId = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MetricDataPointsCompanion(
            id: id,
            metricId: metricId,
            value: value,
            recordedAt: recordedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int metricId,
            required double value,
            required DateTime recordedAt,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MetricDataPointsCompanion.insert(
            id: id,
            metricId: metricId,
            value: value,
            recordedAt: recordedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MetricDataPointsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({metricId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (metricId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.metricId,
                    referencedTable:
                        $$MetricDataPointsTableReferences._metricIdTable(db),
                    referencedColumn:
                        $$MetricDataPointsTableReferences._metricIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MetricDataPointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetricDataPointsTable,
    MetricDataPoint,
    $$MetricDataPointsTableFilterComposer,
    $$MetricDataPointsTableOrderingComposer,
    $$MetricDataPointsTableAnnotationComposer,
    $$MetricDataPointsTableCreateCompanionBuilder,
    $$MetricDataPointsTableUpdateCompanionBuilder,
    (MetricDataPoint, $$MetricDataPointsTableReferences),
    MetricDataPoint,
    PrefetchHooks Function({bool metricId})>;
typedef $$FilesTableCreateCompanionBuilder = FilesCompanion Function({
  Value<int> id,
  required int participantId,
  required String fileId,
  required String title,
  Value<String> type,
  required String filePath,
  required String source,
  Value<int?> fileSize,
  required DateTime fileDate,
  Value<DateTime> createdAt,
});
typedef $$FilesTableUpdateCompanionBuilder = FilesCompanion Function({
  Value<int> id,
  Value<int> participantId,
  Value<String> fileId,
  Value<String> title,
  Value<String> type,
  Value<String> filePath,
  Value<String> source,
  Value<int?> fileSize,
  Value<DateTime> fileDate,
  Value<DateTime> createdAt,
});

final class $$FilesTableReferences
    extends BaseReferences<_$AppDatabase, $FilesTable, DbFile> {
  $$FilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(
          $_aliasNameGenerator(db.files.participantId, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FilesTableFilterComposer extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileId => $composableBuilder(
      column: $table.fileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fileDate => $composableBuilder(
      column: $table.fileDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FilesTableOrderingComposer
    extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileId => $composableBuilder(
      column: $table.fileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fileDate => $composableBuilder(
      column: $table.fileDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileId =>
      $composableBuilder(column: $table.fileId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get fileDate =>
      $composableBuilder(column: $table.fileDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FilesTable,
    DbFile,
    $$FilesTableFilterComposer,
    $$FilesTableOrderingComposer,
    $$FilesTableAnnotationComposer,
    $$FilesTableCreateCompanionBuilder,
    $$FilesTableUpdateCompanionBuilder,
    (DbFile, $$FilesTableReferences),
    DbFile,
    PrefetchHooks Function({bool participantId})> {
  $$FilesTableTableManager(_$AppDatabase db, $FilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> participantId = const Value.absent(),
            Value<String> fileId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<DateTime> fileDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FilesCompanion(
            id: id,
            participantId: participantId,
            fileId: fileId,
            title: title,
            type: type,
            filePath: filePath,
            source: source,
            fileSize: fileSize,
            fileDate: fileDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int participantId,
            required String fileId,
            required String title,
            Value<String> type = const Value.absent(),
            required String filePath,
            required String source,
            Value<int?> fileSize = const Value.absent(),
            required DateTime fileDate,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FilesCompanion.insert(
            id: id,
            participantId: participantId,
            fileId: fileId,
            title: title,
            type: type,
            filePath: filePath,
            source: source,
            fileSize: fileSize,
            fileDate: fileDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable:
                        $$FilesTableReferences._participantIdTable(db),
                    referencedColumn:
                        $$FilesTableReferences._participantIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FilesTable,
    DbFile,
    $$FilesTableFilterComposer,
    $$FilesTableOrderingComposer,
    $$FilesTableAnnotationComposer,
    $$FilesTableCreateCompanionBuilder,
    $$FilesTableUpdateCompanionBuilder,
    (DbFile, $$FilesTableReferences),
    DbFile,
    PrefetchHooks Function({bool participantId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$HealthEventsTableTableManager get healthEvents =>
      $$HealthEventsTableTableManager(_db, _db.healthEvents);
  $$MetricsTableTableManager get metrics =>
      $$MetricsTableTableManager(_db, _db.metrics);
  $$MetricDataPointsTableTableManager get metricDataPoints =>
      $$MetricDataPointsTableTableManager(_db, _db.metricDataPoints);
  $$FilesTableTableManager get files =>
      $$FilesTableTableManager(_db, _db.files);
}
