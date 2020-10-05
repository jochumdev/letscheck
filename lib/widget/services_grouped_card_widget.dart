import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicesGroupedCardWidget extends StatelessWidget {
  final String alias;
  final String groupName;
  final List<cmkApi.LqlTableServicesDto> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesGroupedCardWidget(
      {@required this.alias,
      @required this.groupName,
      @required this.services});

  @override
  Widget build(BuildContext context) {
    List<Widget> cardWidgets = [];

    cardWidgets.add(Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: Text(groupName),
    ));

    services.forEach((service) {
      Widget icon;
      switch (service.state) {
        case 0:
          icon =
              FaIcon(FontAwesomeIcons.checkSquare, color: Colors.greenAccent);
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

      var pluginOutput = service.pluginOutput;
      switch (pluginOutput.substring(0, 7)) {
        case 'CRIT - ':
        case 'WARN - ':
        case 'UNKN - ':
          pluginOutput = pluginOutput.substring(7);
      }

      cardWidgets.add(ListTile(
        visualDensity: minimalVisualDensity,
        dense: true,
        leading: icon,
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        title: Text(service.description),
        subtitle: Text(
          pluginOutput,
          maxLines: 2,
        ),
      ));
    });

    return Card(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cardWidgets),
    );
  }
}
