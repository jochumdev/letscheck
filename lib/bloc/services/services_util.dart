import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

Map<String, List<cmkApi.LqlTableServicesDto>> servicesGroupByHostname(
    {@required BuiltList<cmkApi.LqlTableServicesDto> services}) {

  Map<String, List<cmkApi.LqlTableServicesDto>> groupedServices = {};
  services.forEach((service) {
    if (!groupedServices.containsKey(service.hostName)) {
      groupedServices[service.hostName] = [service];
    } else {
      groupedServices[service.hostName].add(service);
    }
  });

  return groupedServices;
}
