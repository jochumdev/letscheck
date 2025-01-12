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

  final validateSsl = BooleanFieldBloc();

  ConnectionFormBloc(
      {required this.settingsBloc,
      this.connectionAlias,
      this.connection,
      bool isEditing = false})
      : super(isEditing: isEditing) {
    alias.updateInitialValue(connectionAlias != null ? connectionAlias! : '');
    baseUrl.updateInitialValue(connection != null ? connection!.baseUrl : '');
    site.updateInitialValue(connection != null ? connection!.site : '');
    username.updateInitialValue(connection != null ? connection!.username : '');
    secret.updateInitialValue(connection != null ? connection!.secret : '');
    validateSsl.updateInitialValue(
        connection != null ? connection!.validateSsl : true);

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
    var client = cmk_api.Client(cmk_api.ClientSettings(
        baseUrl: baseUrl.value,
        site: site.value,
        username: username.value,
        secret: secret.value,
        validateSsl: validateSsl.value));

    try {
      await client.testConnection();
    } on cmk_api.CheckMkBaseError catch (e) {
      if (e.response!.statusCode == 401) {
        emitFailure(failureResponse: 'Authentication failed');
        return;
      }

      emitFailure(
          failureResponse:
              "Failed StatusCode was: '${e.response!.statusCode}'");
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
          validateSsl: validateSsl.value,
          client: client,
        )));

    settingsBloc.add(ConnectionBack(alias.value));

    emitSuccess(canSubmitAgain: false);
  }
}
