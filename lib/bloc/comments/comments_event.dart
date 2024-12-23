import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

abstract class CommentsEvent extends Equatable {}

class CommentsFetchIds extends CommentsEvent {
  final String alias;
  final List<num> ids;
  final List<String> columns;

  CommentsFetchIds(
      {required this.alias,
      required this.ids,
      this.columns = const [
        'id',
        'author',
        'comment',
        'description',
        'entry_time',
        'entry_type'
      ]});

  @override
  List<Object> get props => [alias, ids, columns];

  @override
  String toString() => '$alias: Comments fetch ids: ${ids.toString()}';
}

class CommentsGotIds extends CommentsEvent {
  final String alias;
  final BuiltMap<num, cmkApi.LqlTableCommentsDto> comments;

  CommentsGotIds({required this.alias, required this.comments});

  @override
  List<Object> get props => [alias, comments];

  @override
  String toString() => '$alias: Got comments';
}
