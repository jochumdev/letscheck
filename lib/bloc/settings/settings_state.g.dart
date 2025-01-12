// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SettingsStateEnum _$uninitialized =
    const SettingsStateEnum._('uninitialized');
const SettingsStateEnum _$noConnection =
    const SettingsStateEnum._('noConnection');
const SettingsStateEnum _$clientConnected =
    const SettingsStateEnum._('clientConnected');
const SettingsStateEnum _$clientUpdated =
    const SettingsStateEnum._('clientUpdated');
const SettingsStateEnum _$clientFailed =
    const SettingsStateEnum._('clientFailed');
const SettingsStateEnum _$clientDeleted =
    const SettingsStateEnum._('clientDeleted');
const SettingsStateEnum _$connected = const SettingsStateEnum._('connected');
const SettingsStateEnum _$failed = const SettingsStateEnum._('failed');
const SettingsStateEnum _$updatedRefreshSeconds =
    const SettingsStateEnum._('updatedRefreshSeconds');

SettingsStateEnum _$valueOf(String name) {
  switch (name) {
    case 'uninitialized':
      return _$uninitialized;
    case 'noConnection':
      return _$noConnection;
    case 'clientConnected':
      return _$clientConnected;
    case 'clientUpdated':
      return _$clientUpdated;
    case 'clientFailed':
      return _$clientFailed;
    case 'clientDeleted':
      return _$clientDeleted;
    case 'connected':
      return _$connected;
    case 'failed':
      return _$failed;
    case 'updatedRefreshSeconds':
      return _$updatedRefreshSeconds;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<SettingsStateEnum> _$values =
    new BuiltSet<SettingsStateEnum>(const <SettingsStateEnum>[
  _$uninitialized,
  _$noConnection,
  _$clientConnected,
  _$clientUpdated,
  _$clientFailed,
  _$clientDeleted,
  _$connected,
  _$failed,
  _$updatedRefreshSeconds,
]);

const SettingsConnectionStateEnum _$connUninitialized =
    const SettingsConnectionStateEnum._('uninitialized');
const SettingsConnectionStateEnum _$connConnected =
    const SettingsConnectionStateEnum._('connected');
const SettingsConnectionStateEnum _$connFailed =
    const SettingsConnectionStateEnum._('failed');

SettingsConnectionStateEnum _$connValueOf(String name) {
  switch (name) {
    case 'uninitialized':
      return _$connUninitialized;
    case 'connected':
      return _$connConnected;
    case 'failed':
      return _$connFailed;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<SettingsConnectionStateEnum> _$connValues = new BuiltSet<
    SettingsConnectionStateEnum>(const <SettingsConnectionStateEnum>[
  _$connUninitialized,
  _$connConnected,
  _$connFailed,
]);

Serializer<SettingsState> _$settingsStateSerializer =
    new _$SettingsStateSerializer();
Serializer<SettingsStateConnection> _$settingsStateConnectionSerializer =
    new _$SettingsStateConnectionSerializer();

class _$SettingsStateSerializer implements StructuredSerializer<SettingsState> {
  @override
  final Iterable<Type> types = const [SettingsState, _$SettingsState];
  @override
  final String wireName = 'SettingsState';

  @override
  Iterable<Object?> serialize(Serializers serializers, SettingsState object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'is_light_mode',
      serializers.serialize(object.isLightMode,
          specifiedType: const FullType(bool)),
      'refresh_seconds',
      serializers.serialize(object.refreshSeconds,
          specifiedType: const FullType(int)),
      'connections',
      serializers.serialize(object.connections,
          specifiedType: const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(SettingsStateConnection)
          ])),
    ];

    return result;
  }

  @override
  SettingsState deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SettingsStateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'is_light_mode':
          result.isLightMode = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'refresh_seconds':
          result.refreshSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'connections':
          result.connections.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType(SettingsStateConnection)
              ]))!);
          break;
      }
    }

    return result.build();
  }
}

