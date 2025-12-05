import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'event_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedService _feedService = FeedService();
  List<FeedItem> _feedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final items = await _feedService.getPersonalizedFeed();
      setState(() {
        _feedItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading feed: $e');
      setState(() {
        _feedItems = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune actualité',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _feedItems.length,
                    itemBuilder: (context, index) {
                      final item = _feedItems[index];
                      return _FeedItemCard(
                        item: item,
                        onTap: () {
                          if (item.type == 'event' && item.eventData != null) {
                            final eventId = item.eventData!['id']?.toString();
                            if (eventId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(eventId: eventId),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const _FeedItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image != null && item.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.image!.startsWith('http')
                      ? item.image!
                      : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${item.image}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.border,
                      child: const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.author != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            item.author!.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.author!.fullName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  if (item.author != null) const SizedBox(height: 8),
                  if (item.title != null)
                    Text(
                      item.title!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  if (item.title != null) const SizedBox(height: 8),
                  if (item.content != null)
                    Text(
                      item.content!,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      DateFormat('dd MMMM yyyy à HH:mm').format(item.createdAt!),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

