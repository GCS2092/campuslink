import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_design.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../utils/toast_service.dart';
import '../widgets/skeleton_loader.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Actualités',
          style: PremiumDesign.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumDesign.spacingL,
                vertical: PremiumDesign.spacingM,
              ),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: PremiumDesign.spacingM),
                child: SkeletonListTile(),
              ),
            )
          : _feedItems.isEmpty
              ? Center(
                  child: PremiumCard(
                    padding: const EdgeInsets.all(PremiumDesign.spacingXXL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: PremiumDesign.spacingL),
                        Text(
                          'Aucune actualité',
                          style: PremiumDesign.titleMedium.copyWith(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumDesign.spacingL,
                      vertical: PremiumDesign.spacingM,
                    ),
                    itemCount: _feedItems.length,
                    itemBuilder: (context, index) {
                      final item = _feedItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: PremiumDesign.spacingM),
                        child: Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  ToastService.showInfo('Fonctionnalité à venir');
                                },
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Supprimer',
                                borderRadius: BorderRadius.circular(PremiumDesign.radiusL),
                              ),
                            ],
                          ),
                          child: _FeedItemCardPremium(
                            item: item,
                            isDark: isDark,
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _FeedItemCardPremium extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final bool isDark;

  const _FeedItemCardPremium({
    required this.item,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image si disponible
          if (item.image != null && item.image!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(PremiumDesign.radiusL),
              ),
              child: Image.network(
                item.image!.startsWith('http')
                    ? item.image!
                    : '${ApiService().baseUrl.replaceAll('/api', '')}${item.image}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.border,
                    child: Icon(
                      Icons.image,
                      size: 64,
                      color: isDark ? Colors.white38 : AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(PremiumDesign.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auteur
                if (item.author != null)
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            item.author!.username.isNotEmpty
                                ? item.author!.username[0].toUpperCase()
                                : 'U',
                            style: PremiumDesign.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: PremiumDesign.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.author!.fullName,
                              style: PremiumDesign.titleSmall.copyWith(
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.createdAt != null)
                              Text(
                                timeago.format(item.createdAt!, locale: 'fr'),
                                style: PremiumDesign.labelSmall.copyWith(
                                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                
                if (item.author != null) const SizedBox(height: PremiumDesign.spacingM),
                
                // Titre
                if (item.title != null)
                  Text(
                    item.title!,
                    style: PremiumDesign.headlineSmall.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                
                if (item.title != null) const SizedBox(height: PremiumDesign.spacingS),
                
                // Contenu
                if (item.content != null)
                  Text(
                    item.content!,
                    style: PremiumDesign.bodyLarge.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

