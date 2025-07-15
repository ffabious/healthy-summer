var addr = "ffabious-healthy-summer.ru";
var userSubdomain = "user";
var activitySubdomain = "activity";

// User Endpoints
var userUrl = 'https://$userSubdomain.$addr/api/users';
var loginEndpoint = '$userUrl/login';
var registerEndpoint = '$userUrl/register';
var userEndpoint = '$userUrl/me';
var friendsEndpoint = '$userUrl/friends';
var sendFriendRequestEndpoint = '$userUrl/friends/request';
var achievementsEndpoint = '$userUrl/achievements';
var profileEndpoint = '$userUrl/profile';

// Activity Endpoints
var activityUrl = 'https://$activitySubdomain.$addr/api/activities';
var postActivityEndpoint = activityUrl;
var getActivitiesEndpoint = activityUrl;
var postStepEntryEndpoint = '$activityUrl/steps';