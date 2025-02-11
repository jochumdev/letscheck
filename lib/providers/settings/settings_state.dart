import 'package:equatable/equatable.dart';

final class SettingsStateConnection extends Equatable {
  final String alias;
  final String site;
  final String baseUrl;
  final String username;
  final String password;
  final bool insecure;
  final bool sendNotifications;
  final bool wifiOnly;
  final bool paused;

  const SettingsStateConnection({
    required this.alias,
    required this.site,
    required this.baseUrl,
    required this.username,
    required this.password,
    this.insecure = false,
    this.sendNotifications = false,
    this.wifiOnly = false,
    this.paused = false,
  });

  @override
  List<Object?> get props => [
        alias,
        site,
        baseUrl,
        username,
        password,
        insecure,
        sendNotifications,
        wifiOnly,
        paused,
      ];

  SettingsStateConnection copyWith({
    String? alias,
    String? site,
    String? baseUrl,
    String? username,
    String? password,
    bool? insecure,
    bool? sendNotifications,
    bool? wifiOnly,
    bool? paused,
  }) {
    return SettingsStateConnection(
      alias: alias ?? this.alias,
      site: site ?? this.site,
      baseUrl: baseUrl ?? this.baseUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      insecure: insecure ?? this.insecure,
      sendNotifications: sendNotifications ?? this.sendNotifications,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      paused: paused ?? this.paused,
    );
  }

  Map<String, dynamic> toJson() => {
        'alias': alias,
        'site': site,
        'base_url': baseUrl,
        'username': username,
        'password': password,
        'insecure': insecure,
        'send_notifications': sendNotifications,
        'wifi_only': wifiOnly,
        'paused': paused,
      };

  factory SettingsStateConnection.fromJson(Map<String, dynamic> json) =>
      SettingsStateConnection(
        alias: json['alias'] as String,
        site: json['site'] as String,
        baseUrl: json['base_url'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        insecure: json['insecure'] as bool? ?? false,
        sendNotifications: json['send_notifications'] as bool? ?? false,
        wifiOnly: json['wifi_only'] as bool? ?? false,
        paused: json['paused'] as bool? ?? false,
      );
}

final class SettingsState extends Equatable {
  final List<SettingsStateConnection> connections;
  final String currentAlias;
  final bool isLightMode;
  final int refreshSeconds;

  const SettingsState({
    this.connections = const [],
    this.currentAlias = '',
    this.isLightMode = true,
    this.refreshSeconds = 30,
  });

  @override
  List<Object?> get props => [
        connections,
        currentAlias,
        isLightMode,
        refreshSeconds,
      ];

  SettingsState copyWith({
    List<SettingsStateConnection>? connections,
    String? currentAlias,
    bool? isLightMode,
    int? refreshSeconds,
  }) {
    return SettingsState(
      connections: connections?.toList(growable: false) ?? this.connections,
      currentAlias: currentAlias ?? this.currentAlias,
      isLightMode: isLightMode ?? this.isLightMode,
      refreshSeconds: refreshSeconds ?? this.refreshSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'connections':
            connections.map((value) => value.toJson()).toList(growable: false),
        'currentAlias': currentAlias,
        'isLightMode': isLightMode,
        'refreshSeconds': refreshSeconds,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        connections: (json['connections'] as List<dynamic>?)
                ?.map(
                  (value) => SettingsStateConnection.fromJson(
                      value as Map<String, dynamic>),
                )
                .toList(growable: false) ??
            [],
        currentAlias: json['currentAlias'] as String? ?? '',
        isLightMode: json['isLightMode'] as bool? ?? true,
        refreshSeconds: json['refreshSeconds'] as int? ?? 30,
      );
}
