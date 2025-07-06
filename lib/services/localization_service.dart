import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'localization_service.g.dart';

@HiveType(typeId: 6)
class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  final int typeId = 6;

  @override
  Locale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Locale(fields[0] as String, fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.countryCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  late Box<Locale> _localeBox;

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(LocaleAdapter());
    }
    _localeBox = await Hive.openBox<Locale>('locale');
  }

  Locale getLocale() {
    return _localeBox.get('currentLocale') ?? const Locale('de', '');
  }

  Future<void> setLocale(Locale locale) async {
    await _localeBox.put('currentLocale', locale);
  }
}
