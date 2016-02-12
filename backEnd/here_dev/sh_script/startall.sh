#!/bin/bash



#kill `<$HOME/dev/webServer.pid`
#kill `<$HOME/dev/socketServer.pid`

forever stop $HOME/here/backEnd/here_dev/server.js
forever stop $HOME/here/backEnd/here_dev/socket.js
forever stop $HOME/here/backEnd/here_dev/schedule.js
forever stop $HOME/here/backEnd/here_dev/webServer.js

forever cleanlogs

forever start -l server.log $HOME/here/backEnd/here_dev/server.js
forever start -l socket.log $HOME/here/backEnd/here_dev/socket.js
forever start -l schedule.log $HOME/here/backEnd/here_dev/schedule.js
forever start -l webServer.log $HOME/here/backEnd/here_dev/webServer.js


#nohup node $HOME/dev/here_dev/socket.js &
#nohup node $HOME/dev/here_dev/server.js &
