var Json = {
    childpath: '/cancelFollowUser',
    user_id: '11111',
    followed_user_id: '999999999'
};

var runner = require('./unitTestRunner.js');
runner.runTest(Json, Json.childpath);
