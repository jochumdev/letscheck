import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../global_router.dart';

class HostCardWidget extends StatelessWidget {
  final String alias;
  final cmk_api.LqlTableHostsDto host;
  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  HostCardWidget({super.key, required this.alias, required this.host});

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(Icons.check, color: Colors.green);
    switch (host.state) {
      case cmk_api.hostStateUp:
        icon = Icon(Icons.check, color: Colors.green);
        break;
      case cmk_api.hostStateUnreachable:
        icon =
            FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.yellow);
        break;
      case cmk_api.hostStateDown:
        icon = FaIcon(FontAwesomeIcons.ban, color: Colors.red);
        break;
      case cmk_api.hostStatePending:
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
            ? Text('${host.displayName!}\n${host.address!}')
            : Text(host.address!),
      ),
    );
  }
}
