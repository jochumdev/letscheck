import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, PlatformException;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_js/flutter_js.dart';

import 'base.dart';

class FFIJavascriptRuntimeWrapper extends AbsJavascriptRuntimeWrapper {
  final JavascriptRuntime impl2;

  FFIJavascriptRuntimeWrapper({required this.impl2});

  @override
  String evaluate(String code, {String? sourceUrl}) {
    return impl2.evaluate(code, sourceUrl: sourceUrl).stringResult;
  }
}

Future<JavascriptRuntimeWrapper> initJavascriptRuntime() async {
  var javascriptRuntime = getJavascriptRuntime();
  if (kDebugMode) {
    javascriptRuntime.onMessage('ConsoleLog2', (args) {
      print('ConsoleLog2 (Dart Side): $args');
      return json.encode(args);
    });
  }

  try {
    var luxonJS = await rootBundle.loadString('assets/js/luxon.min.js');
    javascriptRuntime.evaluate('var window = global = globalThis;');

    await javascriptRuntime.evaluateAsync(luxonJS);
    javascriptRuntime.evaluate('const DateTime = luxon.DateTime;');
  } on PlatformException catch (e) {
    print('Failed to init js engine: ${e.details}');
  }

  final w = JavascriptRuntimeWrapper();
  w.impl = FFIJavascriptRuntimeWrapper(impl2: javascriptRuntime);
  return w;
}
