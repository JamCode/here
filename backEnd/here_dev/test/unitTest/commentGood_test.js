

var commentGoodJson = {
    childpath: 'commentGood',
    content_comment_id: 'commentGoodtest',
    user_id: 'commentGoodtest',
    comment_user_id: 'commentGoodtest',
    user_name: 'commentGoodtest'
};

var runner = require('unitTestRunner.js');
runner.runTest(commentGoodJson, commentGoodJson.childpath);
