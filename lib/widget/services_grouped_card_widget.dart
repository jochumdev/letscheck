import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/javascript/javascript.dart';
import '../bloc/comments/comments.dart';
import '../global_router.dart';

class ServicesGroupedCardWidget extends StatelessWidget {
  final String alias;
  final String groupName;
  final bool showGroupHeader;
  final List<cmk_api.TableServicesDto> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesGroupedCardWidget(
      {required this.alias,
      required this.groupName,
      required this.services,
      this.showGroupHeader = true});

  @override
  Widget build(BuildContext context) {
    var cardWidgets = <Widget>[];

    final cBloc = BlocProvider.of<CommentsBloc>(context);
    final jsRuntime = RepositoryProvider.of<JavascriptRuntimeWrapper>(context);

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
                child: SelectableText(groupName),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      GlobalRouter().buildUri(
                        routeHost,
                        buildArgs: {
                          'alias': alias,
                          'hostname': services[0].hostName!
                        },
                      ),
                    );
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
        await Navigator.of(context).pushNamed(GlobalRouter()
            .buildUri(routeService, buildArgs: {
          'alias': alias,
          'hostname': service.hostName!,
          'service': service.displayName!
        }));
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
      if (cBloc.state.comments.containsKey(alias)) {
        var commentRows = <Widget>[];
        for (var id in service.comments!) {
          if (cBloc.state.comments[alias]!.containsKey(id)) {
            final comment = cBloc.state.comments[alias]![id];
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
                        '@${comment!.author}\n${jsRuntime.evaluate("DateTime.fromISO('${comment.entryTime.toString().replaceFirst(" ", "T")}').toRelative({style: 'short'});")}',
                        style: Theme.of(context).textTheme.bodySmall)),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: SelectableText(comment.comment!,
                        style: Theme.of(context).textTheme.labelMedium)),
              ),
            ]));
          }
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
                            // jsRuntime.evaluate("console.log('')").stringResult,
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
                  child: IconButton(
                    onPressed: gotoService,
                    tooltip: "Goto service",
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            commentsWidget,
          ]),
        ),
      );

      //   cardWidgets.add();
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
