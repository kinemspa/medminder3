// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<double> strength = GeneratedColumn<double>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthUnitMeta = const VerificationMeta(
    'strengthUnit',
  );
  @override
  late final GeneratedColumn<String> strengthUnit = GeneratedColumn<String>(
    'strength_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeUnitMeta = const VerificationMeta(
    'volumeUnit',
  );
  @override
  late final GeneratedColumn<String> volumeUnit = GeneratedColumn<String>(
    'volume_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceDoseMeta = const VerificationMeta(
    'referenceDose',
  );
  @override
  late final GeneratedColumn<String> referenceDose = GeneratedColumn<String>(
    'reference_dose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    strength,
    strengthUnit,
    quantity,
    volumeUnit,
    referenceDose,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    } else if (isInserting) {
      context.missing(_strengthMeta);
    }
    if (data.containsKey('strength_unit')) {
      context.handle(
        _strengthUnitMeta,
        strengthUnit.isAcceptableOrUnknown(
          data['strength_unit']!,
          _strengthUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strengthUnitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('volume_unit')) {
      context.handle(
        _volumeUnitMeta,
        volumeUnit.isAcceptableOrUnknown(data['volume_unit']!, _volumeUnitMeta),
      );
    }
    if (data.containsKey('reference_dose')) {
      context.handle(
        _referenceDoseMeta,
        referenceDose.isAcceptableOrUnknown(
          data['reference_dose']!,
          _referenceDoseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strength'],
      )!,
      strengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength_unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      volumeUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_unit'],
      ),
      referenceDose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_dose'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String name;
  final String type;
  final double strength;
  final String strengthUnit;
  final double quantity;
  final String? volumeUnit;
  final String? referenceDose;
  const Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.strength,
    required this.strengthUnit,
    required this.quantity,
    this.volumeUnit,
    this.referenceDose,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['strength'] = Variable<double>(strength);
    map['strength_unit'] = Variable<String>(strengthUnit);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || volumeUnit != null) {
      map['volume_unit'] = Variable<String>(volumeUnit);
    }
    if (!nullToAbsent || referenceDose != null) {
      map['reference_dose'] = Variable<String>(referenceDose);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      strength: Value(strength),
      strengthUnit: Value(strengthUnit),
      quantity: Value(quantity),
      volumeUnit: volumeUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeUnit),
      referenceDose: referenceDose == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceDose),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      strength: serializer.fromJson<double>(json['strength']),
      strengthUnit: serializer.fromJson<String>(json['strengthUnit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      volumeUnit: serializer.fromJson<String?>(json['volumeUnit']),
      referenceDose: serializer.fromJson<String?>(json['referenceDose']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'strength': serializer.toJson<double>(strength),
      'strengthUnit': serializer.toJson<String>(strengthUnit),
      'quantity': serializer.toJson<double>(quantity),
      'volumeUnit': serializer.toJson<String?>(volumeUnit),
      'referenceDose': serializer.toJson<String?>(referenceDose),
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    String? type,
    double? strength,
    String? strengthUnit,
    double? quantity,
    Value<String?> volumeUnit = const Value.absent(),
    Value<String?> referenceDose = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    strength: strength ?? this.strength,
    strengthUnit: strengthUnit ?? this.strengthUnit,
    quantity: quantity ?? this.quantity,
    volumeUnit: volumeUnit.present ? volumeUnit.value : this.volumeUnit,
    referenceDose: referenceDose.present
        ? referenceDose.value
        : this.referenceDose,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      strength: data.strength.present ? data.strength.value : this.strength,
      strengthUnit: data.strengthUnit.present
          ? data.strengthUnit.value
          : this.strengthUnit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      volumeUnit: data.volumeUnit.present
          ? data.volumeUnit.value
          : this.volumeUnit,
      referenceDose: data.referenceDose.present
          ? data.referenceDose.value
          : this.referenceDose,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('strength: $strength, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('quantity: $quantity, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('referenceDose: $referenceDose')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    strength,
    strengthUnit,
    quantity,
    volumeUnit,
    referenceDose,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.strength == this.strength &&
          other.strengthUnit == this.strengthUnit &&
          other.quantity == this.quantity &&
          other.volumeUnit == this.volumeUnit &&
          other.referenceDose == this.referenceDose);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> strength;
  final Value<String> strengthUnit;
  final Value<double> quantity;
  final Value<String?> volumeUnit;
  final Value<String?> referenceDose;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.strength = const Value.absent(),
    this.strengthUnit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.volumeUnit = const Value.absent(),
    this.referenceDose = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required double strength,
    required String strengthUnit,
    required double quantity,
    this.volumeUnit = const Value.absent(),
    this.referenceDose = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       strength = Value(strength),
       strengthUnit = Value(strengthUnit),
       quantity = Value(quantity);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? strength,
    Expression<String>? strengthUnit,
    Expression<double>? quantity,
    Expression<String>? volumeUnit,
    Expression<String>? referenceDose,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (strength != null) 'strength': strength,
      if (strengthUnit != null) 'strength_unit': strengthUnit,
      if (quantity != null) 'quantity': quantity,
      if (volumeUnit != null) 'volume_unit': volumeUnit,
      if (referenceDose != null) 'reference_dose': referenceDose,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? strength,
    Value<String>? strengthUnit,
    Value<double>? quantity,
    Value<String?>? volumeUnit,
    Value<String?>? referenceDose,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      quantity: quantity ?? this.quantity,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      referenceDose: referenceDose ?? this.referenceDose,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (strength.present) {
      map['strength'] = Variable<double>(strength.value);
    }
    if (strengthUnit.present) {
      map['strength_unit'] = Variable<String>(strengthUnit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (volumeUnit.present) {
      map['volume_unit'] = Variable<String>(volumeUnit.value);
    }
    if (referenceDose.present) {
      map['reference_dose'] = Variable<String>(referenceDose.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('strength: $strength, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('quantity: $quantity, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('referenceDose: $referenceDose')
          ..write(')'))
        .toString();
  }
}

class $DosesTable extends Doses with TableInfo<$DosesTable, Dose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<double> strength = GeneratedColumn<double>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthUnitMeta = const VerificationMeta(
    'strengthUnit',
  );
  @override
  late final GeneratedColumn<String> strengthUnit = GeneratedColumn<String>(
    'strength_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeUnitMeta = const VerificationMeta(
    'volumeUnit',
  );
  @override
  late final GeneratedColumn<String> volumeUnit = GeneratedColumn<String>(
    'volume_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    name,
    strength,
    strengthUnit,
    volume,
    volumeUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    } else if (isInserting) {
      context.missing(_strengthMeta);
    }
    if (data.containsKey('strength_unit')) {
      context.handle(
        _strengthUnitMeta,
        strengthUnit.isAcceptableOrUnknown(
          data['strength_unit']!,
          _strengthUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strengthUnitMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('volume_unit')) {
      context.handle(
        _volumeUnitMeta,
        volumeUnit.isAcceptableOrUnknown(data['volume_unit']!, _volumeUnitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strength'],
      )!,
      strengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength_unit'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      ),
      volumeUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_unit'],
      ),
    );
  }

  @override
  $DosesTable createAlias(String alias) {
    return $DosesTable(attachedDatabase, alias);
  }
}

class Dose extends DataClass implements Insertable<Dose> {
  final int id;
  final int medicationId;
  final String name;
  final double strength;
  final String strengthUnit;
  final double? volume;
  final String? volumeUnit;
  const Dose({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.strength,
    required this.strengthUnit,
    this.volume,
    this.volumeUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['name'] = Variable<String>(name);
    map['strength'] = Variable<double>(strength);
    map['strength_unit'] = Variable<String>(strengthUnit);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    if (!nullToAbsent || volumeUnit != null) {
      map['volume_unit'] = Variable<String>(volumeUnit);
    }
    return map;
  }

  DosesCompanion toCompanion(bool nullToAbsent) {
    return DosesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      name: Value(name),
      strength: Value(strength),
      strengthUnit: Value(strengthUnit),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      volumeUnit: volumeUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeUnit),
    );
  }

  factory Dose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dose(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      name: serializer.fromJson<String>(json['name']),
      strength: serializer.fromJson<double>(json['strength']),
      strengthUnit: serializer.fromJson<String>(json['strengthUnit']),
      volume: serializer.fromJson<double?>(json['volume']),
      volumeUnit: serializer.fromJson<String?>(json['volumeUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'name': serializer.toJson<String>(name),
      'strength': serializer.toJson<double>(strength),
      'strengthUnit': serializer.toJson<String>(strengthUnit),
      'volume': serializer.toJson<double?>(volume),
      'volumeUnit': serializer.toJson<String?>(volumeUnit),
    };
  }

  Dose copyWith({
    int? id,
    int? medicationId,
    String? name,
    double? strength,
    String? strengthUnit,
    Value<double?> volume = const Value.absent(),
    Value<String?> volumeUnit = const Value.absent(),
  }) => Dose(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    name: name ?? this.name,
    strength: strength ?? this.strength,
    strengthUnit: strengthUnit ?? this.strengthUnit,
    volume: volume.present ? volume.value : this.volume,
    volumeUnit: volumeUnit.present ? volumeUnit.value : this.volumeUnit,
  );
  Dose copyWithCompanion(DosesCompanion data) {
    return Dose(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      name: data.name.present ? data.name.value : this.name,
      strength: data.strength.present ? data.strength.value : this.strength,
      strengthUnit: data.strengthUnit.present
          ? data.strengthUnit.value
          : this.strengthUnit,
      volume: data.volume.present ? data.volume.value : this.volume,
      volumeUnit: data.volumeUnit.present
          ? data.volumeUnit.value
          : this.volumeUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dose(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('name: $name, ')
          ..write('strength: $strength, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('volume: $volume, ')
          ..write('volumeUnit: $volumeUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    name,
    strength,
    strengthUnit,
    volume,
    volumeUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dose &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.name == this.name &&
          other.strength == this.strength &&
          other.strengthUnit == this.strengthUnit &&
          other.volume == this.volume &&
          other.volumeUnit == this.volumeUnit);
}

class DosesCompanion extends UpdateCompanion<Dose> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<String> name;
  final Value<double> strength;
  final Value<String> strengthUnit;
  final Value<double?> volume;
  final Value<String?> volumeUnit;
  const DosesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.name = const Value.absent(),
    this.strength = const Value.absent(),
    this.strengthUnit = const Value.absent(),
    this.volume = const Value.absent(),
    this.volumeUnit = const Value.absent(),
  });
  DosesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required String name,
    required double strength,
    required String strengthUnit,
    this.volume = const Value.absent(),
    this.volumeUnit = const Value.absent(),
  }) : medicationId = Value(medicationId),
       name = Value(name),
       strength = Value(strength),
       strengthUnit = Value(strengthUnit);
  static Insertable<Dose> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<String>? name,
    Expression<double>? strength,
    Expression<String>? strengthUnit,
    Expression<double>? volume,
    Expression<String>? volumeUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (name != null) 'name': name,
      if (strength != null) 'strength': strength,
      if (strengthUnit != null) 'strength_unit': strengthUnit,
      if (volume != null) 'volume': volume,
      if (volumeUnit != null) 'volume_unit': volumeUnit,
    });
  }

  DosesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<String>? name,
    Value<double>? strength,
    Value<String>? strengthUnit,
    Value<double?>? volume,
    Value<String?>? volumeUnit,
  }) {
    return DosesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      strength: strength ?? this.strength,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      volume: volume ?? this.volume,
      volumeUnit: volumeUnit ?? this.volumeUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (strength.present) {
      map['strength'] = Variable<double>(strength.value);
    }
    if (strengthUnit.present) {
      map['strength_unit'] = Variable<String>(strengthUnit.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (volumeUnit.present) {
      map['volume_unit'] = Variable<String>(volumeUnit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DosesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('name: $name, ')
          ..write('strength: $strength, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('volume: $volume, ')
          ..write('volumeUnit: $volumeUnit')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _doseIdMeta = const VerificationMeta('doseId');
  @override
  late final GeneratedColumn<int> doseId = GeneratedColumn<int>(
    'dose_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES doses (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesMeta = const VerificationMeta('times');
  @override
  late final GeneratedColumn<String> times = GeneratedColumn<String>(
    'times',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, doseId, name, frequency, times];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dose_id')) {
      context.handle(
        _doseIdMeta,
        doseId.isAcceptableOrUnknown(data['dose_id']!, _doseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('times')) {
      context.handle(
        _timesMeta,
        times.isAcceptableOrUnknown(data['times']!, _timesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      doseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      times: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times'],
      ),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final int doseId;
  final String name;
  final String frequency;
  final String? times;
  const Schedule({
    required this.id,
    required this.doseId,
    required this.name,
    required this.frequency,
    this.times,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dose_id'] = Variable<int>(doseId);
    map['name'] = Variable<String>(name);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || times != null) {
      map['times'] = Variable<String>(times);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      doseId: Value(doseId),
      name: Value(name),
      frequency: Value(frequency),
      times: times == null && nullToAbsent
          ? const Value.absent()
          : Value(times),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      doseId: serializer.fromJson<int>(json['doseId']),
      name: serializer.fromJson<String>(json['name']),
      frequency: serializer.fromJson<String>(json['frequency']),
      times: serializer.fromJson<String?>(json['times']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'doseId': serializer.toJson<int>(doseId),
      'name': serializer.toJson<String>(name),
      'frequency': serializer.toJson<String>(frequency),
      'times': serializer.toJson<String?>(times),
    };
  }

  Schedule copyWith({
    int? id,
    int? doseId,
    String? name,
    String? frequency,
    Value<String?> times = const Value.absent(),
  }) => Schedule(
    id: id ?? this.id,
    doseId: doseId ?? this.doseId,
    name: name ?? this.name,
    frequency: frequency ?? this.frequency,
    times: times.present ? times.value : this.times,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      doseId: data.doseId.present ? data.doseId.value : this.doseId,
      name: data.name.present ? data.name.value : this.name,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      times: data.times.present ? data.times.value : this.times,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('name: $name, ')
          ..write('frequency: $frequency, ')
          ..write('times: $times')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, doseId, name, frequency, times);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.doseId == this.doseId &&
          other.name == this.name &&
          other.frequency == this.frequency &&
          other.times == this.times);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<int> doseId;
  final Value<String> name;
  final Value<String> frequency;
  final Value<String?> times;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.doseId = const Value.absent(),
    this.name = const Value.absent(),
    this.frequency = const Value.absent(),
    this.times = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int doseId,
    required String name,
    required String frequency,
    this.times = const Value.absent(),
  }) : doseId = Value(doseId),
       name = Value(name),
       frequency = Value(frequency);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<int>? doseId,
    Expression<String>? name,
    Expression<String>? frequency,
    Expression<String>? times,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseId != null) 'dose_id': doseId,
      if (name != null) 'name': name,
      if (frequency != null) 'frequency': frequency,
      if (times != null) 'times': times,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? doseId,
    Value<String>? name,
    Value<String>? frequency,
    Value<String?>? times,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      doseId: doseId ?? this.doseId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (doseId.present) {
      map['dose_id'] = Variable<int>(doseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(times.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('name: $name, ')
          ..write('frequency: $frequency, ')
          ..write('times: $times')
          ..write(')'))
        .toString();
  }
}

class $SuppliesTable extends Supplies with TableInfo<$SuppliesTable, Supply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, quantity, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supply> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supply(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $SuppliesTable createAlias(String alias) {
    return $SuppliesTable(attachedDatabase, alias);
  }
}

class Supply extends DataClass implements Insertable<Supply> {
  final int id;
  final String name;
  final double quantity;
  final String unit;
  const Supply({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  SuppliesCompanion toCompanion(bool nullToAbsent) {
    return SuppliesCompanion(
      id: Value(id),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
    );
  }

  factory Supply.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supply(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
    };
  }

  Supply copyWith({int? id, String? name, double? quantity, String? unit}) =>
      Supply(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );
  Supply copyWithCompanion(SuppliesCompanion data) {
    return Supply(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supply(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, quantity, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supply &&
          other.id == this.id &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit);
}

class SuppliesCompanion extends UpdateCompanion<Supply> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> quantity;
  final Value<String> unit;
  const SuppliesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
  });
  SuppliesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double quantity,
    required String unit,
  }) : name = Value(name),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<Supply> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
    });
  }

  SuppliesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? quantity,
    Value<String>? unit,
  }) {
    return SuppliesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
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
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $DosesTable doses = $DosesTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $SuppliesTable supplies = $SuppliesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medications,
    doses,
    schedules,
    supplies,
  ];
}

typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required double strength,
      required String strengthUnit,
      required double quantity,
      Value<String?> volumeUnit,
      Value<String?> referenceDose,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<double> strength,
      Value<String> strengthUnit,
      Value<double> quantity,
      Value<String?> volumeUnit,
      Value<String?> referenceDose,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DosesTable, List<Dose>> _dosesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.doses,
    aliasName: $_aliasNameGenerator(db.medications.id, db.doses.medicationId),
  );

  $$DosesTableProcessedTableManager get dosesRefs {
    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceDose => $composableBuilder(
    column: $table.referenceDose,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dosesRefs(
    Expression<bool> Function($$DosesTableFilterComposer f) f,
  ) {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceDose => $composableBuilder(
    column: $table.referenceDose,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceDose => $composableBuilder(
    column: $table.referenceDose,
    builder: (column) => column,
  );

  Expression<T> dosesRefs<T extends Object>(
    Expression<T> Function($$DosesTableAnnotationComposer a) f,
  ) {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool dosesRefs})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> strength = const Value.absent(),
                Value<String> strengthUnit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> volumeUnit = const Value.absent(),
                Value<String?> referenceDose = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                type: type,
                strength: strength,
                strengthUnit: strengthUnit,
                quantity: quantity,
                volumeUnit: volumeUnit,
                referenceDose: referenceDose,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required double strength,
                required String strengthUnit,
                required double quantity,
                Value<String?> volumeUnit = const Value.absent(),
                Value<String?> referenceDose = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                type: type,
                strength: strength,
                strengthUnit: strengthUnit,
                quantity: quantity,
                volumeUnit: volumeUnit,
                referenceDose: referenceDose,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dosesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dosesRefs) db.doses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dosesRefs)
                    await $_getPrefetchedData<
                      Medication,
                      $MedicationsTable,
                      Dose
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._dosesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicationsTableReferences(db, table, p0).dosesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.medicationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool dosesRefs})
    >;