class _$SettingsStateConnectionSerializer
    implements StructuredSerializer<SettingsStateConnection> {
  @override
  final Iterable<Type> types = const [
    SettingsStateConnection,
    _$SettingsStateConnection
  ];
  @override
  final String wireName = 'SettingsStateConnection';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, SettingsStateConnection object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'base_url',
      serializers.serialize(object.baseUrl,
          specifiedType: const FullType(String)),
      'site',
      serializers.serialize(object.site, specifiedType: const FullType(String)),
      'username',
      serializers.serialize(object.username,
          specifiedType: const FullType(String)),
      'secret',
      serializers.serialize(object.secret,
          specifiedType: const FullType(String)),
      'validate_ssl',
      serializers.serialize(object.validateSsl,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  SettingsStateConnection deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SettingsStateConnectionBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'base_url':
          result.baseUrl = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'site':
          result.site = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'username':
          result.username = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'secret':
          result.secret = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'validate_ssl':
          result.validateSsl = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$SettingsState extends SettingsState {
  @override
  final SettingsStateEnum? state;
  @override
  final String? latestAlias;
  @override
  final bool isLightMode;
  @override
  final int refreshSeconds;
  @override
  final BuiltMap<String, SettingsStateConnection> connections;

  factory _$SettingsState([void Function(SettingsStateBuilder)? updates]) =>
      (new SettingsStateBuilder()..update(updates))._build();

  _$SettingsState._(
      {this.state,
      this.latestAlias,
      required this.isLightMode,
      required this.refreshSeconds,
      required this.connections})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isLightMode, r'SettingsState', 'isLightMode');
    BuiltValueNullFieldError.checkNotNull(
        refreshSeconds, r'SettingsState', 'refreshSeconds');
    BuiltValueNullFieldError.checkNotNull(
        connections, r'SettingsState', 'connections');
  }

  @override
  SettingsState rebuild(void Function(SettingsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsStateBuilder toBuilder() => new SettingsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsState &&
        state == other.state &&
        latestAlias == other.latestAlias &&
        isLightMode == other.isLightMode &&
        refreshSeconds == other.refreshSeconds &&
        connections == other.connections;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, latestAlias.hashCode);
    _$hash = $jc(_$hash, isLightMode.hashCode);
    _$hash = $jc(_$hash, refreshSeconds.hashCode);
    _$hash = $jc(_$hash, connections.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SettingsState')
          ..add('state', state)
          ..add('latestAlias', latestAlias)
          ..add('isLightMode', isLightMode)
          ..add('refreshSeconds', refreshSeconds)
          ..add('connections', connections))
        .toString();
  }
}

