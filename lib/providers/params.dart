import 'package:flutter/foundation.dart' show listEquals;

final class SiteAndFilterParams {
  final String site;
  final List<String> filter;

  const SiteAndFilterParams({required this.site, required this.filter});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SiteAndFilterParams &&
        other.site == site &&
        listEquals(other.filter, filter);
  }

  @override
  int get hashCode => site.hashCode ^ filter.hashCode;

  @override
  String toString() => 'SiteAndFilterParams(site: $site, filter: $filter)';

  SiteAndFilterParams copyWith({
    String? site,
    List<String>? filter,
  }) {
    return SiteAndFilterParams(
      site: site ?? this.site,
      filter: filter ?? this.filter,
    );
  }
}