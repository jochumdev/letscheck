import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'settings_state.dart';

abstract class SettingsEvent extends Equatable {}

class AppStarted extends SettingsEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'App started';
}

class ThemeChanged extends SettingsEvent {
  final bool lightMode;
  ThemeChanged(this.lightMode);
  @override
  List<Object> get props => [lightMode];
}

class UpdateRefresh extends SettingsEvent {
  final int refreshSeconds;
  UpdateRefresh(this.refreshSeconds);
  @override
  List<Object> get props => [refreshSeconds];
}

class NewConnection extends SettingsEvent {
  final String alias;
  final SettingsStateConnection connectionSettings;

  NewConnection(this.alias, this.connectionSettings);

  @override
  List<Object> get props => [alias];

  @override
  String toString() => "New connection '$alias'";
}

class UpdateConnection extends SettingsEvent {
  final String alias;
  final SettingsStateConnection connectionSettings;

  UpdateConnection(this.alias, this.connectionSettings);

  @override
  List<Object> get props => [alias];

  @override
  String toString() => "Update connection '$alias'";
}

class DeleteConnection extends SettingsEvent {
  final String alias;

  DeleteConnection(this.alias);

  @override
  List<Object> get props => [alias];

  @override
  String toString() => "Delete connection '$alias'";
}

class ConnectionBack extends SettingsEvent {
  final String alias;

  ConnectionBack(this.alias);

  @override
  List<Object> get props => [alias];

  @override
  String toString() => "Connection '$alias' is back";
}

/*class ConnectedEvent extends SettingsEvent {
  final String alias;
  final cmkApi.Client client;

  ConnectedEvent(this.alias, this.client);

  @override
  List<Object> get props => [alias];

  @override
  String toString() => "Connected to '${alias}'";
}*/

class ConnectionFailed extends SettingsEvent {
  final String alias;
  final cmkApi.CheckMkBaseError error;

  ConnectionFailed(this.alias, this.error);

  @override
  List<Object> get props => [alias, error];

  @override
  String toString() => "Connection '$alias' failed";
}
