#!/bin/sh -x
echo Starting XPRA server
mkdir -p /home/user/.ssh/ || echo exit 99
chown -R user:user /home/user || echo exit 98
/usr/sbin/sshd && rm -f /tmp/.X100-lock || echo exit 97
su user -c " xpra start :100 --daemon=no --bind-tcp=0.0.0.0:9899 --tcp-auth=file,filename=/home/user/password.txt --html=on \
	--start-child='rxvt' --exit-with-children=yes --sharing=yes"

