var addr = "ffabious-healthy-summer.ru";
var authSubdomain = "auth";
var activitySubdomain = "activity";

var userUrl = 'https://$authSubdomain.$addr/api/users';
var loginEndpoint = '$userUrl/login';
var registerEndpoint = '$userUrl/register';
var userEndpoint = '$userUrl/me';

var activityUrl = 'https://$activitySubdomain.$addr/api/activities';
var postActivityEndpoint = activityUrl;
var getActivitiesEndpoint = activityUrl;