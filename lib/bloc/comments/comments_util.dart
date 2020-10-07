import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'comments_bloc.dart';
import 'comments_event.dart';

void commentsFetchForServices(
    {BuildContext context,
    String alias,
    BuiltList<cmkApi.LqlTableServicesDto> services}) {

  final cBloc = BlocProvider.of<CommentsBloc>(context);

  List<num> ids = List();
  services.forEach((service) {
    if (service.comments != null) {
      if (cBloc.state.comments == null || !cBloc.state.comments.containsKey(alias)) {
        ids.addAll(service.comments);
      } else {
        service.comments.forEach((id) {
          if (!cBloc.state.comments[alias].containsKey(id)) {
            ids.add(id);
          } else {
          }
        });
      }
    }
  });
  if (ids.length > 0) {
    cBloc.add(CommentsFetchIds(alias: alias, ids: ids));
  }
}
