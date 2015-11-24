#!/bin/sh
#show all application processes

ps -aux|grep `<$HOME/webServer.pid`
ps -aux|grep `<$HOME/socketServer.pid`
ps -aux|grep `<$HOME/schedule.pid`
