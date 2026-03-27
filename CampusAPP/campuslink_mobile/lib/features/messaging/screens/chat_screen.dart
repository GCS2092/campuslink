import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ChatScreen extends ConsumerWidget {
  final int conversationId;
  const ChatScreen({super.key, required this.conversationId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Chat #$conversationId')), body: Center(child: Text('Chat $conversationId')));
}
