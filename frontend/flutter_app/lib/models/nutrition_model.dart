class PostMealRequestModel {
  final String name;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fats;

  PostMealRequestModel({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
    };
  }
}

class PostMealResponseModel {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fats;
  final DateTime timestamp;

  PostMealResponseModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
    required this.timestamp,
  });

  factory PostMealResponseModel.fromJson(Map<String, dynamic> json) {
    return PostMealResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class GetMealsResponseModel {
  final List<PostMealResponseModel> meals;

  GetMealsResponseModel({required this.meals});

  factory GetMealsResponseModel.fromJson(dynamic json) {
    List<dynamic> mealsJson;

    if (json is List) {
      mealsJson = json;
    } else if (json is Map && json.containsKey('meals')) {
      mealsJson = json['meals'] as List;
    } else {
      throw Exception('Invalid JSON format for meals');
    }

    List<PostMealResponseModel> mealsList = mealsJson
        .map(
          (meal) =>
              PostMealResponseModel.fromJson(meal as Map<String, dynamic>),
        )
        .toList();

    // Sort by timestamp in descending order (most recent first)
    mealsList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return GetMealsResponseModel(meals: mealsList);
  }
}

// Water Intake Models
class PostWaterIntakeRequestModel {
  final int amount;

  PostWaterIntakeRequestModel({required this.amount});

  Map<String, dynamic> toJson() {
    return {
      'volume_ml': amount.toDouble(),
    };
  }
}

class PostWaterIntakeResponseModel {
  final String id;
  final double volumeMl;
  final DateTime timestamp;

  PostWaterIntakeResponseModel({
    required this.id,
    required this.volumeMl,
    required this.timestamp,
  });

  factory PostWaterIntakeResponseModel.fromJson(Map<String, dynamic> json) {
    return PostWaterIntakeResponseModel(
      id: json['id'] as String,
      volumeMl: (json['volume_ml'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// Preset Meal Model
class PresetMeal {
  final String name;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fats;

  const PresetMeal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
  });

  PostMealRequestModel toPostMealRequest() {
    return PostMealRequestModel(
      name: name,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fats: fats,
    );
  }
}

// Nutrition Stats Models
class NutritionStats {
  final NutritionPeriod today;
  final NutritionPeriod week;
  final NutritionPeriod month;
  final NutritionPeriod total;

  NutritionStats({
    required this.today,
    required this.week,
    required this.month,
    required this.total,
  });

  factory NutritionStats.fromJson(Map<String, dynamic> json) {
    return NutritionStats(
      today: NutritionPeriod.fromJson(json['today'] as Map<String, dynamic>),
      week: NutritionPeriod.fromJson(json['week'] as Map<String, dynamic>),
      month: NutritionPeriod.fromJson(json['month'] as Map<String, dynamic>),
      total: NutritionPeriod.fromJson(json['total'] as Map<String, dynamic>),
    );
  }
}

class NutritionPeriod {
  final int mealCount;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final double totalWaterMl;

  NutritionPeriod({
    required this.mealCount,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalWaterMl,
  });

  factory NutritionPeriod.fromJson(Map<String, dynamic> json) {
    return NutritionPeriod(
      mealCount: json['meal_count'] as int,
      totalCalories: json['total_calories'] as int,
      totalProtein: (json['total_protein'] as num).toDouble(),
      totalCarbs: (json['total_carbohydrates'] as num).toDouble(),
      totalFats: (json['total_fats'] as num).toDouble(),
      totalWaterMl: (json['total_water_ml'] as num).toDouble(),
    );
  }

  // Helper methods for display
  double get totalWaterL => totalWaterMl / 1000.0;

  String get formattedWater => totalWaterL < 1
      ? '${totalWaterMl.toStringAsFixed(0)} ml'
      : '${totalWaterL.toStringAsFixed(2)} L';
}

// Water Entries Response Model
class GetWaterEntriesResponseModel {
  final List<PostWaterIntakeResponseModel> waterEntries;

  GetWaterEntriesResponseModel({required this.waterEntries});

  factory GetWaterEntriesResponseModel.fromJson(Map<String, dynamic> json) {
    var entriesJson = json['water_entries'] as List;
    List<PostWaterIntakeResponseModel> entriesList = entriesJson
        .map(
          (entry) => PostWaterIntakeResponseModel.fromJson(
            entry as Map<String, dynamic>,
          ),
        )
        .toList();

    return GetWaterEntriesResponseModel(waterEntries: entriesList);
  }
}
