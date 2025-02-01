import 'base.dart';

class WebJavascriptRuntimeWrapper implements AbsJavascriptRuntimeWrapper {
  @override
  String evaluate(String code, {String? sourceUrl}) {
    return "";
  }
}

Future<JavascriptRuntimeWrapper> initJavascriptRuntime() async {
  final w = JavascriptRuntimeWrapper();
  w.impl = WebJavascriptRuntimeWrapper();
  return w;
}
