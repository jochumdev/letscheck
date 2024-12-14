import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

part 'connection_data_state.g.dart';

abstract class ConnectionDataState
    implements Built<ConnectionDataState, ConnectionDataStateBuilder> {
  ConnectionDataState._();
  factory ConnectionDataState(
          [void Function(ConnectionDataStateBuilder) updates]) =
      _$ConnectionDataState;

  BuiltMap<String, cmkApi.LqlStatsTacticalOverviewDto> get stats;

  BuiltMap<String, BuiltList<cmkApi.LqlTableServicesDto>> get unhServices;

  factory ConnectionDataState.init() => ConnectionDataState((b) => b);
}
