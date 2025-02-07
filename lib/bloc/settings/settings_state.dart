import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

enum SettingsStateEnum {
  uninitialized,
  noConnection,
  clientConnected,
  clientFailed,
  clientDeleted,
  clientUpdated,
  connected,
  failed,
  updatedRefreshSeconds,
}

enum SettingsConnectionStateEnum {
  uninitialized,
  connecting,
  connected,
  failed,
}

sealed class SettingsStateConnection {
  final String baseUrl;
  final String site;
  final String username;
  final String secret;
  final bool notifications;
  final bool validateSsl;
  final SettingsConnectionStateEnum state;
  final cmk_api.Client? client;
  final Map<String, bool> filters;

  const SettingsStateConnection({
    required this.baseUrl,
    required this.site,
    required this.username,
    required this.secret,
    required this.notifications,
    required this.validateSsl,
    required this.state,
    this.client,
    required this.filters,
  });

  Map<String, dynamic> toJson() => {
        'base_url': baseUrl,
        'site': site,
        'username': username,
        'secret': secret,
        'notifications': notifications,
        'validate_ssl': validateSsl,
        'filters': filters,
      };

  factory SettingsStateConnection.fromJson(Map<String, dynamic> json) {
    return SettingsStateConnectionImpl(
      baseUrl: json['base_url'] as String,
      site: json['site'] as String,
      username: json['username'] as String,
      secret: json['secret'] as String,
      notifications: json['notifications'] as bool,
      validateSsl: json['validate_ssl'] as bool,
      state: SettingsConnectionStateEnum.uninitialized,
      filters: Map<String, bool>.from(json['filters'] as Map),
    );
  }

  SettingsStateConnection copyWith({
    String? baseUrl,
    String? site,
    String? username,
    String? secret,
    bool? notifications,
    bool? validateSsl,
    SettingsConnectionStateEnum? state,
    cmk_api.Client? client,
    Map<String, bool>? filters,
  });
}

final class SettingsStateConnectionImpl extends SettingsStateConnection {
  const SettingsStateConnectionImpl({
    required super.baseUrl,
    required super.site,
    required super.username,
    required super.secret,
    required super.notifications,
    required super.validateSsl,
    required super.state,
    super.client,
    required super.filters,
  });

  @override
  SettingsStateConnection copyWith({
    String? baseUrl,
    String? site,
    String? username,
    String? secret,
    bool? notifications,
    bool? validateSsl,
    SettingsConnectionStateEnum? state,
    cmk_api.Client? client,
    Map<String, bool>? filters,
  }) {
    return SettingsStateConnectionImpl(
      baseUrl: baseUrl ?? this.baseUrl,
      site: site ?? this.site,
      username: username ?? this.username,
      secret: secret ?? this.secret,
      notifications: notifications ?? this.notifications,
      validateSsl: validateSsl ?? this.validateSsl,
      state: state ?? this.state,
      client: client ?? this.client,
      filters: filters ?? this.filters,
    );
  }
}

sealed class SettingsState {
  final SettingsStateEnum state;
  final Map<String, SettingsStateConnection> connections;
  final String currentAlias;
  final bool isLightMode;
  final int refreshSeconds;

  const SettingsState({
    required this.state,
    required this.connections,
    required this.currentAlias,
    required this.isLightMode,
    required this.refreshSeconds,
  });

  Map<String, dynamic> toJson() => {
    'state': state.name,
    'current_alias': currentAlias,
    'is_light_mode': isLightMode,
    'refresh_seconds': refreshSeconds,
    'connections': connections.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
  };
}

final class SettingsStateImpl extends SettingsState {
  const SettingsStateImpl({
    required super.state,
    required super.connections,
    required super.currentAlias,
    required super.isLightMode,
    required super.refreshSeconds,
  });

  SettingsStateImpl copyWith({
    SettingsStateEnum? state,
    Map<String, SettingsStateConnection>? connections,
    String? currentAlias,
    bool? isLightMode,
    int? refreshSeconds,
  }) {
    return SettingsStateImpl(
      state: state ?? this.state,
      connections: connections ?? this.connections,
      currentAlias: currentAlias ?? this.currentAlias,
      isLightMode: isLightMode ?? this.isLightMode,
      refreshSeconds: refreshSeconds ?? this.refreshSeconds,
    );
  }

  factory SettingsStateImpl.fromJson(Map<String, dynamic> json) {
    final connections = <String, SettingsStateConnection>{};
    final jsonConnections = json['connections'] as Map<String, dynamic>;
    
    jsonConnections.forEach((key, value) {
      connections[key] = SettingsStateConnection.fromJson(value as Map<String, dynamic>);
    });

    return SettingsStateImpl(
      state: SettingsStateEnum.uninitialized,
      connections: connections,
      currentAlias: json['current_alias'] as String,
      isLightMode: json['is_light_mode'] as bool,
      refreshSeconds: json['refresh_seconds'] as int,
    );
  }
}
