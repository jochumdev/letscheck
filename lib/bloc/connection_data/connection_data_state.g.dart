// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_data_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectionDataState extends ConnectionDataState {
  @override
  final BuiltMap<String, cmk_api.StatsTacticalOverviewDto> stats;
  @override
  final BuiltMap<String, BuiltList<cmk_api.TableServicesDto>> unhServices;

  factory _$ConnectionDataState(
          [void Function(ConnectionDataStateBuilder)? updates]) =>
      (new ConnectionDataStateBuilder()..update(updates))._build();

  _$ConnectionDataState._({required this.stats, required this.unhServices})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        stats, r'ConnectionDataState', 'stats');
    BuiltValueNullFieldError.checkNotNull(
        unhServices, r'ConnectionDataState', 'unhServices');
  }

  @override
  ConnectionDataState rebuild(
          void Function(ConnectionDataStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectionDataStateBuilder toBuilder() =>
      new ConnectionDataStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectionDataState &&
        stats == other.stats &&
        unhServices == other.unhServices;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stats.hashCode);
    _$hash = $jc(_$hash, unhServices.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectionDataState')
          ..add('stats', stats)
          ..add('unhServices', unhServices))
        .toString();
  }
}

class ConnectionDataStateBuilder
    implements Builder<ConnectionDataState, ConnectionDataStateBuilder> {
  _$ConnectionDataState? _$v;

  MapBuilder<String, cmk_api.StatsTacticalOverviewDto>? _stats;
  MapBuilder<String, cmk_api.StatsTacticalOverviewDto> get stats =>
      _$this._stats ??=
          new MapBuilder<String, cmk_api.StatsTacticalOverviewDto>();
  set stats(MapBuilder<String, cmk_api.StatsTacticalOverviewDto>? stats) =>
      _$this._stats = stats;

  MapBuilder<String, BuiltList<cmk_api.TableServicesDto>>? _unhServices;
  MapBuilder<String, BuiltList<cmk_api.TableServicesDto>> get unhServices =>
      _$this._unhServices ??=
          new MapBuilder<String, BuiltList<cmk_api.TableServicesDto>>();
  set unhServices(
          MapBuilder<String, BuiltList<cmk_api.TableServicesDto>>?
              unhServices) =>
      _$this._unhServices = unhServices;

  ConnectionDataStateBuilder();

  ConnectionDataStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stats = $v.stats.toBuilder();
      _unhServices = $v.unhServices.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectionDataState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ConnectionDataState;
  }

  @override
  void update(void Function(ConnectionDataStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectionDataState build() => _build();

  _$ConnectionDataState _build() {
    _$ConnectionDataState _$result;
    try {
      _$result = _$v ??
          new _$ConnectionDataState._(
            stats: stats.build(),
            unhServices: unhServices.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stats';
        stats.build();
        _$failedField = 'unhServices';
        unhServices.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ConnectionDataState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
