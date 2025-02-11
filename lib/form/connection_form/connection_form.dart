import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:letscheck/providers/settings/settings_state.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

final connectionFormProvider = StateNotifierProvider.autoDispose
    .family<ConnectionFormNotifier, ConnectionFormState, String>((ref, alias) {
  return ConnectionFormNotifier(ref, alias);
});

class ConnectionFormState {
  final String? site;
  final String? alias;
  final String? url;
  final String? username;
  final String? password;
  final bool insecure;
  final bool sendNotifications;
  final bool wifiOnly;
  final String? error;
  final bool isSubmitting;
  final bool isValid;
  final bool isEditing;

  ConnectionFormState({
    this.site,
    this.alias,
    this.url,
    this.username,
    this.password,
    this.insecure = false,
    this.sendNotifications = false,
    this.wifiOnly = false,
    this.error,
    this.isSubmitting = false,
    this.isValid = false,
    this.isEditing = false,
  });

  ConnectionFormState copyWith({
    String? site,
    String? alias,
    String? url,
    String? username,
    String? password,
    bool? insecure,
    bool? sendNotifications,
    bool? wifiOnly,
    String? error,
    bool? isSubmitting,
    bool? isValid,
    bool? isEditing,
  }) {
    return ConnectionFormState(
      site: site ?? this.site,
      alias: alias ?? this.alias,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      insecure: insecure ?? this.insecure,
      sendNotifications: sendNotifications ?? this.sendNotifications,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValid: isValid ?? this.isValid,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ConnectionFormNotifier extends StateNotifier<ConnectionFormState> {
  final Ref ref;
  final String alias;

  ConnectionFormNotifier(this.ref, this.alias) : super(ConnectionFormState()) {
    _init();
  }

  void _init() {
    if (alias == '+') return;

    final settings = ref.read(settingsProvider);
    final connection =
        settings.connections.where((c) => c.alias == alias).singleOrNull;
    if (connection == null) return;

    state = ConnectionFormState(
      site: connection.site,
      alias: alias,
      url: connection.baseUrl,
      username: connection.username,
      password: '', // Mask the existing password
      insecure: connection.insecure,
      sendNotifications: connection.sendNotifications,
      wifiOnly: connection.wifiOnly,
      isEditing: true,
      isValid: true,
    );
  }

  Future<bool> submit() async {
    if (!mounted) return false;

    if (!state.isValid) return false;

    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final settingsNotifier = ref.read(settingsProvider.notifier);
      final settings = ref.read(settingsProvider);

      final talkerDioLogger = ref.read(talkerDioLoggerProvider);

      // Create a temporary client to test the connection
      final client = cmk_api.Client(
        () {
          final dio = Dio();
          dio.interceptors.add(talkerDioLogger);
          return dio;
        },
        cmk_api.ClientSettings(
          site: state.site!,
          baseUrl: state.url!,
          username: state.username!,
          secret: state.isEditing && state.password == ''
              ? settings.connections
                      .where((c) => c.alias == alias)
                      .singleOrNull
                      ?.password ??
                  state.password!
              : state.password!,
          insecure: !state.insecure,
        ),
      );

      try {
        await client.testConnection();
      } catch (e) {
        state = state.copyWith(
          error: e.toString(),
          isSubmitting: false,
        );
        return false;
      }

      if (state.isEditing) {
        final currentConnection =
            settings.connections.where((c) => c.alias == alias).singleOrNull;
        if (currentConnection == null) return false;

        await settingsNotifier.updateConnection(
          SettingsStateConnection(
            alias: alias,
            site: state.site!,
            baseUrl: state.url!,
            username: state.username!,
            password: state.password == ''
                ? currentConnection.password
                : state.password!,
            insecure: state.insecure,
            sendNotifications: state.sendNotifications,
            wifiOnly: state.wifiOnly,
          ),
        );
      } else {
        if (state.alias == null) return false;
        await settingsNotifier.addConnection(
          SettingsStateConnection(
            alias: state.alias!,
            site: state.site!,
            baseUrl: state.url!,
            username: state.username!,
            password: state.password!,
            insecure: state.insecure,
            sendNotifications: state.sendNotifications,
            wifiOnly: state.wifiOnly,
          ),
        );
      }

      return true;
    } catch (e) {
      if (!mounted) return false;

      state = state.copyWith(error: e.toString(), isSubmitting: false);
      return false;
    }
  }

  void update(
      ConnectionFormState Function(ConnectionFormState state) callback) {
    state = callback(state);
  }
}

class ConnectionForm extends ConsumerStatefulWidget {
  final String alias;

  const ConnectionForm({required this.alias, super.key});

  @override
  ConsumerState<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends ConsumerState<ConnectionForm> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(connectionFormProvider(widget.alias));
    form = buildForm(formState);
  }

  FormGroup buildForm(ConnectionFormState state) {
    return FormGroup({
      'site': FormControl<String>(
        value: state.site,
        validators: [
          Validators.required,
          Validators.pattern(r'[a-zA-Z0-9_-]+')
        ],
      ),
      'alias': FormControl<String>(
        value: state.alias,
        validators: [
          Validators.required,
          Validators.pattern(r'[a-zA-Z0-9_-]+')
        ],
      ),
      'url': FormControl<String>(
        value: state.url ?? 'https://',
        validators: [
          Validators.required,
          Validators.pattern(r'^https?:\/\/.+'),
        ],
      ),
      'username': FormControl<String>(
        value: state.username,
        validators: [Validators.required],
      ),
      'password': !state.isEditing
          ? FormControl<String>(
              value: state.password,
              validators: [Validators.required],
            )
          : FormControl<String>(
              value: state.password,
            ),
      'insecure': FormControl<bool>(
        value: state.insecure,
      ),
      'sendNotifications': FormControl<bool>(
        value: state.isEditing ? state.sendNotifications : true,
      ),
      'wifiOnly': FormControl<bool>(
        value: state.wifiOnly,
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(connectionFormProvider(widget.alias));
    final formNotifier =
        ref.watch(connectionFormProvider(widget.alias).notifier);
    final passwordVisible = ValueNotifier<bool>(false);

    return ReactiveForm(
      formGroup: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!formState.isEditing)
            ReactiveTextField<String>(
              formControlName: 'alias',
              decoration: const InputDecoration(
                labelText: 'Alias',
                helperText: 'A unique identifier for this connection',
              ),
              validationMessages: {
                ValidationMessage.required: (_) => 'Alias is required',
              },
            ),
          if (!formState.isEditing) const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'site',
            decoration: const InputDecoration(
              labelText: 'Site',
              helperText: 'The Checkmk site to connect to',
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Site name is required',
            },
          ),
          const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'url',
            decoration: const InputDecoration(
              labelText: 'URL',
              helperText: 'The base URL (e.g., https://monitor.example.com)',
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'URL is required',
              ValidationMessage.pattern: (_) =>
                  'Please enter a valid URL starting with http:// or https://',
            },
          ),
          const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'username',
            decoration: const InputDecoration(
              labelText: 'Username',
              helperText: 'Your Checkmk Username',
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Username is required',
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: passwordVisible,
            builder: (context, isVisible, child) {
              return ReactiveTextField<String>(
                formControlName: 'password',
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText:
                      'Your Checkmk Password or leave empty if already set',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => passwordVisible.value = !isVisible,
                  ),
                ),
                obscureText: !isVisible,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Password is required',
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ReactiveSwitchListTile(
            formControlName: 'insecure',
            title: const Text('Allow Insecure Connections'),
            subtitle: const Text('Skip SSL certificate validation'),
          ),
          ReactiveSwitchListTile(
            formControlName: 'sendNotifications',
            title: const Text('Enable Notifications'),
            subtitle: const Text('Show system notifications'),
          ),
          ReactiveSwitchListTile(
            formControlName: 'wifiOnly',
            title: const Text('Only connect via Wi-Fi'),
            subtitle:
                const Text('Only connect to Checkmk when Wi-Fi is available'),
          ),
          if (formState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                formState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (ref.watch(settingsProvider).connections.isNotEmpty)
                    ElevatedButton(
                      onPressed:
                          formState.isSubmitting ? null : () => context.pop(),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  if (ref.watch(settingsProvider).connections.isNotEmpty)
                    SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: form.valid && !formState.isSubmitting
                        ? () async {
                            // Get current form values
                            final currentValues = form.value;
                            formNotifier.update((state) => ConnectionFormState(
                                  site: currentValues['site'] as String,
                                  alias: currentValues['alias'] as String,
                                  url: currentValues['url'] as String,
                                  username: currentValues['username'] as String,
                                  password: currentValues['password'] as String,
                                  insecure:
                                      currentValues['insecure'] as bool? ??
                                          false,
                                  sendNotifications:
                                      currentValues['sendNotifications']
                                              as bool? ??
                                          false,
                                  wifiOnly:
                                      currentValues['wifiOnly'] as bool? ??
                                          false,
                                  isValid: true,
                                  isEditing: formState.isEditing,
                                ));

                            if (await formNotifier.submit()) {
                              if (formState.isEditing) {
                                context.pop();
                              } else {
                                form.reset();
                              }
                            }
                          }
                        : null,
                    child: Text(formState.isSubmitting
                        ? 'Saving...'
                        : formState.isEditing
                            ? 'Save'
                            : 'Add'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
