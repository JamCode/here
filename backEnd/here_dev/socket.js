var log = require('./utility/log');
log.SetLogFileName('logSocket_');
global.log = log; //  设置全局
var config = require('./config/config');

var global_config = null;

if (process.env.ENV === 'dev') {
    global_config = require('./config/dev_env_config');
}

if (process.env.ENV === 'pro') {
    global_config = require('./config/pro_env_config');
}

var instantMsgMgmt = require('./database/instantMsgMgmt');
var userMgmt = require('./database/userMgmt');
var conn = require('./database/utility.js');
var cluster = require('cluster');
var email = require('./utility/emailTool');
var redis = require('redis');
var redisClient = redis.createClient();
var fs = require('fs');
var async = require('async');

var socketPort = global_config.socketServerInfo.listen_port;

var encryp = require('./utility/encryption.js');

redisClient.on('error',
function (err) {
    log.error(err, log.getFileNameAndLineNum(__filename));
});

var userInfoHashKey = 'userInfoHashKey'; //  key is user_id, value is user_base_info include socket.id
var socketUserIdMap = 'socketUserIdMap'; //  key is socket.id, value is user_id, using for socket disconnect, delete user info
var path = require('path');

if (cluster.isMaster) {
    //  write pid to app.pid
    var pidfile = path.join(global_config.env.homedir, 'socketServer.pid');
    log.info(pidfile, log.getFileNameAndLineNum(__filename));

    fs.writeFileSync(pidfile, process.pid, {
        flag: 'w'
    });


    cluster.fork();
    cluster.on('exit',
    function (worker, code, signal) {
        log.error('socket worker ' + worker.process.pid + ' died, code is ' + code + ', signal is ' + signal, log.getFileNameAndLineNum(__filename));
        cluster.fork();

        email.sendMail('socket worker ' + worker.process.pid + ' died', 'socket process failed');

    });
    cluster.on('listening',
    function (worker, address) {
        log.info('A socket worker with pid#' + worker.process.pid + ' is now listening to:' + address.port, log.getFileNameAndLineNum(__filename));
    });

} else {

    process.on('uncaughtException',
    function (err) {
        log.error('SOCKET SERVER Caught exception: ' + err.stack, log.getFileNameAndLineNum(__filename));
        email.sendMail('SOCKET SERVER Caught exception: ' + err.stack, 'socket process failed');
    });

    startSocketServer();
}

//  exports.getUsersSocket = function (user_id) {
//      return usersSocket[user_id];
//  }
//  exports.getUsersID = function (user_socket) {
//      return usersID[user_socket];
//  }
function feedBack (flag, result, fn) {
    var returnData = {};
    if (flag) {
        returnData.code = config.returnCode.SUCCESS;
        returnData.data = result;
    } else {
        log.logPrint(config.logLevel.ERROR, result);
        returnData.code = config.returnCode.ERROR;
    }
    fn(returnData);
}

function register (user_id, socket) {
    redisClient.hset(userInfoHashKey, user_id, socket.id);
    redisClient.hset(socketUserIdMap, socket.id, user_id);
}

