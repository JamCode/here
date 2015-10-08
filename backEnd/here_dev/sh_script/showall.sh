#!/bin/sh
#show all application processes

ps -ef|grep `<$HOME/webServer.pid`
ps -ef|grep `<$HOME/socketServer.pid`
