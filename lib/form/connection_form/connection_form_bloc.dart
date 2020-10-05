import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import '../../bloc/settings/settings.dart';

class ConnectionFormBloc extends FormBloc<String, String> {
  final SettingsBloc settingsBloc;
  final String connectionAlias;
  final SettingsStateConnection connection;

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

  final validateSsl = BooleanFieldBloc();

  ConnectionFormBloc(
      {@required this.settingsBloc, this.connectionAlias, this.connection, bool isEditing = false}) : super(isEditing: isEditing) {
    if (connection != null) {
      alias.updateInitialValue(connectionAlias);
      baseUrl.updateInitialValue(connection.baseUrl);
      site.updateInitialValue(connection.site);
      username.updateInitialValue(connection.username);
      secret.updateInitialValue(connection.secret);
      validateSsl.updateInitialValue(connection.validateSsl);
    } else {
      validateSsl.updateInitialValue(true);
    }

    addFieldBlocs(fieldBlocs: [
      alias,
      baseUrl,
      site,
      username,
      secret,
      validateSsl,
    ]);
  }

  @override
  void onSubmitting() async {
    var client = cmkApi.Client(cmkApi.ClientSettings(
        baseUrl: baseUrl.value,
        site: site.value,
        username: username.value,
        secret: secret.value,
        validateSsl: validateSsl.value));

    try {
      await client.testConnection();
    } on cmkApi.CheckMkBaseError catch (e) {
      if (e.response == null) {
        emitFailure(failureResponse: "Connection failed: '${e.message}'");
        return;
      } else if (e.response.statusCode == 401) {
        emitFailure(failureResponse: "Authentication failed");
        return;
      }

      emitFailure(
          failureResponse: "Failed StatusCode was: '${e.response.statusCode}'");
      return;
    }

    if (connectionAlias == null) {
      settingsBloc.add(NewConnection(
          alias.value,
          SettingsStateConnection.init(
            state: SettingsConnectionStateEnum.connected,
            baseUrl: baseUrl.value,
            site: site.value,
            username: username.value,
            secret: secret.value,
            validateSsl: validateSsl.value,
            client: client,
          )));
    } else {
      settingsBloc.add(UpdateConnection(
          alias.value,
          SettingsStateConnection.init(
            state: SettingsConnectionStateEnum.connected,
            baseUrl: baseUrl.value,
            site: site.value,
            username: username.value,
            secret: secret.value,
            validateSsl: validateSsl.value,
            client: client,
          )));

      settingsBloc.add(ConnectionBack(alias.value));
    }

    emitSuccess(canSubmitAgain: false);
  }
}
