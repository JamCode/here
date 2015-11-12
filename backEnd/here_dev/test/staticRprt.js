var fs = require('fs');
var path = require('path');
var util = require('util');
var EventEmitter = require('events').EventEmitter;
fs.exists = fs.exists || path.exists;
var mysql = require('mysql');
var conn = require('./utility.js');
var config = require('../config/config');


/**
 * Copy file, auto create tofile dir if dir not exists.
 *
 * @param {String} fromfile, Source file path.
 * @param {String} tofile, Target file path.
 * @param {Function(err)} callback
 * @public
 */
exports.copyfile = function copyfile(fromfile, tofile, callback) {
  fromfile = path.resolve(fromfile);
  tofile = path.resolve(tofile);
  if (fromfile === tofile) {
    var msg = 'cp: "' + fromfile + '" and "' + tofile + '" are identical (not copied).';
    return callback(new Error(msg));
  }
  exports.mkdir(path.dirname(tofile), function (err) {
    if (err) {
      return callback(err);
    }
    var ws = fs.createWriteStream(tofile);
    var rs = fs.createReadStream(fromfile);
    var onerr = function (err) {
      callback && callback(err);
      callback = null;
    };
    ws.once('error', onerr); // if file not open, these is only error event will be emit.
    rs.once('error', onerr);
    ws.on('close', function () {
      // after file open, error event could be fire close event before.
      callback && callback();
      callback = null;
    });
    rs.pipe(ws);
  });
};

/**
 * @private
 */
function _mkdir(dir, mode, callback) {
  fs.exists(dir, function (exists) {
    if (exists) {
      return callback();
    }
    fs.mkdir(dir, mode, callback);
  });
}

/**
 * mkdir if dir not exists, equal mkdir -p /path/foo/bar
 *
 * @param {String} dir
 * @param {Number} [mode] file mode, default is 0777.
 * @param {Function(err)} callback
 * @public
 */
exports.mkdir = function mkdir(dir, mode, callback) {
  if (typeof mode === 'function') {
    callback = mode;
    mode = 0777 & (~process.umask());
  }
  var parent = path.dirname(dir);
  fs.exists(parent, function (exists) {
    if (exists) {
      return _mkdir(dir, mode, callback);
    }
    exports.mkdir(parent, mode, function (err) {
      if (err) {
        return callback(err);
      }
      _mkdir(dir, mode, callback);
    });
  });
};
exports.mkdirp = exports.mkdir;


/**
 * Read stream data line by line.
 *
 * @constructor
 * @param {String|ReadStream} file File path or data stream object.
 */
function LineReader(file) {
  if (typeof file === 'string') {
    this.readstream = fs.createReadStream(file);
  } else {
    this.readstream = file;
  }
  this.remainBuffers = [];
  var self = this;
  this.readstream.on('data', function (data) {
    self.ondata(data);
  });
  this.readstream.on('error', function (err) {
    self.emit('error', err);
  });
  this.readstream.on('end', function () {
    self.emit('end');
  });
}
util.inherits(LineReader, EventEmitter);

/**
 * `Stream` data event handler.
 *
 * @param  {Buffer} data
 * @private
 */
LineReader.prototype.ondata = function (data) {
  var i = 0;
  var found = false;
  for (var l = data.length; i < l; i++) {
    if (data[i] === 10) {
      found = true;
      break;
    }
  }
  if (!found) {
    this.remainBuffers.push(data);
    return;
  }
  var line = null;
  if (this.remainBuffers.length > 0) {
    var size = i;
    var j, jl = this.remainBuffers.length;
    for (j = 0; j < jl; j++) {
      size += this.remainBuffers[j].length;
    }
    line = new Buffer(size);
    var pos = 0;
    for (j = 0; j < jl; j++) {
      var buf = this.remainBuffers[j];
      buf.copy(line, pos);
      pos += buf.length;
    }
    // check if `\n` is the first char in `data`
    if (i > 0) {
      data.copy(line, pos, 0, i);
    }
    this.remainBuffers = [];
  } else {
    line = data.slice(0, i);
  }
  this.emit('line', line);
  this.ondata(data.slice(i + 1));
};

