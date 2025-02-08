import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/widget/host_card_widget.dart';

class HostsListWidget extends StatelessWidget {
  final String alias;
  final List<cmk_api.Host> hosts;
  final Key? listKey;

  HostsListWidget({required this.alias, required this.hosts, this.listKey});

  @override
  Widget build(BuildContext context) {
    var mapHosts = <String, cmk_api.Host>{};
    for (var host in hosts) {
      mapHosts[host.hostName!] = host;
    }

    var sortedHostNames = mapHosts.keys.toList();
    sortedHostNames.sort();

    return ListView.builder(
      key: listKey,
      itemCount: sortedHostNames.length,
      itemBuilder: (context, idx) {
        var hostName = sortedHostNames[idx];
        var host = mapHosts[hostName];
        return HostCardWidget(site: alias, host: host!);
      },
    );
  }
}
