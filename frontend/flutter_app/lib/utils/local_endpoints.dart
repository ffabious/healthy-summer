var addr = "10.91.53.110";
var userPort = "8084";
var activityPort = "8081";

var userUrl = 'https://$addr:$userPort/api';
var loginEndpoint = '$userUrl/users/login';
var registerEndpoint = '$userUrl/users/register';
var userEndpoint = '$userUrl/users/me';

var activityUrl = 'https://$addr:$activityPort/api';
var postActivityEndpoint = '$activityUrl/activities';
var getActivitiesEndpoint = '$activityUrl/activities';