/**
*定义一个Map
**/
function HashMap(){
    //定义长度
    var length = 0;
    //创建一个对象
    var obj = new Object();

    /**
    * 判断Map是否为空
    */
    this.isEmpty = function(){
        return length == 0;
    };

    /**
    * 判断对象中是否包含给定Key
    */
    this.containsKey=function(key){
        return (key in obj);
    };

    /**
    * 判断对象中是否包含给定的Value
    */
    this.containsValue=function(value){
        for(var key in obj){
            if(obj[key] == value){
                return true;
            }
        }
        return false;
    };

    /**
    *向map中添加数据
    */
    this.put=function(key,value){
        if(!this.containsKey(key)){
            length++;
        }
        obj[key] = value;
    };

    /**
    * 根据给定的Key获得Value
    */
    this.get=function(key){
        return this.containsKey(key)?obj[key]:null;
    };

    /**
    * 根据给定的Key删除一个值
    */
    this.remove=function(key){
        if(this.containsKey(key)&&(delete obj[key])){
            length--;
        }
    };

    /**
    * 获得Map中的所有Value
    */
    this.values=function(){
        var _values= new Array();
        for(var key in obj){
            _values.push(obj[key]);
        }
        return _values;
    };

    /**
    * 获得Map中的所有Key
    */
    this.keySet=function(){
        var _keys = new Array();
        for(var key in obj){
            _keys.push(key);
        }
        return _keys;
    };

    /**
    * 获得Map的长度
    */
    this.size = function(){
        return length;
    };

    /**
    * 清空Map
    */
    this.clear = function(){
        length = 0;
        obj = new Object();
    };
}

function daliyRprt(dirPath,fromFile){
  var dateStr = Date.now();
  console.log(dirPath+fromFile);
  var toFile = dirPath+fromFile+dateStr;
  exports.copyfile(dirPath+fromFile, toFile, function(err) {
  if (err) {
    throw err;
  }
  console.log('copy file success.');
  // clear access.log
  fs.writeFile(dirPath+fromFile,"",function (err) {
      if (err) throw err ;
   console.log("File Saved !"); //文件被保存
   }) ;
  var pvCount = 0;
  var uvCount = 0;
  //var uvMap = new HashMap();
  var uvMap = {};
   new LineReader(toFile).on('line', function(line) {
    //console.log('%d: %s', ++pvCount, line.toString());
	++pvCount;
	var lineStr =line.toString();
    var obj = new Array;
	obj = lineStr.split(" ");
	if(uvMap[obj[0].trim()]==null){
		uvCount++;
		uvMap[obj[0].trim()]=1;
	}
  }).on('end', function() {
	  var sql = "insert into daliy_report(pv_count,uv_count,timestamp,date)values(?,?,?,?)";
	  var timestamp = Date.now()/1000;
	  var date =  new Date();
	  var y = date.getFullYear();
	  var M = "0" + (date.getMonth() + 1);
	  M = M.substring(M.length - 2);
	  var d = "0" + date.getDate();
	  d = d.substring(d.length - 2);
	  var curDateStr = y+M+d;
	  var todayRprtDate = y+M+d+"-----[pvCount :"+pvCount+";uvCount:"+uvCount+"]";
	  //console.log('read a file done.');
	  conn.executeSql(sql, [pvCount, uvCount, timestamp,curDateStr], callback);
    //create rprtLog file
	  var rptLogNm= 'rptLog.txt';
	  exports.mkdir(path.dirname(dirPath+rptLogNm), function (err) {
		if (err) {
		  return callback(err);
		}
		fs.writeFile(dirPath+rptLogNm,todayRprtDate,function (err) {
        if (err) throw err ;
     console.log("File Saved !"); //文件被保存
     }) ;
  });
  }).on('error', function(err) {
    console.log('error: ', err.message)
  });
});
}
var fromFile ='access.log';//var dirPath = 'C:\\Users\\Micheal\\AppData\\Roaming\\npm\\node_modules\\';
var dirPath = '/home/wanghan/here/backEnd/here_dev/'
daliyRprt(dirPath,fromFile);