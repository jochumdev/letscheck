import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../bloc/comments/comments.dart';
import '../global_router.dart';

enum ServicesGroupedCardMode { hosts }

class ServicesGroupedCardWidget extends StatelessWidget {
  final String alias;
  final String groupName;
  final bool showGroupHeader;
  final ServicesGroupedCardMode groupMode;
  final List<cmk_api.LqlTableServicesDto> services;

  final minimalVisualDensity = VisualDensity(horizontal: -4.0, vertical: -4.0);

  ServicesGroupedCardWidget(
      {required this.alias,
      required this.groupName,
      required this.services,
      this.showGroupHeader = true,
      this.groupMode = ServicesGroupedCardMode.hosts});

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    var cardWidgets = <Widget>[];

    final cBloc = BlocProvider.of<CommentsBloc>(context);
    final jsRuntime = RepositoryProvider.of<JavascriptRuntime>(context);

    if (showGroupHeader) {
      cardWidgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: groupMode == ServicesGroupedCardMode.hosts
            ? GestureDetector(
                child: Text(groupName),
                onTap: () {
                  Navigator.of(context).pushNamed(GlobalRouter()
                      .buildUri(routeHost, buildArgs: {
                    'alias': alias,
                    'hostname': services[0].hostName
                  }));
                })
            : Text(groupName),
      ));
    }

    for (var service in services) {
      Widget icon = Icon(Icons.check, color: Colors.green, size: 20);
      switch (service.state) {
        case cmk_api.svcStateOk:
          icon = Icon(Icons.check, color: Colors.green, size: 20);
          break;
        case cmk_api.svcStateWarn:
          icon = FaIcon(FontAwesomeIcons.triangleExclamation,
              color: Colors.yellow, size: 20);
          break;
        case cmk_api.svcStateCritical:
          icon = FaIcon(FontAwesomeIcons.ban, color: Colors.red, size: 20);
          break;
        case cmk_api.svcStateUnknown:
          icon = FaIcon(FontAwesomeIcons.circleQuestion,
              color: Colors.grey, size: 20);
          break;
      }
      var pluginOutput = service.pluginOutput!;
      switch (pluginOutput.substring(0, 7)) {
        case 'CRIT - ':
        case 'WARN - ':
        case 'UNKN - ':
          pluginOutput = pluginOutput.substring(7);
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
                    child: Text(
                        '@${comment!.author}\n${jsRuntime.evaluate("DateTime.fromISO('${comment.entryTime.toString().replaceFirst(" ", "T")}').toRelative({style: 'short'});").stringResult}',
                        style: Theme.of(context).textTheme.bodySmall)),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(comment.comment!,
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
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: <Widget>[
              SlidableAction(
                label: 'More',
                foregroundColor: Colors.black45,
                icon: Icons.more_horiz,
                onPressed: (BuildContext context) =>
                    _showSnackBar(context, 'More'),
              ),
              SlidableAction(
                label: 'Acknowledge',
                foregroundColor: Colors.green,
                icon: Icons.delete,
                onPressed: (BuildContext context) =>
                    _showSnackBar(context, 'Delete'),
              ),
            ],
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
              child: GestureDetector(
                child: Column(children: [
                  Row(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    service.displayName!.substring(
                                        0,
                                        service.displayName!.length > 35
                                            ? 35
                                            : service.displayName!.length),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                Text(
                                  jsRuntime
                                      .evaluate(
                                          "DateTime.fromISO('${service.lastStateChange.toString().replaceFirst(" ", "T")}').toRelative({style: 'short'});")
                                      .stringResult,
                                  // jsRuntime.evaluate("console.log('')").stringResult,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              pluginOutput,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  commentsWidget,
                ]),
                onTap: () {
                  Navigator.of(context).pushNamed(GlobalRouter()
                      .buildUri(routeService, buildArgs: {
                    'alias': alias,
                    'hostname': service.hostName,
                    'service': service.displayName!
                  }));
                },
              )),
        ),
      );

      //   cardWidgets.add();
    }

    return Card(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cardWidgets),
    );
  }
}
