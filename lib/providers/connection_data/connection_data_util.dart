import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:letscheck/providers/connection_data/connection_data_state.dart';

Set<int> getCommentIdsToFetch(
    {required ConnectionDataLoaded state,
    required String alias,
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
