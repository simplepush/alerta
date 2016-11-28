#!/bin/sh

key="$1"
title="$2"
message="$3"
e="$4"

if [ -n "${e}" ]; then
	event="&event=${e}"
else
	event=""
fi

curl --data "key=${key}&title=${title}&msg=${message}${event}" "https://api.simplepush.io/send" > /dev/null 2>&1
if [ -n "$e" ]; then
	echo "Alert to ${key} with event ${e}: ${title} ${message}"
else
	echo "Alert to ${key}: ${title} ${message}"
fi
