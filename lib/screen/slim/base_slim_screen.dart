import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/connection_data/connection_data.dart';
import '../../bloc/settings/settings.dart';
import '../../widget/site_stats_widget.dart';
import 'custom_search_delegate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../notifications/plugin.dart';

class BaseSlimScreenSettings {
  final String title;
  final bool showSettings;
  final bool showMenu;
  final bool showLeading;
  final bool showSearch;

  BaseSlimScreenSettings(this.title,
      {this.showSettings = false,
      this.showMenu = true,
      this.showLeading = true,
      this.showSearch = true});
}

abstract class BaseSlimScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<void> leadingButtonAction(context) async {
    Navigator.of(context).pop();
  }

  Widget content(BuildContext context);

  BaseSlimScreenSettings setup(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final settings = setup(context);

    var drawer = Drawer(
      child: BlocBuilder<ConnectionDataBloc, ConnectionDataState>(
          builder: (context, state) {
        final sBloc = BlocProvider.of<SettingsBloc>(context);
        return ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: false,
            itemCount: sBloc.state.connections.length,
            itemBuilder: (context, index) {
              return SiteStatsWidget(
                      alias: sBloc.state.connections.keys.toList()[index],
                      state: state)
                  .build(context);
            });
      }),
    );

    Widget leading;
    if (settings.showMenu) {
      leading = IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            if (_scaffoldKey.currentState != null) {
              if (_scaffoldKey.currentState!.isDrawerOpen == false) {
                _scaffoldKey.currentState!.openDrawer();
              } else {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            }
          });
    } else {
      leading = IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () async {
          await leadingButtonAction(context);
        },
      );
    }

    var actions = <Widget>[];
    actions.add(IconButton(
        onPressed: () async {
          const androidNotificationDetails = AndroidNotificationDetails(
              'your channel id', 'your channel name',
              icon: 'app_icon',
              channelDescription: 'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
          const notificationDetails =
              NotificationDetails(android: androidNotificationDetails);
          await flutterLocalNotificationsPlugin.show(notificationId++,
              'plain title', 'plain body', notificationDetails,
              payload: 'item x');
        },
        icon: Icon(Icons.alarm)));

    if (settings.showSettings) {
      actions.add(IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.of(context).pushNamed('/settings');
        },
      ));
    }

    if (settings.showSearch) {
      actions.add(IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showSearch(context: context, delegate: CustomSearchDelegate());
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing:
            settings.showLeading ? 0 : NavigationToolbar.kMiddleSpacing,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/check_mk.png',
              width: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Let\'s Check', style: TextStyle(fontSize: 14)),
                Text(settings.title,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        automaticallyImplyLeading: false,
        leading: settings.showLeading ? leading : null,
        actions: actions,
      ),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: drawer,
        drawerEnableOpenDragGesture: true,
        body: content(context),
      ),
    );
  }
}
