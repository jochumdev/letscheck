import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../global_router.dart';

class HostCardWidget extends StatelessWidget {
  final String alias;
  final cmkApi.LqlTableHostsDto host;
  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  HostCardWidget({Key? key, required this.alias, required this.host})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(Icons.check, color: Colors.green);
    switch (host.state! as int) {
      case 0:
        icon = Icon(Icons.check, color: Colors.green);
        break;
      case 1:
        icon =
            FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.yellow);
        break;
      case 2:
        icon = FaIcon(FontAwesomeIcons.ban, color: Colors.red);
        break;
      case 3:
        icon = FaIcon(FontAwesomeIcons.questionCircle, color: Colors.grey);
        break;
    }

    return Card(
      child: ListTile(
        leading: icon,
        visualDensity: minimalVisualDensity,
        isThreeLine: host.name != host.displayName,
        title: GestureDetector(
            child: Text(host.name!),
            onTap: () {
              Navigator.of(context).pushNamed(GlobalRouter().buildUri(routeHost,
                  buildArgs: {'alias': alias, 'hostname': host.name!}));
            }),
        subtitle: host.name != host.displayName
            ? Text(host.displayName! + '\n' + host.address!)
            : Text(host.address!),
      ),
    );
  }
}
