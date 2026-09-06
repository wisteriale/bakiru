// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TrashItemsTable extends TrashItems
    with TableInfo<$TrashItemsTable, TrashItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrashItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrashItemType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrashItemType>($TrashItemsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purgeAtMeta = const VerificationMeta(
    'purgeAt',
  );
  @override
  late final GeneratedColumn<DateTime> purgeAt = GeneratedColumn<DateTime>(
    'purge_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    thumbnailPath,
    addedAt,
    purgeAt,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trash_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrashItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('purge_at')) {
      context.handle(
        _purgeAtMeta,
        purgeAt.isAcceptableOrUnknown(data['purge_at']!, _purgeAtMeta),
      );
    } else if (isInserting) {
      context.missing(_purgeAtMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrashItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrashItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $TrashItemsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      purgeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purge_at'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $TrashItemsTable createAlias(String alias) {
    return $TrashItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrashItemType, String, String> $convertertype =
      const EnumNameConverter<TrashItemType>(TrashItemType.values);
}

class TrashItemRow extends DataClass implements Insertable<TrashItemRow> {
  /// 一意な ID（uuid 文字列）。
  final String id;

  /// 種別。enum の名前（'photo' など）を文字列で保存する。
  ///
  /// index（整数）ではなく名前で保存するのは、あとで enum の並び順を
  /// 入れ替えても既存データが壊れないようにするため。
  final TrashItemType type;

  /// 一覧に表示する名前。
  final String title;

  /// サムネイル画像のパス。持たない種別もあるので null 可。
  final String? thumbnailPath;

  /// ごみ箱に入れた日時。
  final DateTime addedAt;

  /// 完全消去する予定の日時。
  final DateTime purgeAt;

  /// 種別ごとの追加情報を JSON 文字列にしたもの。
  ///
  /// Map のままでは保存できないので、repository で jsonEncode して入れ、
  /// 読むときに jsonDecode して [TrashItem.payload] に戻す。
  final String payloadJson;
  const TrashItemRow({
    required this.id,
    required this.type,
    required this.title,
    this.thumbnailPath,
    required this.addedAt,
    required this.purgeAt,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>(
        $TrashItemsTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['purge_at'] = Variable<DateTime>(purgeAt);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  TrashItemsCompanion toCompanion(bool nullToAbsent) {
    return TrashItemsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      addedAt: Value(addedAt),
      purgeAt: Value(purgeAt),
      payloadJson: Value(payloadJson),
    );
  }

  factory TrashItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrashItemRow(
      id: serializer.fromJson<String>(json['id']),
      type: $TrashItemsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      purgeAt: serializer.fromJson<DateTime>(json['purgeAt']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $TrashItemsTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'purgeAt': serializer.toJson<DateTime>(purgeAt),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  TrashItemRow copyWith({
    String? id,
    TrashItemType? type,
    String? title,
    Value<String?> thumbnailPath = const Value.absent(),
    DateTime? addedAt,
    DateTime? purgeAt,
    String? payloadJson,
  }) => TrashItemRow(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    addedAt: addedAt ?? this.addedAt,
    purgeAt: purgeAt ?? this.purgeAt,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  TrashItemRow copyWithCompanion(TrashItemsCompanion data) {
    return TrashItemRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      purgeAt: data.purgeAt.present ? data.purgeAt.value : this.purgeAt,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrashItemRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('purgeAt: $purgeAt, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    thumbnailPath,
    addedAt,
    purgeAt,
    payloadJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrashItemRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.thumbnailPath == this.thumbnailPath &&
          other.addedAt == this.addedAt &&
          other.purgeAt == this.purgeAt &&
          other.payloadJson == this.payloadJson);
}

class TrashItemsCompanion extends UpdateCompanion<TrashItemRow> {
  final Value<String> id;
  final Value<TrashItemType> type;
  final Value<String> title;
  final Value<String?> thumbnailPath;
  final Value<DateTime> addedAt;
  final Value<DateTime> purgeAt;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const TrashItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.purgeAt = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrashItemsCompanion.insert({
    required String id,
    required TrashItemType type,
    required String title,
    this.thumbnailPath = const Value.absent(),
    required DateTime addedAt,
    required DateTime purgeAt,
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       addedAt = Value(addedAt),
       purgeAt = Value(purgeAt);
  static Insertable<TrashItemRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? thumbnailPath,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? purgeAt,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (addedAt != null) 'added_at': addedAt,
      if (purgeAt != null) 'purge_at': purgeAt,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrashItemsCompanion copyWith({
    Value<String>? id,
    Value<TrashItemType>? type,
    Value<String>? title,
    Value<String?>? thumbnailPath,
    Value<DateTime>? addedAt,
    Value<DateTime>? purgeAt,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return TrashItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      addedAt: addedAt ?? this.addedAt,
      purgeAt: purgeAt ?? this.purgeAt,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TrashItemsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (purgeAt.present) {
      map['purge_at'] = Variable<DateTime>(purgeAt.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrashItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('purgeAt: $purgeAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpitaphsTable extends Epitaphs
    with TableInfo<$EpitaphsTable, EpitaphRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpitaphsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrashItemType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrashItemType>($EpitaphsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destroyedAtMeta = const VerificationMeta(
    'destroyedAt',
  );
  @override
  late final GeneratedColumn<DateTime> destroyedAt = GeneratedColumn<DateTime>(
    'destroyed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DestroyMethod, String>
  destroyMethod = GeneratedColumn<String>(
    'destroy_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DestroyMethod>($EpitaphsTable.$converterdestroyMethod);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    message,
    type,
    title,
    destroyedAt,
    destroyMethod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epitaphs';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpitaphRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('destroyed_at')) {
      context.handle(
        _destroyedAtMeta,
        destroyedAt.isAcceptableOrUnknown(
          data['destroyed_at']!,
          _destroyedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destroyedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EpitaphRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpitaphRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      type: $EpitaphsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      destroyedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}destroyed_at'],
      )!,
      destroyMethod: $EpitaphsTable.$converterdestroyMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destroy_method'],
        )!,
      ),
    );
  }

  @override
  $EpitaphsTable createAlias(String alias) {
    return $EpitaphsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrashItemType, String, String> $convertertype =
      const EnumNameConverter<TrashItemType>(TrashItemType.values);
  static JsonTypeConverter2<DestroyMethod, String, String>
  $converterdestroyMethod = const EnumNameConverter<DestroyMethod>(
    DestroyMethod.values,
  );
}

class EpitaphRow extends DataClass implements Insertable<EpitaphRow> {
  /// 一意な ID（uuid 文字列）。
  final String id;

  /// ユーザーが残した言葉。
  ///
  /// Dart 側の名前を message にしているのは、Table が持つ text() という
  /// メソッドと同じ名前の getter を定義できないため。
  /// ドメイン型 Epitaph 側では text という名前のまま扱う。
  final String message;

  /// 何を捨てたときのものか。
  final TrashItemType type;

  /// 捨てたものの表示名。中身ではなく名前だけ。
  final String title;

  /// 破壊した日時。
  final DateTime destroyedAt;

  /// どの演出で壊したか。
  final DestroyMethod destroyMethod;
  const EpitaphRow({
    required this.id,
    required this.message,
    required this.type,
    required this.title,
    required this.destroyedAt,
    required this.destroyMethod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message'] = Variable<String>(message);
    {
      map['type'] = Variable<String>($EpitaphsTable.$convertertype.toSql(type));
    }
    map['title'] = Variable<String>(title);
    map['destroyed_at'] = Variable<DateTime>(destroyedAt);
    {
      map['destroy_method'] = Variable<String>(
        $EpitaphsTable.$converterdestroyMethod.toSql(destroyMethod),
      );
    }
    return map;
  }

  EpitaphsCompanion toCompanion(bool nullToAbsent) {
    return EpitaphsCompanion(
      id: Value(id),
      message: Value(message),
      type: Value(type),
      title: Value(title),
      destroyedAt: Value(destroyedAt),
      destroyMethod: Value(destroyMethod),
    );
  }

  factory EpitaphRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpitaphRow(
      id: serializer.fromJson<String>(json['id']),
      message: serializer.fromJson<String>(json['message']),
      type: $EpitaphsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      destroyedAt: serializer.fromJson<DateTime>(json['destroyedAt']),
      destroyMethod: $EpitaphsTable.$converterdestroyMethod.fromJson(
        serializer.fromJson<String>(json['destroyMethod']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'message': serializer.toJson<String>(message),
      'type': serializer.toJson<String>(
        $EpitaphsTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'destroyedAt': serializer.toJson<DateTime>(destroyedAt),
      'destroyMethod': serializer.toJson<String>(
        $EpitaphsTable.$converterdestroyMethod.toJson(destroyMethod),
      ),
    };
  }

  EpitaphRow copyWith({
    String? id,
    String? message,
    TrashItemType? type,
    String? title,
    DateTime? destroyedAt,
    DestroyMethod? destroyMethod,
  }) => EpitaphRow(
    id: id ?? this.id,
    message: message ?? this.message,
    type: type ?? this.type,
    title: title ?? this.title,
    destroyedAt: destroyedAt ?? this.destroyedAt,
    destroyMethod: destroyMethod ?? this.destroyMethod,
  );
  EpitaphRow copyWithCompanion(EpitaphsCompanion data) {
    return EpitaphRow(
      id: data.id.present ? data.id.value : this.id,
      message: data.message.present ? data.message.value : this.message,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      destroyedAt: data.destroyedAt.present
          ? data.destroyedAt.value
          : this.destroyedAt,
      destroyMethod: data.destroyMethod.present
          ? data.destroyMethod.value
          : this.destroyMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpitaphRow(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('destroyedAt: $destroyedAt, ')
          ..write('destroyMethod: $destroyMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, message, type, title, destroyedAt, destroyMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpitaphRow &&
          other.id == this.id &&
          other.message == this.message &&
          other.type == this.type &&
          other.title == this.title &&
          other.destroyedAt == this.destroyedAt &&
          other.destroyMethod == this.destroyMethod);
}

class EpitaphsCompanion extends UpdateCompanion<EpitaphRow> {
  final Value<String> id;
  final Value<String> message;
  final Value<TrashItemType> type;
  final Value<String> title;
  final Value<DateTime> destroyedAt;
  final Value<DestroyMethod> destroyMethod;
  final Value<int> rowid;
  const EpitaphsCompanion({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.destroyedAt = const Value.absent(),
    this.destroyMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpitaphsCompanion.insert({
    required String id,
    required String message,
    required TrashItemType type,
    required String title,
    required DateTime destroyedAt,
    required DestroyMethod destroyMethod,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       message = Value(message),
       type = Value(type),
       title = Value(title),
       destroyedAt = Value(destroyedAt),
       destroyMethod = Value(destroyMethod);
  static Insertable<EpitaphRow> custom({
    Expression<String>? id,
    Expression<String>? message,
    Expression<String>? type,
    Expression<String>? title,
    Expression<DateTime>? destroyedAt,
    Expression<String>? destroyMethod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (destroyedAt != null) 'destroyed_at': destroyedAt,
      if (destroyMethod != null) 'destroy_method': destroyMethod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpitaphsCompanion copyWith({
    Value<String>? id,
    Value<String>? message,
    Value<TrashItemType>? type,
    Value<String>? title,
    Value<DateTime>? destroyedAt,
    Value<DestroyMethod>? destroyMethod,
    Value<int>? rowid,
  }) {
    return EpitaphsCompanion(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      title: title ?? this.title,
      destroyedAt: destroyedAt ?? this.destroyedAt,
      destroyMethod: destroyMethod ?? this.destroyMethod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $EpitaphsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (destroyedAt.present) {
      map['destroyed_at'] = Variable<DateTime>(destroyedAt.value);
    }
    if (destroyMethod.present) {
      map['destroy_method'] = Variable<String>(
        $EpitaphsTable.$converterdestroyMethod.toSql(destroyMethod.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpitaphsCompanion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('destroyedAt: $destroyedAt, ')
          ..write('destroyMethod: $destroyMethod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrashItemsTable trashItems = $TrashItemsTable(this);
  late final $EpitaphsTable epitaphs = $EpitaphsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [trashItems, epitaphs];
}

typedef $$TrashItemsTableCreateCompanionBuilder =
    TrashItemsCompanion Function({
      required String id,
      required TrashItemType type,
      required String title,
      Value<String?> thumbnailPath,
      required DateTime addedAt,
      required DateTime purgeAt,
      Value<String> payloadJson,
      Value<int> rowid,
    });
typedef $$TrashItemsTableUpdateCompanionBuilder =
    TrashItemsCompanion Function({
      Value<String> id,
      Value<TrashItemType> type,
      Value<String> title,
      Value<String?> thumbnailPath,
      Value<DateTime> addedAt,
      Value<DateTime> purgeAt,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$TrashItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TrashItemsTable> {
  $$TrashItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrashItemType, TrashItemType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purgeAt => $composableBuilder(
    column: $table.purgeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrashItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrashItemsTable> {
  $$TrashItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purgeAt => $composableBuilder(
    column: $table.purgeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrashItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrashItemsTable> {
  $$TrashItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TrashItemType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get purgeAt =>
      $composableBuilder(column: $table.purgeAt, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$TrashItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrashItemsTable,
          TrashItemRow,
          $$TrashItemsTableFilterComposer,
          $$TrashItemsTableOrderingComposer,
          $$TrashItemsTableAnnotationComposer,
          $$TrashItemsTableCreateCompanionBuilder,
          $$TrashItemsTableUpdateCompanionBuilder,
          (
            TrashItemRow,
            BaseReferences<_$AppDatabase, $TrashItemsTable, TrashItemRow>,
          ),
          TrashItemRow,
          PrefetchHooks Function()
        > {
  $$TrashItemsTableTableManager(_$AppDatabase db, $TrashItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrashItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrashItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrashItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<TrashItemType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> purgeAt = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrashItemsCompanion(
                id: id,
                type: type,
                title: title,
                thumbnailPath: thumbnailPath,
                addedAt: addedAt,
                purgeAt: purgeAt,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required TrashItemType type,
                required String title,
                Value<String?> thumbnailPath = const Value.absent(),
                required DateTime addedAt,
                required DateTime purgeAt,
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrashItemsCompanion.insert(
                id: id,
                type: type,
                title: title,
                thumbnailPath: thumbnailPath,
                addedAt: addedAt,
                purgeAt: purgeAt,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrashItemsTable, TrashItemRow>(table),
                  BaseReferences<_$AppDatabase, $TrashItemsTable, TrashItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrashItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrashItemsTable,
      TrashItemRow,
      $$TrashItemsTableFilterComposer,
      $$TrashItemsTableOrderingComposer,
      $$TrashItemsTableAnnotationComposer,
      $$TrashItemsTableCreateCompanionBuilder,
      $$TrashItemsTableUpdateCompanionBuilder,
      (
        TrashItemRow,
        BaseReferences<_$AppDatabase, $TrashItemsTable, TrashItemRow>,
      ),
      TrashItemRow,
      PrefetchHooks Function()
    >;
typedef $$EpitaphsTableCreateCompanionBuilder =
    EpitaphsCompanion Function({
      required String id,
      required String message,
      required TrashItemType type,
      required String title,
      required DateTime destroyedAt,
      required DestroyMethod destroyMethod,
      Value<int> rowid,
    });
typedef $$EpitaphsTableUpdateCompanionBuilder =
    EpitaphsCompanion Function({
      Value<String> id,
      Value<String> message,
      Value<TrashItemType> type,
      Value<String> title,
      Value<DateTime> destroyedAt,
      Value<DestroyMethod> destroyMethod,
      Value<int> rowid,
    });

class $$EpitaphsTableFilterComposer
    extends Composer<_$AppDatabase, $EpitaphsTable> {
  $$EpitaphsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrashItemType, TrashItemType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get destroyedAt => $composableBuilder(
    column: $table.destroyedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DestroyMethod, DestroyMethod, String>
  get destroyMethod => $composableBuilder(
    column: $table.destroyMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$EpitaphsTableOrderingComposer
    extends Composer<_$AppDatabase, $EpitaphsTable> {
  $$EpitaphsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get destroyedAt => $composableBuilder(
    column: $table.destroyedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destroyMethod => $composableBuilder(
    column: $table.destroyMethod,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpitaphsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpitaphsTable> {
  $$EpitaphsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TrashItemType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get destroyedAt => $composableBuilder(
    column: $table.destroyedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DestroyMethod, String> get destroyMethod =>
      $composableBuilder(
        column: $table.destroyMethod,
        builder: (column) => column,
      );
}

class $$EpitaphsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpitaphsTable,
          EpitaphRow,
          $$EpitaphsTableFilterComposer,
          $$EpitaphsTableOrderingComposer,
          $$EpitaphsTableAnnotationComposer,
          $$EpitaphsTableCreateCompanionBuilder,
          $$EpitaphsTableUpdateCompanionBuilder,
          (
            EpitaphRow,
            BaseReferences<_$AppDatabase, $EpitaphsTable, EpitaphRow>,
          ),
          EpitaphRow,
          PrefetchHooks Function()
        > {
  $$EpitaphsTableTableManager(_$AppDatabase db, $EpitaphsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpitaphsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpitaphsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpitaphsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<TrashItemType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> destroyedAt = const Value.absent(),
                Value<DestroyMethod> destroyMethod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpitaphsCompanion(
                id: id,
                message: message,
                type: type,
                title: title,
                destroyedAt: destroyedAt,
                destroyMethod: destroyMethod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String message,
                required TrashItemType type,
                required String title,
                required DateTime destroyedAt,
                required DestroyMethod destroyMethod,
                Value<int> rowid = const Value.absent(),
              }) => EpitaphsCompanion.insert(
                id: id,
                message: message,
                type: type,
                title: title,
                destroyedAt: destroyedAt,
                destroyMethod: destroyMethod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpitaphsTable, EpitaphRow>(table),
                  BaseReferences<_$AppDatabase, $EpitaphsTable, EpitaphRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EpitaphsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpitaphsTable,
      EpitaphRow,
      $$EpitaphsTableFilterComposer,
      $$EpitaphsTableOrderingComposer,
      $$EpitaphsTableAnnotationComposer,
      $$EpitaphsTableCreateCompanionBuilder,
      $$EpitaphsTableUpdateCompanionBuilder,
      (EpitaphRow, BaseReferences<_$AppDatabase, $EpitaphsTable, EpitaphRow>),
      EpitaphRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrashItemsTableTableManager get trashItems =>
      $$TrashItemsTableTableManager(_db, _db.trashItems);
  $$EpitaphsTableTableManager get epitaphs =>
      $$EpitaphsTableTableManager(_db, _db.epitaphs);
}
