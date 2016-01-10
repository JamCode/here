var Json = {
    childpath: '/getFansUser',
    followed_user_id: '11111',
    follow_timestamp: 999999999
};

var runner = require('./unitTestRunner.js');
runner.runTest(Json, Json.childpath);
