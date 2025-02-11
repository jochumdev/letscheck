import 'package:equatable/equatable.dart';

final class AliasAndFilterParams extends Equatable {
  final String alias;
  final List<String> filter;

  const AliasAndFilterParams({required this.alias, required this.filter});

  @override
  List<Object?> get props => [alias, filter];

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