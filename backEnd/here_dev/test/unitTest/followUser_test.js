var followUserJson = {
    childpath: '/followUser',
    user_id: '112233',
    user_name: 'jam',
    followed_user_id: '223344'
};

var runner = require('./unitTestRunner.js');
runner.runTest(followUserJson, followUserJson.childpath);
