import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

part 'settings_state.g.dart';

abstract class SettingsState
    implements Built<SettingsState, SettingsStateBuilder> {
  static Serializer<SettingsState> get serializer => _$settingsStateSerializer;

  SettingsState._();
  factory SettingsState([void Function(SettingsStateBuilder) updates]) =
      _$SettingsState;

  @BuiltValueField(serialize: false)
  SettingsStateEnum? get state;

  @BuiltValueField(wireName: 'current_alias')
  String get currentAlias;

  @BuiltValueField(wireName: 'is_light_mode')
  bool get isLightMode;

  @BuiltValueField(wireName: 'refresh_seconds')
  int get refreshSeconds;

  BuiltMap<String, SettingsStateConnection> get connections;

  factory SettingsState.init() => SettingsState((b) => b
    ..currentAlias = ""
    ..isLightMode = false // Dark mode by default
    ..refreshSeconds = 60 // 1 minute
    ..state = SettingsStateEnum.uninitialized);
}

class SettingsStateEnum extends EnumClass {
  static const SettingsStateEnum uninitialized = _$uninitialized;
  static const SettingsStateEnum noConnection = _$noConnection;
  static const SettingsStateEnum clientConnected = _$clientConnected;
  static const SettingsStateEnum clientUpdated = _$clientUpdated;
  static const SettingsStateEnum clientFailed = _$clientFailed;
  static const SettingsStateEnum clientDeleted = _$clientDeleted;
  static const SettingsStateEnum connected = _$connected;
  static const SettingsStateEnum failed = _$failed;
  static const SettingsStateEnum updatedRefreshSeconds =
      _$updatedRefreshSeconds;

  const SettingsStateEnum._(super.name);

  static BuiltSet<SettingsStateEnum> get values => _$values;
  static SettingsStateEnum valueOf(String name) => _$valueOf(name);
}

abstract class SettingsStateConnection
    implements Built<SettingsStateConnection, SettingsStateConnectionBuilder> {
  static Serializer<SettingsStateConnection> get serializer =>
      _$settingsStateConnectionSerializer;

  @BuiltValueField(
    serialize: false,
  )
  SettingsConnectionStateEnum? get state;

  @BuiltValueField(serialize: false)
  cmk_api.Client? get client;

  @BuiltValueField(serialize: false)
  cmk_api.NetworkError? get error;

  @BuiltValueField(wireName: 'base_url')
  String get baseUrl;

  String get site;

  String get username;

  String get secret;

  bool get notifications;

  @BuiltValueField(wireName: 'validate_ssl')
  bool get validateSsl;

  BuiltMap<String, bool>? get filters;

  factory SettingsStateConnection(
          [void Function(SettingsStateConnectionBuilder) updates]) =
      _$SettingsStateConnection;

  SettingsStateConnection._();

  factory SettingsStateConnection.init(
          {required SettingsConnectionStateEnum state,
          required String baseUrl,
          required String site,
          required String username,
          required String secret,
          bool notifications = true,
          bool validateSsl = true,
          String currentAlias = "",
          Map<String, bool> filters = const {},
          cmk_api.Client? client}) =>
      SettingsStateConnection((b) => b
        ..state = state
        ..baseUrl = baseUrl
        ..site = site
        ..username = username
        ..secret = secret
        ..notifications = notifications
        ..validateSsl = validateSsl
        ..filters = BuiltMap<String, bool>.from(filters).toBuilder()
        ..client = client);
}

class SettingsConnectionStateEnum extends EnumClass {
  static const SettingsConnectionStateEnum uninitialized = _$connUninitialized;
  static const SettingsConnectionStateEnum connected = _$connConnected;
  static const SettingsConnectionStateEnum failed = _$connFailed;

  const SettingsConnectionStateEnum._(super.name);

  static BuiltSet<SettingsConnectionStateEnum> get values => _$connValues;
  static SettingsConnectionStateEnum valueOf(String name) =>
      _$connValueOf(name);
}