class SettingsStateBuilder
    implements Builder<SettingsState, SettingsStateBuilder> {
  _$SettingsState? _$v;

  SettingsStateEnum? _state;
  SettingsStateEnum? get state => _$this._state;
  set state(SettingsStateEnum? state) => _$this._state = state;

  String? _latestAlias;
  String? get latestAlias => _$this._latestAlias;
  set latestAlias(String? latestAlias) => _$this._latestAlias = latestAlias;

  bool? _isLightMode;
  bool? get isLightMode => _$this._isLightMode;
  set isLightMode(bool? isLightMode) => _$this._isLightMode = isLightMode;

  int? _refreshSeconds;
  int? get refreshSeconds => _$this._refreshSeconds;
  set refreshSeconds(int? refreshSeconds) =>
      _$this._refreshSeconds = refreshSeconds;

  MapBuilder<String, SettingsStateConnection>? _connections;
  MapBuilder<String, SettingsStateConnection> get connections =>
      _$this._connections ??= new MapBuilder<String, SettingsStateConnection>();
  set connections(MapBuilder<String, SettingsStateConnection>? connections) =>
      _$this._connections = connections;

  SettingsStateBuilder();

  SettingsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _state = $v.state;
      _latestAlias = $v.latestAlias;
      _isLightMode = $v.isLightMode;
      _refreshSeconds = $v.refreshSeconds;
      _connections = $v.connections.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SettingsState;
  }

  @override
  void update(void Function(SettingsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsState build() => _build();

  _$SettingsState _build() {
    _$SettingsState _$result;
    try {
      _$result = _$v ??
          new _$SettingsState._(
              state: state,
              latestAlias: latestAlias,
              isLightMode: BuiltValueNullFieldError.checkNotNull(
                  isLightMode, r'SettingsState', 'isLightMode'),
              refreshSeconds: BuiltValueNullFieldError.checkNotNull(
                  refreshSeconds, r'SettingsState', 'refreshSeconds'),
              connections: connections.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'connections';
        connections.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SettingsState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$SettingsStateConnection extends SettingsStateConnection {
  @override
  final SettingsConnectionStateEnum? state;
  @override
  final cmk_api.Client? client;
  @override
  final cmk_api.CheckMkBaseError? error;
  @override
  final String baseUrl;
  @override
  final String site;
  @override
  final String username;
  @override
  final String secret;
  @override
  final bool validateSsl;

  factory _$SettingsStateConnection(
          [void Function(SettingsStateConnectionBuilder)? updates]) =>
      (new SettingsStateConnectionBuilder()..update(updates))._build();

  _$SettingsStateConnection._(
      {this.state,
      this.client,
      this.error,
      required this.baseUrl,
      required this.site,
      required this.username,
      required this.secret,
      required this.validateSsl})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        baseUrl, r'SettingsStateConnection', 'baseUrl');
    BuiltValueNullFieldError.checkNotNull(
        site, r'SettingsStateConnection', 'site');
    BuiltValueNullFieldError.checkNotNull(
        username, r'SettingsStateConnection', 'username');
    BuiltValueNullFieldError.checkNotNull(
        secret, r'SettingsStateConnection', 'secret');
    BuiltValueNullFieldError.checkNotNull(
        validateSsl, r'SettingsStateConnection', 'validateSsl');
  }

  @override
  SettingsStateConnection rebuild(
          void Function(SettingsStateConnectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsStateConnectionBuilder toBuilder() =>
      new SettingsStateConnectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsStateConnection &&
        state == other.state &&
        client == other.client &&
        error == other.error &&
        baseUrl == other.baseUrl &&
        site == other.site &&
        username == other.username &&
        secret == other.secret &&
        validateSsl == other.validateSsl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, client.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, baseUrl.hashCode);
    _$hash = $jc(_$hash, site.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, secret.hashCode);
    _$hash = $jc(_$hash, validateSsl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SettingsStateConnection')
          ..add('state', state)
          ..add('client', client)
          ..add('error', error)
          ..add('baseUrl', baseUrl)
          ..add('site', site)
          ..add('username', username)
          ..add('secret', secret)
          ..add('validateSsl', validateSsl))
        .toString();
  }
}

class SettingsStateConnectionBuilder
    implements
        Builder<SettingsStateConnection, SettingsStateConnectionBuilder> {
  _$SettingsStateConnection? _$v;

  SettingsConnectionStateEnum? _state;
  SettingsConnectionStateEnum? get state => _$this._state;
  set state(SettingsConnectionStateEnum? state) => _$this._state = state;

  cmk_api.Client? _client;
  cmk_api.Client? get client => _$this._client;
  set client(cmk_api.Client? client) => _$this._client = client;

  cmk_api.CheckMkBaseError? _error;
  cmk_api.CheckMkBaseError? get error => _$this._error;
  set error(cmk_api.CheckMkBaseError? error) => _$this._error = error;

  String? _baseUrl;
  String? get baseUrl => _$this._baseUrl;
  set baseUrl(String? baseUrl) => _$this._baseUrl = baseUrl;

  String? _site;
  String? get site => _$this._site;
  set site(String? site) => _$this._site = site;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _secret;
  String? get secret => _$this._secret;
  set secret(String? secret) => _$this._secret = secret;

  bool? _validateSsl;
  bool? get validateSsl => _$this._validateSsl;
  set validateSsl(bool? validateSsl) => _$this._validateSsl = validateSsl;

  SettingsStateConnectionBuilder();

  SettingsStateConnectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _state = $v.state;
      _client = $v.client;
      _error = $v.error;
      _baseUrl = $v.baseUrl;
      _site = $v.site;
      _username = $v.username;
      _secret = $v.secret;
      _validateSsl = $v.validateSsl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsStateConnection other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SettingsStateConnection;
  }

  @override
  void update(void Function(SettingsStateConnectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsStateConnection build() => _build();

  _$SettingsStateConnection _build() {
    final _$result = _$v ??
        new _$SettingsStateConnection._(
            state: state,
            client: client,
            error: error,
            baseUrl: BuiltValueNullFieldError.checkNotNull(
                baseUrl, r'SettingsStateConnection', 'baseUrl'),
            site: BuiltValueNullFieldError.checkNotNull(
                site, r'SettingsStateConnection', 'site'),
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'SettingsStateConnection', 'username'),
            secret: BuiltValueNullFieldError.checkNotNull(
                secret, r'SettingsStateConnection', 'secret'),
            validateSsl: BuiltValueNullFieldError.checkNotNull(
                validateSsl, r'SettingsStateConnection', 'validateSsl'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
