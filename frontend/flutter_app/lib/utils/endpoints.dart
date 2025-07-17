var addr = "ffabious-healthy-summer.ru";
var userSubdomain = "user";
var activitySubdomain = "activity";
var nutritionSubdomain = "nutrition";

// User Endpoints
var userUrl = 'https://$userSubdomain.$addr/api/users';
var loginEndpoint = '$userUrl/login';
var registerEndpoint = '$userUrl/register';
var userEndpoint = '$userUrl/me';
var friendsEndpoint = '$userUrl/friends';
var sendFriendRequestEndpoint = '$userUrl/friends/request';
var getPendingFriendRequestsEndpoint = '$userUrl/friends/requests';
var respondToFriendRequestEndpoint = '$userUrl/friends/respond';
var searchUsersEndpoint = '$userUrl/search';
var achievementsEndpoint = '$userUrl/achievements';
var profileEndpoint = '$userUrl/profile';

// Activity Endpoints
var activityUrl = 'https://$activitySubdomain.$addr/api/activities';
var postActivityEndpoint = activityUrl;
var getActivitiesEndpoint = activityUrl;
var updateActivityEndpoint = activityUrl; // Used with /{id}
var deleteActivityEndpoint = activityUrl; // Used with /{id}
var postStepEntryEndpoint = '$activityUrl/steps';
var getStepEntriesEndpoint = '$activityUrl/steps';
var getActivityStatsEndpoint = '$activityUrl/stats';

// Nutrition Endpoints
var nutritionUrl = 'https://$nutritionSubdomain.$addr/api';
var postMealEndpoint = '$nutritionUrl/meals';
var getMealsEndpoint = '$nutritionUrl/meals';
var postWaterEndpoint = '$nutritionUrl/water';
var getWaterEndpoint = '$nutritionUrl/water';
var getNutritionStatsEndpoint = '$nutritionUrl/stats';