function insertPrivateMsgAndPushToFront (msg, io) {
    if (msg.voice_time === null) {
        msg.voice_time = 0;
    }

    log.debug('enter insertPrivateMsgAndPushToFront', log.getFileNameAndLineNum(__filename));

    instantMsgMgmt.insertPrivateMsg(msg.from, msg.to, msg.message, msg.msg_id, msg.msg_type, msg.datapath, msg.voice_time, msg.msg_srno,
    function (flag, result) {
        // check insert action
        if (!flag) {
            log.logPrint(config.logLevel.ERROR, result);
            // feedBack(flag, result, fn);
        } else {
            log.logPrint(config.logLevel.DEBUG, 'insertPrivateMsg SUCCESS');
            log.logPrint(config.logLevel.DEBUG, msg.msg_id);

            instantMsgMgmt.getMsgByID(msg.msg_id,
            function (flag, result) {
                if (flag) {
                    log.logPrint(config.logLevel.DEBUG, 'getMsgByID SUCCESS');

                    redisClient.hget(userInfoHashKey, msg.to,
                    function (err, reply) {
                        if (err) {
                            log.error(err, log.getFileNameAndLineNum(__filename));
                        } else {
                            if (reply !== null) {
                                var socketID = reply;
                                if (io.sockets.connected[socketID] !== null) {

                                    // send using socket
                                    io.sockets.connected[socketID].emit('msg', msg);

                                    log.debug(msg.from + ' send msg to ' + msg.to, log.getFileNameAndLineNum(__filename));
                                } else {
                                    log.debug('io.sockets.connected[socketID] is null', log.getFileNameAndLineNum(__filename));
                                }
                            } else {
                                log.debug('toSocket is null ' + msg.from + ' cannot send msg to ' + msg.to, log.getFileNameAndLineNum(__filename));
                            }
                        }
                    });

                    var item = result[0];

                    if (msg.msg_type === config.msgType.VOICEMSG) {
                        msg.message = '[语音]';
                    }

                    if (msg.msg_type === config.msgType.IMAGEMSG) {
                        msg.message = '[图片]';
                    }

                    log.info('push msg ' + msg.message, log.getFileNameAndLineNum(__filename));

                    var pushMsg = {
                        content: msg.from_name + ':' + msg.message,
                        msgtype: 'msg',
                        badge: item.count
                    };

                    // apn to user
                    conn.pushMsgToUsers(item.device_token, pushMsg);
                    userMgmt.updateDeviceNotifyCount(item.device_token, item.count + 1,
                    function (flag, result) {
                        if (!flag) {
                            log.error(result, log.getFileNameAndLineNum(__filename));
                        }
                    });
                } else {
                    log.error(result, log.getFileNameAndLineNum(__filename));
                }

                // feedBack(flag, result, fn);
            });
        }
    });
}

function getMissedMsgAsync (result, fn) {
    async.map(result,
    function (item, callback) {

        log.info(item.message_content, log.getFileNameAndLineNum(__filename));

        item.message_content = encryp.decode(item.message_content);

        if (item.msg_type === config.msgType.VOICEMSG || item.msg_type === config.msgType.IMAGEMSG) {
            fs.readFile(item.datapath, {
                encoding: 'utf8',
                flag: 'r'
            },
            function (err, data) {
                if (err) {
                    log.error(err + ' item.msg_id ' + item.msg_id, log.getFileNameAndLineNum(__filename));
                    item.data = null;
                } else {
                    item.data = data;
                }
                callback(null, item);
            });
        } else {
            // message type
            callback(null, item);
        }

    },
    function (err, result) {
        log.info('end getMissedMsgAsync', log.getFileNameAndLineNum(__filename));
        if (err) {
            feedBack(false, result, fn);
        } else {
            // log.info(JSON.stringify(result), log.getFileNameAndLineNum(__filename));
            feedBack(true, result, fn);
        }
    });
}

