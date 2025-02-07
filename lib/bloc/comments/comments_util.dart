import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/bloc/comments/comments_state.dart';
import 'comments_bloc.dart';
import 'comments_event.dart';

void commentsFetchForServices(
    {required BuildContext context,
    required String alias,
    required List<cmk_api.Service> services}) {
  final cBloc = BlocProvider.of<CommentsBloc>(context);



  var ids = <num>[];
  if (cBloc.state is CommentsStateImpl) {
    final comments = (cBloc.state as CommentsStateImpl).comments;

    for (var service in services) {
      if (!comments.containsKey(alias)) {
        ids.addAll(service.comments!);
      } else {
        for (var id in service.comments!) {
          if (!comments[alias]!.containsKey(id)) {
            ids.add(id);
          } else {}
        }
      }
    }
  }

  // We haven't found some comments, fetch them.
  if (ids.isNotEmpty) {
    cBloc.add(CommentsFetchIds(alias: alias, ids: ids));
  }
}
