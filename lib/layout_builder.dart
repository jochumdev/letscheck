import 'package:flutter/material.dart';

enum Layout { slim, wide, ultrawide }

typedef LayoutLayoutWidgetBuilder = Widget Function(
    BuildContext context, Layout layout);

/// layout.
const double ultraWideLayoutThreshold = 1920;

const double wideLayoutThreshold = 1200;

/// Builds a widget tree that can depend on the parent widget's width
class ProxmoxLayoutBuilder extends StatelessWidget {
  const ProxmoxLayoutBuilder({
    @required this.builder,
    Key key,
  })  : assert(builder != null),
        super(key: key);

  /// Builds the widgets below this widget given this widget's layout width.
  final LayoutLayoutWidgetBuilder builder;

  Widget _build(BuildContext context, BoxConstraints constraints) {
    var mediaWidth = MediaQuery.of(context).size.width;
    final Layout layout = mediaWidth >= ultraWideLayoutThreshold
        ? Layout.ultrawide
        : mediaWidth > wideLayoutThreshold
        ? Layout.wide
        : Layout.slim;
    return builder(context, layout);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }
}
