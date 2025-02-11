import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:talker_flutter/talker_flutter.dart';

class LogScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talker = ref.read(talkerProvider);
    return TalkerScreen(talker: talker);
  }
}
