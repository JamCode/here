var Json = {
    childpath: '/getfollowContent',
    user_id: '112233',
    timestamp: 9999999999
};

var runner = require('./unitTestRunner.js');
runner.runTest(Json, Json.childpath);
