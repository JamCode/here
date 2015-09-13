#!/bin/sh
#show all application processes

ps -ef|grep `<$HOME/dev/webServer.pid`
ps -ef|grep `<$HOME/dev/socketServer.pid`
