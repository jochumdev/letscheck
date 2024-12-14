import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../bloc/services/services.dart';
import 'services_grouped_card_widget.dart';

class ServicesListWidget extends StatelessWidget {
  final String alias;
  final BuiltList<cmk_api.LqlTableServicesDto> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesListWidget({required this.alias, required this.services});

  @override
  Widget build(BuildContext context) {
    final groupedServices = servicesGroupByHostname(services: services);

    var hostNames = groupedServices.keys.toList();
    hostNames.sort();

    var result = <Widget>[];
    for (var i = 0; i < hostNames.length; i++) {
      final hostname = hostNames[i];

      result.add(ServicesGroupedCardWidget(
          alias: alias,
          groupName: hostname,
          services: groupedServices[hostname]!));
    }

    return ListView(children: result);
  }
}
