import 'package:flutter/material.dart';
import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../../global_router.dart';
import '../../bloc/comments/comments.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/services/services.dart';
import '../../widget/services_list_widget.dart';
import '../../widget/center_loading_widget.dart';

class ServicesScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeServices,
      uri: '/conn/{alias}/services/{filter}',
      lastArgOptional: true,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => ServicesScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = ServicesScreen.route.extractNamedArgs(context);
    var title = 'Services';
    if (groups.containsKey('alias')) {
      if (groups.containsKey('filter')) {
        switch (groups['filter']) {
          case 'all':
            title = "Services";
            break;
          default:
            title = "Services ${groups["filter"]}";
        }
      } else {
        title = "Services";
      }
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final groups = ServicesScreen.route.extractNamedArgs(context);
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    var filter = <String>[];
    switch (groups['filter']) {
      case 'problems':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateWarn}"}');
        break;
      case 'unhandled':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateCritical}"}');
        break;
      case 'stale':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateUnknown}"}');
        break;
      case 'all':
        break;
      default:
        if (groups['filter'] != null) {
          filter.add(groups['filter']!);
        }
    }

    return BlocProvider<ServicesBloc>(
      create: (context) =>
          ServicesBloc(alias: groups['alias']!, filter: filter, sBloc: sBloc)
            ..add(ServicesStartFetching()),
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          return BlocBuilder<CommentsBloc, CommentsState>(
            builder: (cContext, cState) {
              final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
              if (state is ServicesStateFetched) {
                commentsFetchForServices(
                    context: context,
                    alias: groups['alias']!,
                    services: state.services);
                return Column(
                  children: [
                    SiteStatsWidget(
                        alias: groups['alias']!, state: cBloc.state),
                    Expanded(
                      child: ServicesListWidget(
                          alias: groups['alias']!, services: state.services),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SiteStatsWidget(
                        alias: groups['alias']!, state: cBloc.state),
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
