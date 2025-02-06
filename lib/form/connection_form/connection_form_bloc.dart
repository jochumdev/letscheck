import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../../bloc/settings/settings.dart';

class ConnectionFormBloc extends FormBloc<String, String> {
  final SettingsBloc settingsBloc;
  final String? connectionAlias;
  final SettingsStateConnection? connection;

  final alias = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final baseUrl = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final site = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final username = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final secret = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  final notifications = BooleanFieldBloc();

  final validateSsl = BooleanFieldBloc();

  ConnectionFormBloc(
      {required this.settingsBloc,
      this.connectionAlias,
      this.connection,
      super.isEditing = false}) {
    alias.updateInitialValue(connectionAlias != null ? connectionAlias! : '');
    baseUrl.updateInitialValue(
        connection != null ? connection!.baseUrl : 'https://');
    site.updateInitialValue(connection != null ? connection!.site : '');
    username.updateInitialValue(connection != null ? connection!.username : '');
    secret.updateInitialValue(connection != null ? connection!.secret : '');
    notifications.updateInitialValue(
        connection != null ? connection!.notifications : true);
    validateSsl.updateInitialValue(
        connection != null ? connection!.validateSsl : true);

    addFieldBlocs(fieldBlocs: [
      alias,
      baseUrl,
      site,
      username,
      secret,
      notifications,
      validateSsl,
    ]);
  }

  @override
  void onSubmitting() async {
    var client = cmk_api.Client(cmk_api.ClientSettings(
        baseUrl: baseUrl.value,
        site: site.value,
        username: username.value,
        secret: secret.value,
        validateSsl: validateSsl.value));

    try {
      await client.testConnection();
    } on cmk_api.NetworkError catch (e) {
      if (e.response!.statusCode == 401) {
        emitFailure(failureResponse: 'Authentication failed');
        return;
      }

      emitFailure(
          failureResponse:
              "Failed StatusCode was: '${e.response!.statusCode}'");
      return;
    } catch (e) {
      settingsBloc
          .add(ConnectionFailed(alias.value, cmk_api.NetworkError.of(e)));
      emitFailure(failureResponse: "Failed error: $e");
      return;
    }

    settingsBloc.add(UpdateConnection(
        alias.value,
        SettingsStateConnection.init(
          state: SettingsConnectionStateEnum.connected,
          baseUrl: baseUrl.value,
          site: site.value,
          username: username.value,
          secret: secret.value,
          notifications: notifications.value,
          validateSsl: validateSsl.value,
          client: client,
        )));

    settingsBloc.add(ConnectionBack(alias.value));

    emitSuccess(canSubmitAgain: false);
  }
}
