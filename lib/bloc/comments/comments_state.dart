import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:built_value/built_value.dart';

part 'comments_state.g.dart';

abstract class CommentsState
    implements Built<CommentsState, CommentsStateBuilder> {
  CommentsState._();
  factory CommentsState([void Function(CommentsStateBuilder) updates]) =
      _$CommentsState;

  BuiltMap<String, BuiltMap<num, cmk_api.TableCommentsDto>> get comments;

  factory CommentsState.init() => CommentsState((b) => b);
}
