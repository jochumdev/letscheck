import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

class HostCardWidget extends StatelessWidget {
  final String site;
  final cmk_api.Host host;

  HostCardWidget({super.key, required this.site, required this.host});

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(Icons.check, color: Colors.green);
    switch (host.state) {
      case cmk_api.hostStateUp:
        icon = Icon(Icons.check, color: Colors.green);
        break;
      case cmk_api.hostStateUnreachable:
        icon =
            FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.yellow);
        break;
      case cmk_api.hostStateDown:
        icon = FaIcon(FontAwesomeIcons.ban, color: Colors.red);
        break;
      case cmk_api.hostStatePending:
        icon = FaIcon(FontAwesomeIcons.circleQuestion, color: Colors.grey);
        break;
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: icon,
          ),
          Expanded(
            flex: 20,
            child: SelectableText(host.hostName!),
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              onPressed: () {
                context.push('/$site/host/${Uri.encodeComponent(host.hostName!)}');
              },
              tooltip: "Goto host",
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
