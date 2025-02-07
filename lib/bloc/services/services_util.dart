import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

Map<String, List<cmk_api.Service>> servicesGroupByHostname(
    {required List<cmk_api.Service> services}) {
  var groupedServices = <String, List<cmk_api.Service>>{};
  for (var service in services) {
    if (groupedServices.containsKey(service.hostName)) {
      groupedServices[service.hostName]!.add(service);
    } else {
      groupedServices[service.hostName!] = [service];
    }
  }

  return groupedServices;
}
