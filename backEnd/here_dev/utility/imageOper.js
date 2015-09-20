var gm = require('gm').subClass({ imageMagick: true });
var fs = require('fs');
var log = global.log;




exports.updateImage = function(origfilePath, fullFileName, fullFileNameCompress, minSize)
{


	fs.rename(origfilePath, fullFileName, function(err){
		var returnData = {};
		if (err) {
			log.error("fs.rename error " + err, log.getFileNameAndLineNum(__filename));
		}else{
			
			log.info(fullFileName, log.getFileNameAndLineNum(__filename));
			gm(fullFileName).size(function(err, size){
				if (!err) {
					log.info("width:"+size.width+", height:"+size.height, log.getFileNameAndLineNum(__filename));
					if(size.width<minSize.width||size.height<minSize.height){
						gm(fullFileName).resize(size.width, size.height, '!').write(fullFileNameCompress, function (err) {
		  						if (err) {
		  							log.error(err, log.getFileNameAndLineNum(__filename));
		  						}

		  						log.info("compress size: width "+ size.width+ " height "+size.height );
							});
					}else{
						if(size.width>size.height){

						
							gm(fullFileName).resize(minSize.height*size.width/size.height, minSize.height, '!').write(fullFileNameCompress, function (err) {
		  						if (err) {
		  							log.error(err, log.getFileNameAndLineNum(__filename));
		  						}

		  						log.info("compress size: width "+ minSize.height*size.width/size.height+ " height "+minSize.height );
							});


						}else{

							gm(fullFileName).resize(minSize.width, minSize.width*size.height/size.width, '!').write(fullFileNameCompress, function (err) {
		  						if (err) {
		  							log.error(err, log.getFileNameAndLineNum(__filename));
		  						}

		  						log.info("compress size: width "+minSize.width+"  height "+ minSize.width*size.height/size.width);
							});
						}
					}

					

				}else{
					log.error(err, log.getFileNameAndLineNum(__filename));
				}
			});				
		}
	});
}