function startSocketServer () {

    var io = require('socket.io').listen(socketPort);
    log.logPrint(config.logLevel.DEBUG, 'start listen socket');
    io.sockets.on('connection',
    function (socket) {

        log.logPrint(config.logLevel.DEBUG, process.pid + ' get the socket:' + socket.id);

        socket.on('register',
        function (msg, fn) {
            log.logPrint(config.logLevel.INFO, JSON.stringify(msg));
            register(msg.user_id, socket);
            var user_id = msg.user_id;
            var counter_id = msg.counter_id;
            var lastTimeStamp = msg.lastTimeStamp;
            if (counter_id === null) {

                // get last send timestamp
                userMgmt.getMissedMsgRecord(user_id,
                function (flag, result) {
                    if (flag) {
                        if (result.length === 0) {
                            // insert first
                            userMgmt.insertMissedMsgRecord(user_id,
                            function (flag, result) {
                                if (flag) {
                                    feedBack(flag, {},
                                    fn);
                                } else {
                                    feedBack(flag, result, fn);
                                }
                            });
                        } else {
                            var lastTimeStamp = result[0].last_timestamp;
                            log.logPrint(config.logLevel.DEBUG, 'lastTimeStamp ' + lastTimeStamp);

                            instantMsgMgmt.getAllMissedMsg(user_id, lastTimeStamp,
                            function (flag, result) {
                                log.logPrint(config.logLevel.INFO, 'getAllMissedMsg');

                                if (flag === true) {
                                    getMissedMsgAsync(result, fn);
                                } else {
                                    feedBack(flag, result, fn);
                                }

                            });

                            userMgmt.updateMissedMsgRecord(user_id, null);
                        }
                    } else {
                        feedBack(flag, result, fn);
                    }
                });

            } else {
                instantMsgMgmt.getMissedMsg(user_id, counter_id, lastTimeStamp,
                function (flag, result) {
                    log.info('getMissedMsg', log.getFileNameAndLineNum(__filename));

                    if (flag) {
                        getMissedMsgAsync(result, fn);
                    } else {
                        feedBack(flag, result, fn);
                    }
                });
            }
        });

        socket.on('testACK',
        function (msg, callback) {
            log.logPrint(config.logLevel.DEBUG, 'testACK');
            callback(msg);
        });

        socket.on('msg',
        function (msg, fn) {
            log.info('msg ' + msg.from + ' to ' + msg.to, log.getFileNameAndLineNum(__filename));
            register(msg.from, socket);
            msg.timestamp = Date.now() / 1000;
            msg.msg_id = conn.sha1Cryp(msg.from + msg.to + msg.timestamp);
            log.logPrint(config.logLevel.DEBUG, 'msg_id ' + msg.msg_id);

            userMgmt.checkBlackList(msg.to, msg.from,
            function (flag, result) {
                if (flag) {
                    var returnData = {};
                    if (result.length > 0) {
                        // set black list, send refuse msg to msg.from
                        log.info(msg.to + ' set black list to ' + msg.from);
                        returnData.code = config.returnCode.BLACK_LIST;
                        fn(returnData);
                    } else {

                        // response first
                        returnData.code = config.returnCode.SUCCESS;
                        fn(returnData);

                        if (msg.msg_type === null) {
                            msg.msg_type = config.msgType.USERMSG;
                        }

                        if (msg.msg_type === config.msgType.VOICEMSG || msg.msg_type === config.msgType.IMAGEMSG) {

                            var fileName = '';

                            if (msg.msg_type === config.msgType.VOICEMSG) {
                                fileName = path.join(global_config.env.homedir, config.voiceInfo.voiceRootDir, msg.msg_id + Date.now() + '.mp3');
                            }

                            if (msg.msg_type === config.msgType.IMAGEMSG) {
                                fileName = path.join(global_config.env.homedir, config.msgImageInfo.msgImageInfoRootDir, msg.msg_id + Date.now() + '.jpg');
                            }

                            msg.datapath = fileName;
                            fs.open(fileName, 'w',
                            function (err, fd) {
                                if (err) {
                                    log.error(err, log.getFileNameAndLineNum(__filename));
                                    //  var returnData = {};
                                    //  returnData.code = config.returnCode.ERROR;
                                    //  fn(returnData);
                                } else {
                                    fs.write(fd, msg.data, 0, msg.data.length,
                                    function (err, written, buffer) {
                                        if (err) {
                                            log.error(err, log.getFileNameAndLineNum(__filename));
                                        } else {
                                            insertPrivateMsgAndPushToFront(msg, io);
                                        }
                                    });
                                }
                            });
                        } else {
                            insertPrivateMsgAndPushToFront(msg, io);
                        }
                    }
                } else {
                    // checkBlackList db error
                    feedBack(flag, result, fn);
                }
            });
        });

        socket.on('disconnect',
        function (msg) {
            log.debug(msg, log.getFileNameAndLineNum(__filename));

            redisClient.hget(socketUserIdMap, socket.id,
            function (err, reply) {
                if (err) {
                    log.error(err, log.getFileNameAndLineNum(__filename));
                } else {
                    if (reply === null) {
                        log.warn('reply is null', log.getFileNameAndLineNum(__filename));
                    } else {
                        var userID = reply;
                        if (userID !== undefined) {
                            redisClient.hdel(userInfoHashKey, userID);
                            redisClient.hdel(socketUserIdMap, socket.id);
                            log.debug(userID + ' disconnect', log.getFileNameAndLineNum(__filename));
                        }
                    }
                }
            });

            // delete io.sockets.sockets[socket.id];
            // delete socket;
            // socket.close();
        });
    });
}
