import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/providers/search/search_state.dart';
import 'package:letscheck/providers/services/services_util.dart';
import 'package:letscheck/widget/host_card_widget.dart';
import 'package:letscheck/widget/services_grouped_card_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate()
      : super(
          searchFieldLabel: 'Search...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.colorScheme.brightness == Brightness.dark) {
      return theme.copyWith(
        primaryColor: theme.colorScheme.primary,
        secondaryHeaderColor: Colors.black,
        primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black),
      );
    } else {
      return theme;
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search_off),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'Search term must be longer than two letters.',
            ),
          )
        ],
      );
    }

    // Create a RiverPod ConsumerWidget
    return SearchResultView(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}

class SearchResultView extends ConsumerStatefulWidget {
  final String query;

  const SearchResultView({super.key, required this.query});

  @override
  ConsumerState<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends ConsumerState<SearchResultView> {
  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        ref.read(searchProvider.notifier).search(widget.query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchProvider);

    if (search is! SearchLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    var groupItems = <dynamic>[];
    search.hosts.forEach((alias, hosts) {
      for (var host in hosts) {
        groupItems
            .add({'group': '$alias: Hosts', 'alias': alias, 'host': host});
      }
    });
    search.services.forEach((alias, services) {
      final groupedServices =
          servicesGroupByHostname(services: services.toList());

      groupedServices.forEach((_, hServices) {
        groupItems.add({
          'group': '$alias: Services',
          'alias': alias,
          'services': hServices
        });
      });
    });

    if (groupItems.isEmpty) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Text(
                  'No Results Found.',
                ),
              ],
            ))
          ]);
    } else {
      return GroupedListView<dynamic, String>(
        elements: groupItems,
        groupBy: (element) => element['group'],
        groupComparator: (value1, value2) => value2.compareTo(value1),
        useStickyGroupSeparators: false,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (context, element) {
          if (element.containsKey('host')) {
            return HostCardWidget(
                alias: element['alias'], host: element['host']);
          }
          // Service
          return ServicesGroupedCardWidget(
              alias: element['alias'],
              groupName: element['services'][0].hostName,
              services: element['services']);
        },
      );
    }
  }
}
