abstract class AbsJavascriptRuntimeWrapper {
  String evaluate(String code, {String? sourceUrl});
}

class JavascriptRuntimeWrapper {
  //
  // Start Singleton
  //
  static final JavascriptRuntimeWrapper _singleton =
      JavascriptRuntimeWrapper._internal();

  factory JavascriptRuntimeWrapper() {
    return _singleton;
  }

  JavascriptRuntimeWrapper._internal();
  //
  // END Singleton
  //

  late AbsJavascriptRuntimeWrapper impl;

  String evaluate(String code, {String? sourceUrl}) {
    return impl.evaluate(code, sourceUrl: sourceUrl);
  }
}
