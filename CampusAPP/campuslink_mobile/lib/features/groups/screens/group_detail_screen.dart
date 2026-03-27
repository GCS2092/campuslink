import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class GroupDetailScreen extends ConsumerWidget {
  final int groupId;
  const GroupDetailScreen({super.key, required this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Groupe #$groupId')), body: Center(child: Text('Detail groupe $groupId')));
}
