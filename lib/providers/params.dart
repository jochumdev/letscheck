import 'package:flutter/foundation.dart' show listEquals;

final class AliasAndFilterParams {
  final String alias;
  final List<String> filter;

  const AliasAndFilterParams({required this.alias, required this.filter});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AliasAndFilterParams &&
        other.alias == alias &&
        listEquals(other.filter, filter);
  }

  @override
  int get hashCode => alias.hashCode ^ filter.hashCode;

  @override
  String toString() => 'AliasAndFilterParams(alias: $alias, filter: $filter)';

  AliasAndFilterParams copyWith({
    String? alias,
    List<String>? filter,
  }) {
    return AliasAndFilterParams(
      alias: alias ?? this.alias,
      filter: filter ?? this.filter,
    );
  }
}