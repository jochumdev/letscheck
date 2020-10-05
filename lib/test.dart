import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConnectionForm(),
    );
  }
}

class ConnectionFormBloc extends FormBloc<String, String> {
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
    ],
  );

  final validateSsl = BooleanFieldBloc();

  ConnectionFormBloc() {
    addFieldBlocs(fieldBlocs: [
      baseUrl,
      site,
      username,
      secret,
      validateSsl,
    ]);
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));

      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}

class ConnectionForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectionFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<ConnectionFormBloc>(context);

          return Scaffold(
            appBar: AppBar(title: Text('Connection')),
            body: FormBlocListener<ConnectionFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => SuccessScreen()));
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);

                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.baseUrl,
                        decoration: InputDecoration(
                          labelText: 'Url',
                          prefixIcon: Icon(Icons.text_fields),
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
                          prefixIcon: Icon(Icons.text_fields),
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
                        booleanFieldBloc: formBloc.validateSsl,
                        body: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Validate SSL?'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(key: key),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ConnectionForm())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
