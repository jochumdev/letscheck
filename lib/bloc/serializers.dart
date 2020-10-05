import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'settings/settings_state.dart';

part 'serializers.g.dart';

@SerializersFor([
  SettingsStateConnection,
  SettingsState,
])
final Serializers serializers = (_$serializers.toBuilder()
  ..addPlugin(StandardJsonPlugin()))
    .build();
