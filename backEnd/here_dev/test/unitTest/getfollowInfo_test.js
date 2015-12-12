var getfollowInfoJson = {
    childpath: '/getfollowInfo',
    user_id: '112233'
};

var runner = require('./unitTestRunner.js');
runner.runTest(getfollowInfoJson, getfollowInfoJson.childpath);
