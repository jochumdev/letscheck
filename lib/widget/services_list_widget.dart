import 'package:flutter/material.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/providers/services/services_util.dart';
import 'package:letscheck/widget/services_grouped_card_widget.dart';

class ServicesListWidget extends StatefulWidget {
  final String alias;
  final List<cmk_api.Service> services;
  final Key? listKey;

  const ServicesListWidget({
    required this.alias,
    required this.services,
    this.listKey,
    super.key,
  });

  @override
  State<ServicesListWidget> createState() => _ServicesListWidgetState();
}

class _ServicesListWidgetState extends State<ServicesListWidget> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final groupedServices = servicesGroupByHostname(services: widget.services);
    final hostNames = groupedServices.keys.toList()..sort();

    return ListView.builder(
      key: widget.listKey,
      controller: _scrollController,
      itemCount: hostNames.length,
      itemBuilder: (context, index) {
        final hostname = hostNames[index];
        return ServicesGroupedCardWidget(
          site: widget.alias,
          groupName: hostname,
          services: groupedServices[hostname]!,
        );
      },
    );
  }
}
