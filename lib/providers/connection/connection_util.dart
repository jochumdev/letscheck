import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/providers/connection/connection_state.dart';


Set<int> getCommentIdsToFetch(
    {required ConnectionLoaded state,
    required String site,
    required List<cmk_api.Service> services}) {

  var ids = <int>{};
  final comments = state.comments;

  for (final service in services) {
    for (final id in service.comments!) {
      if (!comments.containsKey(id)) {
        ids.add(id);
      }
    }
  }

  return ids;
}