typedef $$DosesTableCreateCompanionBuilder =
    DosesCompanion Function({
      Value<int> id,
      required int medicationId,
      required String name,
      required double strength,
      required String strengthUnit,
      Value<double?> volume,
      Value<String?> volumeUnit,
    });
typedef $$DosesTableUpdateCompanionBuilder =
    DosesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<String> name,
      Value<double> strength,
      Value<String> strengthUnit,
      Value<double?> volume,
      Value<String?> volumeUnit,
    });

final class $$DosesTableReferences
    extends BaseReferences<_$AppDatabase, $DosesTable, Dose> {
  $$DosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.doses.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
  _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schedules,
    aliasName: $_aliasNameGenerator(db.doses.id, db.schedules.doseId),
  );

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.doseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DosesTableFilterComposer extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> schedulesRefs(
    Expression<bool> Function($$SchedulesTableFilterComposer f) f,
  ) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableAnnotationComposer({
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

  GeneratedColumn<double> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> schedulesRefs<T extends Object>(
    Expression<T> Function($$SchedulesTableAnnotationComposer a) f,
  ) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DosesTable,
          Dose,
          $$DosesTableFilterComposer,
          $$DosesTableOrderingComposer,
          $$DosesTableAnnotationComposer,
          $$DosesTableCreateCompanionBuilder,
          $$DosesTableUpdateCompanionBuilder,
          (Dose, $$DosesTableReferences),
          Dose,
          PrefetchHooks Function({bool medicationId, bool schedulesRefs})
        > {
  $$DosesTableTableManager(_$AppDatabase db, $DosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> strength = const Value.absent(),
                Value<String> strengthUnit = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<String?> volumeUnit = const Value.absent(),
              }) => DosesCompanion(
                id: id,
                medicationId: medicationId,
                name: name,
                strength: strength,
                strengthUnit: strengthUnit,
                volume: volume,
                volumeUnit: volumeUnit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required String name,
                required double strength,
                required String strengthUnit,
                Value<double?> volume = const Value.absent(),
                Value<String?> volumeUnit = const Value.absent(),
              }) => DosesCompanion.insert(
                id: id,
                medicationId: medicationId,
                name: name,
                strength: strength,
                strengthUnit: strengthUnit,
                volume: volume,
                volumeUnit: volumeUnit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DosesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicationId = false, schedulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (schedulesRefs) db.schedules],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (medicationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicationId,
                                    referencedTable: $$DosesTableReferences
                                        ._medicationIdTable(db),
                                    referencedColumn: $$DosesTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (schedulesRefs)
                        await $_getPrefetchedData<Dose, $DosesTable, Schedule>(
                          currentTable: table,
                          referencedTable: $$DosesTableReferences
                              ._schedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DosesTableReferences(
                                db,
                                table,
                                p0,
                              ).schedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.doseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DosesTable,
      Dose,
      $$DosesTableFilterComposer,
      $$DosesTableOrderingComposer,
      $$DosesTableAnnotationComposer,
      $$DosesTableCreateCompanionBuilder,
      $$DosesTableUpdateCompanionBuilder,
      (Dose, $$DosesTableReferences),
      Dose,
      PrefetchHooks Function({bool medicationId, bool schedulesRefs})
    >;
typedef $$SchedulesTableCreateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      required int doseId,
      required String name,
      required String frequency,
      Value<String?> times,
    });
typedef $$SchedulesTableUpdateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<int> doseId,
      Value<String> name,
      Value<String> frequency,
      Value<String?> times,
    });

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DosesTable _doseIdTable(_$AppDatabase db) => db.doses.createAlias(
    $_aliasNameGenerator(db.schedules.doseId, db.doses.id),
  );

  $$DosesTableProcessedTableManager get doseId {
    final $_column = $_itemColumn<int>('dose_id')!;

    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnFilters(column),
  );

  $$DosesTableFilterComposer get doseId {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  $$DosesTableOrderingComposer get doseId {
    final $$DosesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableOrderingComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
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

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  $$DosesTableAnnotationComposer get doseId {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, $$SchedulesTableReferences),
          Schedule,
          PrefetchHooks Function({bool doseId})
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> doseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> times = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                doseId: doseId,
                name: name,
                frequency: frequency,
                times: times,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int doseId,
                required String name,
                required String frequency,
                Value<String?> times = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                doseId: doseId,
                name: name,
                frequency: frequency,
                times: times,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({doseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (doseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.doseId,
                                referencedTable: $$SchedulesTableReferences
                                    ._doseIdTable(db),
                                referencedColumn: $$SchedulesTableReferences
                                    ._doseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, $$SchedulesTableReferences),
      Schedule,
      PrefetchHooks Function({bool doseId})
    >;
typedef $$SuppliesTableCreateCompanionBuilder =
    SuppliesCompanion Function({
      Value<int> id,
      required String name,
      required double quantity,
      required String unit,
    });
typedef $$SuppliesTableUpdateCompanionBuilder =
    SuppliesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> quantity,
      Value<String> unit,
    });

class $$SuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableAnnotationComposer({
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

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);
}

class $$SuppliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliesTable,
          Supply,
          $$SuppliesTableFilterComposer,
          $$SuppliesTableOrderingComposer,
          $$SuppliesTableAnnotationComposer,
          $$SuppliesTableCreateCompanionBuilder,
          $$SuppliesTableUpdateCompanionBuilder,
          (Supply, BaseReferences<_$AppDatabase, $SuppliesTable, Supply>),
          Supply,
          PrefetchHooks Function()
        > {
  $$SuppliesTableTableManager(_$AppDatabase db, $SuppliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
              }) => SuppliesCompanion(
                id: id,
                name: name,
                quantity: quantity,
                unit: unit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double quantity,
                required String unit,
              }) => SuppliesCompanion.insert(
                id: id,
                name: name,
                quantity: quantity,
                unit: unit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliesTable,
      Supply,
      $$SuppliesTableFilterComposer,
      $$SuppliesTableOrderingComposer,
      $$SuppliesTableAnnotationComposer,
      $$SuppliesTableCreateCompanionBuilder,
      $$SuppliesTableUpdateCompanionBuilder,
      (Supply, BaseReferences<_$AppDatabase, $SuppliesTable, Supply>),
      Supply,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$DosesTableTableManager get doses =>
      $$DosesTableTableManager(_db, _db.doses);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$SuppliesTableTableManager get supplies =>
      $$SuppliesTableTableManager(_db, _db.supplies);
}
