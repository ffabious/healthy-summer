class PostActivityRequestModel {
  final String type;
  final int durationMin;
  final String intensity;
  final int calories;
  final String? location;
  final DateTime timestamp;

  PostActivityRequestModel({
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.calories,
    this.location,
    required this.timestamp,
  });

  factory PostActivityRequestModel.fromJson(Map<String, dynamic> json) {
    return PostActivityRequestModel(
      type: json['type'],
      durationMin: json['duration_min'].toDouble(),
      intensity: json['intensity'],
      calories: json['calories'].toDouble(),
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration_min': durationMin,
      'intensity': intensity,
      'calories': calories,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class UpdateActivityRequestModel {
  final String type;
  final int durationMin;
  final String intensity;
  final int calories;
  final String? location;

  UpdateActivityRequestModel({
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.calories,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration_min': durationMin,
      'intensity': intensity,
      'calories': calories,
      'location': location,
    };
  }

  factory UpdateActivityRequestModel.fromActivity(ActivityModel activity) {
    return UpdateActivityRequestModel(
      type: activity.type,
      durationMin: activity.durationMin,
      intensity: activity.intensity,
      calories: activity.calories,
      location: activity.location,
    );
  }
}

class PostActivityResponseModel {
  final String id;
  final String userId;
  final String type;
  final int durationMin;
  final String intensity;
  final int calories;
  final String? location;
  final DateTime timestamp;

  PostActivityResponseModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.calories,
    this.location,
    required this.timestamp,
  });

  factory PostActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return PostActivityResponseModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      durationMin: json['duration_min'],
      intensity: json['intensity'],
      calories: json['calories'],
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'duration_min': durationMin,
      'intensity': intensity,
      'calories': calories,
      'location': location,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }
}

class ActivityModel {
  final String id;
  final String type;
  final int durationMin;
  final String intensity;
  final int calories;
  final String? location;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.calories,
    this.location,
    required this.timestamp,
  });

  factory ActivityModel.fromResponse(PostActivityResponseModel response) {
    return ActivityModel(
      id: response.id,
      type: response.type,
      durationMin: response.durationMin,
      intensity: response.intensity,
      calories: response.calories,
      location: response.location,
      timestamp: response.timestamp,
    );
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      type: json['type'],
      durationMin: json['duration_min'],
      intensity: json['intensity'],
      calories: json['calories'],
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'duration_min': durationMin,
      'intensity': intensity,
      'calories': calories,
      'location': location,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }
}

class GetActivitiesRequestModel {
  final String userId;

  GetActivitiesRequestModel({required this.userId});

  factory GetActivitiesRequestModel.fromJson(Map<String, dynamic> json) {
    return GetActivitiesRequestModel(userId: json['user_id']);
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}

class GetActivitiesResponseModel {
  final List<ActivityModel> activities;

  const GetActivitiesResponseModel({required this.activities});

  factory GetActivitiesResponseModel.fromJson(List<dynamic> json) {
    return GetActivitiesResponseModel(
      activities: json.map((item) => ActivityModel.fromJson(item)).toList(),
    );
  }

  List<dynamic> toJson() =>
      activities.map((activity) => activity.toJson()).toList();

  // Helper method to get recent activities (sorted by timestamp)
  List<ActivityModel> getRecentActivities({int limit = 3}) {
    final sortedActivities = List<ActivityModel>.from(activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities.take(limit).toList();
  }

  // Helper method to get activities by type
  List<ActivityModel> getActivitiesByType(String type) {
    return activities
        .where((activity) => activity.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  // Helper method to get total calories
  int get totalCalories {
    return activities.fold(0, (sum, activity) => sum + activity.calories);
  }

  // Helper method to get total duration
  int get totalDurationMin {
    return activities.fold(0, (sum, activity) => sum + activity.durationMin);
  }

  @override
  String toString() {
    return 'GetActivitiesResponseModel(activities: ${activities.length} items)';
  }
}

class PostStepEntryRequestModel {
  final int steps;
  final DateTime date;

  PostStepEntryRequestModel({required this.steps, required this.date});

  Map<String, dynamic> toJson() {
    return {'steps': steps, 'date': date.toUtc().toIso8601String()};
  }

  factory PostStepEntryRequestModel.fromJson(Map<String, dynamic> json) {
    return PostStepEntryRequestModel(
      steps: json['steps'],
      date: DateTime.parse(json['date'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'steps': steps, 'date': date.toUtc().toIso8601String()};
  }
}

class PostStepEntryResponseModel {
  final String id;
  final String userId;
  final int steps;
  final DateTime date;

  PostStepEntryResponseModel({
    required this.id,
    required this.userId,
    required this.steps,
    required this.date,
  });

  factory PostStepEntryResponseModel.fromJson(Map<String, dynamic> json) {
    return PostStepEntryResponseModel(
      id: json['id'],
      userId: json['user_id'],
      steps: json['steps'],
      date: DateTime.parse(json['date']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'steps': steps,
      'date': date.toUtc().toIso8601String(),
    };
  }
}
