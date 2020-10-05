import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HostCardWidget extends StatelessWidget {
  final String alias;
  final cmkApi.LqlTableHostsDto host;
  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  HostCardWidget({Key key, @required this.alias, @required this.host})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    switch (host.state) {
      case 0:
        icon = FaIcon(FontAwesomeIcons.checkSquare, color: Colors.greenAccent);
        break;
      case 1:
        icon = FaIcon(FontAwesomeIcons.exclamationTriangle,
            color: Colors.yellowAccent);
        break;
      case 2:
        icon = FaIcon(FontAwesomeIcons.ban, color: Colors.redAccent);
        break;
      case 3:
        icon = FaIcon(FontAwesomeIcons.questionCircle, color: Colors.grey);
        break;
    }

    return Card(
      child: ListTile(
        leading: icon,
        visualDensity: minimalVisualDensity,
        isThreeLine: true,
        title: Text(host.name),
        subtitle: Text(host.displayName + "\n" + host.address),
      ),
    );
  }
}
