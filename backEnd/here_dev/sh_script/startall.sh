#!/bin/bash



#kill `<$HOME/dev/webServer.pid`
#kill `<$HOME/dev/socketServer.pid`

forever stop $HOME/dev/here_dev/server.js
forever stop $HOME/dev/here_dev/socket.js

forever cleanlogs

forever start -l server.log $HOME/dev/here_dev/server.js
forever start -l socket.log $HOME/dev/here_dev/socket.js


#nohup node $HOME/dev/here_dev/socket.js &
#nohup node $HOME/dev/here_dev/server.js &
