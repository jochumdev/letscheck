import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../global_router.dart';

enum ServicesGroupedCardMode { HOSTS }

class ServicesGroupedCardWidget extends StatelessWidget {
  final String alias;
  final String groupName;
  final bool showGroupHeader;
  final ServicesGroupedCardMode groupMode;
  final List<cmkApi.LqlTableServicesDto> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesGroupedCardWidget(
      {@required this.alias,
      @required this.groupName,
      @required this.services,
      this.showGroupHeader = true,
      this.groupMode = ServicesGroupedCardMode.HOSTS});

  @override
  Widget build(BuildContext context) {
    List<Widget> cardWidgets = [];

    if (showGroupHeader) {
      cardWidgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: groupMode == ServicesGroupedCardMode.HOSTS
            ? GestureDetector(
                child: Text(groupName),
                onTap: () {
                  Navigator.of(context).pushNamed(GlobalRouter()
                      .buildUri(routeHost, buildArgs: {
                    "alias": alias,
                    "hostname": services[0].hostName
                  }));
                })
            : Text(groupName),
      ));
    }

    services.forEach((service) {
      Widget icon;
      switch (service.state) {
        case 0:
          icon = Icon(Icons.check, color: Colors.green, size: 20);
          break;
        case 1:
          icon = FaIcon(FontAwesomeIcons.exclamationTriangle,
              color: Colors.yellow, size: 20);
          break;
        case 2:
          icon = FaIcon(FontAwesomeIcons.ban, color: Colors.red, size: 20);
          break;
        case 3:
          icon = FaIcon(FontAwesomeIcons.questionCircle, color: Colors.grey, size: 20);
          break;
      }

      var pluginOutput = service.pluginOutput;
      switch (pluginOutput.substring(0, 7)) {
        case 'CRIT - ':
        case 'WARN - ':
        case 'UNKN - ':
          pluginOutput = pluginOutput.substring(7);
      }

      cardWidgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: icon,
              ),
              Expanded(
                flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      child: Text(service.displayName, style: Theme.of(context).textTheme.bodyText1),
                      onTap: () {
                        Navigator.of(context).pushNamed(GlobalRouter()
                            .buildUri(routeService, buildArgs: {
                          "alias": alias,
                          "hostname": service.hostName,
                          "service": service.displayName
                        }));
                      }),
                  Text(
                    pluginOutput,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.caption.color),
                  ),
                ],
              ),
              ),
            ],
          )));
    });

    return Card(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cardWidgets),
    );
  }
}
