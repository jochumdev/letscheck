import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'connection_form_bloc.dart';
import '../../bloc/settings/settings.dart';
import '../../dialog/loading_dialog.dart';

class ConnectionFormWidget extends StatelessWidget {
  final String? alias;
  final GlobalKey<State> _ldKey = GlobalKey<State>();

  ConnectionFormWidget({this.alias});

  @override
  Widget build(BuildContext context) {
    final formBloc = BlocProvider.of<ConnectionFormBloc>(context);
    var isNew = alias == null;

    return FormBlocListener<ConnectionFormBloc, String, String>(
      onSubmitting: (context, state) {
        LoadingDialog.show(context, key: _ldKey);
      },
      onSuccess: (context, state) {
        LoadingDialog.hide(context);

        Navigator.of(context).pop();
      },
      onFailure: (context, state) {
        LoadingDialog.hide(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.failureResponse!)));
      },
      child: Builder(builder: (context) {
        var buttons = <Widget>[];
        if (!isNew) {
          buttons.add(ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              var dialogResult = await showDialog<bool>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Warning'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Do you really want to Delete'
                              ' the connection "${formBloc.alias.value}"'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (dialogResult!) {
                Navigator.of(context).pop();
                final sBloc = BlocProvider.of<SettingsBloc>(context);
                sBloc.add(DeleteConnection(formBloc.alias.value));
              }
            },
            child: Text('Delete'),
          ));
        } else {
          buttons.add(Container());
        }
        buttons.add(ElevatedButton(
          onPressed: formBloc.submit,
          child: Text('Save'),
        ));

        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 5),
                  child: Text(
                      isNew ? 'Add a Connection' : 'Edit Connection: $alias'),
                ),
                Column(
                  children: <Widget>[
                    isNew
                        ? TextFieldBlocBuilder(
                            textFieldBloc: formBloc.alias,
                            decoration: InputDecoration(
                              labelText: 'Alias for the Connection',
                              prefixIcon: Icon(Icons.settings_input_component),
                            ),
                          )
                        : Container(),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.baseUrl,
                      decoration: InputDecoration(
                        labelText: 'Url',
                        prefixIcon: Icon(Icons.web_asset),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.site,
                      decoration: InputDecoration(
                        labelText: 'Site',
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.account_circle_rounded),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.secret,
                      suffixButton: SuffixButton.obscureText,
                      decoration: InputDecoration(
                        labelText: 'Secret',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    SwitchFieldBlocBuilder(
                      booleanFieldBloc: formBloc.notifications,
                      body: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Enable Notifications? (this requires lql-api on the server!)'),
                      ),
                    ),
                    SwitchFieldBlocBuilder(
                      booleanFieldBloc: formBloc.validateSsl,
                      body: Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Validate SSL?'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: buttons,
                    ),
                  ],
                ),
              ],
            ));
      }),
    );
  }
}
