class FeedItem {
  final String userId;
  final String userName;
  final String activityType;
  final Map<String, dynamic> activityData;
  final DateTime createdAt;

  FeedItem({
    required this.userId,
    required this.userName,
    required this.activityType,
    required this.activityData,
    required this.createdAt,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      activityType: json['activity_type'] ?? '',
      activityData: Map<String, dynamic>.from(json['activity_data'] ?? {}),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'activity_type': activityType,
      'activity_data': activityData,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GetFeedResponseModel {
  final List<FeedItem> feedItems;

  GetFeedResponseModel({required this.feedItems});

  factory GetFeedResponseModel.fromJson(Map<String, dynamic> json) {
    var feedItemsList = json['feed_items'] as List<dynamic>? ?? [];
    List<FeedItem> feedItems = feedItemsList
        .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return GetFeedResponseModel(feedItems: feedItems);
  }

  Map<String, dynamic> toJson() {
    return {'feed_items': feedItems.map((item) => item.toJson()).toList()};
  }
}
