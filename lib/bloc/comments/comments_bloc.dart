import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SettingsBloc sBloc;

  CommentsBloc({required this.sBloc}) : super(const CommentsStateImpl(comments: {})) {
    on<CommentsFetchIds>((event, emit) async {
      await _fetchIds(event.alias, event.ids);
    });

    on<CommentsGotIds>((event, emit) async {
      if (state is! CommentsStateImpl) {
        emit(CommentsStateImpl(comments: {event.alias: event.comments}));
      } else {
        final currentState = state as CommentsStateImpl;
        final comments = Map<String, Map<num, cmk_api.Comment>>.from(currentState.comments);
        comments[event.alias] = event.comments;
        emit(CommentsStateImpl(comments: comments));
      }
    });
  }

  Future<void> _fetchIds(String alias, List<num> ids) async {
    if (!sBloc.state.connections.containsKey(alias)) {
      return;
    }

    if (sBloc.state.connections[alias]!.state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias]!.client!;
    final filter = ids.map((id) => '{"op": "=", "left": "id", "right": "$id"}').toList();

    try {
      final comments = await client.getApiComments(filter: filter);
      var result = <num, cmk_api.Comment>{};
      for (var comment in comments) {
        result[comment.id] = comment;
      }
      add(CommentsGotIds(alias: alias, comments: result));
    } on cmk_api.NetworkError catch (e) {
      sBloc.add(ConnectionFailed(alias, e));
    }
  }
}
