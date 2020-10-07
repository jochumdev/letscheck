import 'dart:async';
import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'comments_state.dart';
import 'comments_event.dart';
import '../settings/settings.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SettingsBloc sBloc;

  CommentsBloc({@required this.sBloc}) : super(CommentsState.init());

  @override
  Stream<CommentsState> mapEventToState(CommentsEvent event) async* {
    if (event is CommentsFetchIds) {
      await this._fetchIds(
          alias: event.alias, ids: event.ids, columns: event.columns);
    }

    if (event is CommentsGotIds) {
      if (state.comments == null) {
        Map<String, BuiltMap<num, cmkApi.LqlTableCommentsDto>> result = Map();
        result[event.alias] = event.comments;
        yield state.rebuild((b) => b..comments.addAll(result));
      } else if (!state.comments.containsKey(event.alias)) {
        yield state.rebuild((b) => b..comments[event.alias] = event.comments);
      } else {
        yield state.rebuild((b) => b
          ..comments[event.alias]
              .rebuild((b) => b.addAll(event.comments.toMap())));
      }
    }
  }

  Future<void> _fetchIds(
      {String alias, List<num> ids, List<String> columns}) async {
    if (!sBloc.state.connections.containsKey(alias)) {
      return;
    }

    if (sBloc.state.connections[alias].state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias].client;

    if (client == null) {
      // This should never happen
      return;
    }

    List<String> filter = List();
    ids.forEach((id) {
      filter.add("Filter: id = $id");
    });
    filter.add("Or: ${ids.length}");

    try {
      final comments =
          await client.lqlGetTableComments(filter: filter, columns: columns);
      Map<num, cmkApi.LqlTableCommentsDto> result = Map();
      comments.forEach((comment) {
        result[comment.id] = comment;
      });
      add(CommentsGotIds(alias: alias, comments: BuiltMap(result)));
    } on cmkApi.CheckMkBaseError catch (e) {
      sBloc.add(new ConnectionFailed(alias, e));
    }
  }
}
