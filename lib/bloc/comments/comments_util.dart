import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'comments_bloc.dart';
import 'comments_event.dart';

void commentsFetchForServices(
    {required BuildContext context,
    required String alias,
    required BuiltList<cmk_api.TableServicesDto> services}) {
  final cBloc = BlocProvider.of<CommentsBloc>(context);

  var ids = <num>[];
  for (var service in services) {
    if (!cBloc.state.comments.containsKey(alias)) {
      ids.addAll(service.comments!);
    } else {
      for (var id in service.comments!) {
        if (!cBloc.state.comments[alias]!.containsKey(id)) {
          ids.add(id);
        } else {}
      }
    }
  }
  if (ids.isNotEmpty) {
    cBloc.add(CommentsFetchIds(alias: alias, ids: ids));
  }
}
