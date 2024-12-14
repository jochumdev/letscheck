import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'comments_state.dart';
import 'comments_event.dart';
import '../settings/settings.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SettingsBloc sBloc;

  CommentsBloc({required this.sBloc}) : super(CommentsState.init()) {
    on<CommentsFetchIds>((event, emit) async {
      await _fetchIds(
          alias: event.alias, ids: event.ids, columns: event.columns);
    });

    on<CommentsGotIds>((event, emit) async {
      if (state.comments.containsKey(event.alias)) {
        emit(state.rebuild((b) => b
          ..comments[event.alias]!
              .rebuild((b) => b.addAll(event.comments.toMap()))));
      } else {
        emit(state.rebuild((b) => b..comments[event.alias] = event.comments));
      }
    });
  }

  Future<void> _fetchIds(
      {required String alias,
      required List<num> ids,
      required List<String> columns}) async {
    if (!sBloc.state.connections.containsKey(alias)) {
      return;
    }

    if (sBloc.state.connections[alias]!.state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias]!.client!;

    var filter = <String>[];
    ids.forEach((id) {
      filter.add('Filter: id = $id');
    });
    filter.add('Or: ${ids.length}');

    try {
      final comments =
          await client.lqlGetTableComments(filter: filter, columns: columns);
      var result = <num, cmkApi.LqlTableCommentsDto>{};
      comments.forEach((comment) {
        result[comment.id!] = comment;
      });
      add(CommentsGotIds(alias: alias, comments: BuiltMap(result)));
    } on cmkApi.CheckMkBaseError catch (e) {
      sBloc.add(ConnectionFailed(alias, e));
    }
  }
}
