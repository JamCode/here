var getUnreadCommentGoodJson = {
    childpath: '/getUnreadCommentGood',
    comment_user_id: 'c186c03ba298bc3cc20490684010a353',
    cgbi_timestamp: 1447906691
};

var runner = require('./unitTestRunner.js');
runner.runTest(getUnreadCommentGoodJson, getUnreadCommentGoodJson.childpath);
