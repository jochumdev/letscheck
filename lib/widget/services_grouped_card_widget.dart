import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/providers.dart';

class ServicesGroupedCardWidget extends ConsumerWidget {
  final String alias;
  final String groupName;
  final bool showGroupHeader;
  final List<cmk_api.Service> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesGroupedCardWidget(
      {required this.alias,
      required this.groupName,
      required this.services,
      this.showGroupHeader = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardWidgets = <Widget>[];

    final comments = ref.watch(connectionDataProvider(alias)
        .select((s) => (s is ConnectionDataLoaded) ? s.comments : const {}));
    final jsRuntime = ref.watch(javascriptRuntimeProvider);

    if (showGroupHeader) {
      cardWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(),
              ),
              Expanded(
                flex: 20,
                child: SelectableText(
                  groupName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () {
                    context.push(
                        '/conn/$alias/host/${Uri.encodeComponent(services[0].hostName!)}');
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
        ),
      );
    }

    for (var service in services) {
      gotoService() async {
        context.push(
            '/conn/$alias/host/${Uri.encodeComponent(service.hostName!)}/services/${Uri.encodeComponent(service.displayName!)}');
      }

      Widget stateIcon = IconButton(
        onPressed: gotoService,
        icon: Icon(Icons.check, color: Colors.green, size: 20),
      );
      switch (service.state) {
        case cmk_api.svcStateOk:
          stateIcon = IconButton(
            onPressed: gotoService,
            icon: Icon(Icons.check, color: Colors.green, size: 20),
          );
          break;
        case cmk_api.svcStateWarn:
          stateIcon = IconButton(
            onPressed: gotoService,
            icon: FaIcon(FontAwesomeIcons.triangleExclamation,
                color: Colors.yellow, size: 20),
          );
          break;
        case cmk_api.svcStateCritical:
          stateIcon = IconButton(
            onPressed: gotoService,
            icon: FaIcon(FontAwesomeIcons.ban, color: Colors.red, size: 20),
          );
          break;
        case cmk_api.svcStateUnknown:
          stateIcon = IconButton(
            onPressed: gotoService,
            icon: FaIcon(FontAwesomeIcons.circleQuestion,
                color: Colors.grey, size: 20),
          );
          break;
      }
      var pluginOutput = service.pluginOutput!;
      if (pluginOutput.length > 7) {
        switch (pluginOutput.substring(0, 7)) {
          case 'CRIT - ':
          case 'WARN - ':
          case 'UNKN - ':
            pluginOutput = pluginOutput.substring(7);
        }
      }

      Widget commentsWidget = Container();
      var commentRows = <Widget>[];
      for (var id in service.comments!) {
        if (comments.containsKey(id)) {
          final comment = comments[id]!;
          commentRows.add(Row(children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: SelectableText(
                    '@${comment!.author}\n${comment.entryTime}',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: SelectableText(comment.comment!,
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ),
          ]));
        }

        if (commentRows.isNotEmpty) {
          commentsWidget = Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                children: commentRows,
              ));
        }
      }

      cardWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: stateIcon,
                ),
                Expanded(
                  flex: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                              service.displayName!.substring(
                                  0,
                                  service.displayName!.length > 35
                                      ? 35
                                      : service.displayName!.length),
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            jsRuntime.evaluate(
                                "DateTime.fromISO('${service.lastStateChange.toString().replaceFirst(" ", "T")}').toRelative({style: 'short'});"),
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      SelectableText(
                        pluginOutput,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
              ],
            ),
            commentsWidget,
          ]),
        ),
      );
    }

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardWidgets,
      ),
    );
  }
}
