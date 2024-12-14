import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

Map<String, List<cmk_api.LqlTableServicesDto>> servicesGroupByHostname(
    {required BuiltList<cmk_api.LqlTableServicesDto> services}) {
  var groupedServices = <String, List<cmk_api.LqlTableServicesDto>>{};
  services.forEach((service) {
    if (groupedServices.containsKey(service.hostName)) {
      groupedServices[service.hostName]!.add(service);
    } else {
      groupedServices[service.hostName] = [service];
    }
  });

  return groupedServices;
}
