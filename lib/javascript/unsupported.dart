import 'base.dart';

class NullJavascriptRuntimeWrapper implements AbsJavascriptRuntimeWrapper {
  @override
  String evaluate(String code, {String? sourceUrl}) {
    return "";
  }
}

Future<JavascriptRuntimeWrapper> initJavascriptRuntime() async {
  final w = JavascriptRuntimeWrapper();
  w.impl = NullJavascriptRuntimeWrapper();
  return w;
}
