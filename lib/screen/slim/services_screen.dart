import 'package:flutter/material.dart';
import 'base_slim_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            title = "${groups["alias"]} Services";
            break;
          default:
            title = "${groups["alias"]} Services ${groups["filter"]}";
        }
      } else {
        title = "${groups["alias"]} Services";
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
        filter.add('services_problems');
        break;
      case 'unhandled':
        filter.add('services_unhandled');
        break;
      case 'stale':
        filter.add('services_stale');
        break;
      default:
    }

    return BlocBuilder<CommentsBloc, CommentsState>(
        builder: (cContext, cState) {
      return BlocProvider<ServicesBloc>(
          create: (context) => ServicesBloc(
              alias: groups['alias']!, filter: filter, sBloc: sBloc)
            ..add(ServicesStartFetching()),
          child: BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
            if (state is ServicesStateFetched) {
              commentsFetchForServices(
                  context: context,
                  alias: groups['alias']!,
                  services: state.services);
              return ServicesListWidget(
                  alias: groups['alias']!, services: state.services);
            } else {
              return CenterLoadingWidget();
            }
          }));
    });
  }
}
