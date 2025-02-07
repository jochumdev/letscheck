import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

sealed class CommentsState {
  final Map<String, Map<num, cmk_api.Comment>> comments;

  const CommentsState({required this.comments});
}

final class CommentsStateImpl extends CommentsState {
  const CommentsStateImpl({required super.comments});
}
