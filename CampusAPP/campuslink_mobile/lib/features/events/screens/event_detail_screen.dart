import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class EventDetailScreen extends ConsumerWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Evenement #$eventId')), body: Center(child: Text('Detail evenement $eventId')));
}
