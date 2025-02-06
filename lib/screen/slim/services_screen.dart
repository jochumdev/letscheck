import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

import 'base_slim_screen.dart';
import '../../bloc/connection_data/connection_data.dart';
import '../../bloc/comments/comments.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/services/services.dart';
import '../../widget/services_list_widget.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/site_stats_widget.dart';

class ServicesScreen extends StatefulWidget {
  final String alias;
  final String filter;

  ServicesScreen({required this.alias, required this.filter});

  @override
  ServicesScreenState createState() => ServicesScreenState(
        alias: alias,
        filter: filter,
      );
}

class ServicesScreenState extends State<ServicesScreen>
    with BaseSlimScreenState {
  final String alias;
  final String filter;

  ServicesScreenState({required this.alias, required this.filter});

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Services';
    switch (filter) {
      case 'all':
        title = "Services";
        break;
      default:
        title = "Services $filter";
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    var myFilters = <String>[];
    switch (filter) {
      case 'problems':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateWarn}"}');
        break;
      case 'unhandled':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateCritical}"}');
        break;
      case 'stale':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateUnknown}"}');
        break;
      case 'all':
        break;
      default:
        if (filter.isNotEmpty) {
          myFilters.add(filter);
        }
    }

    return BlocProvider<ServicesBloc>(
      create: (context) =>
          ServicesBloc(alias: alias, filter: myFilters, sBloc: sBloc)
            ..add(ServicesStartFetching()),
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          return BlocBuilder<CommentsBloc, CommentsState>(
            builder: (cContext, cState) {
              final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
              if (state is ServicesStateFetched) {
                commentsFetchForServices(
                    context: context,
                    alias: alias,
                    services: state.services.toList());
                return Column(
                  children: [
                    SiteStatsWidget(alias: alias, state: cBloc.state),
                    Expanded(
                      child: ServicesListWidget(
                          alias: alias, services: state.services),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SiteStatsWidget(alias: alias, state: cBloc.state),
                    Expanded(child: CenterLoadingWidget()),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
