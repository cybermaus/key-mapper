#!/bin/bash
#
# this needs to be placed in $PATH with name key-mapper-exit for key-mapper to find this
# likely you will want to place a copy or a symbolic link there:
# sudo ln -s /home/pi/key-mapper/examples/key-mapper-exit.sh /usr/bin/key-mapper-exit

modefile='/tmp/screenblankmode'
mode='-p'
host=''

# Camera devices to send CURL to should best resolve in DNS, straigt from 
# their names as mentioned in KEY-MAPPER
# User and Passwords for those devices are best stored in system .netrc file
# where CURL will find them automatically.
cam01='cam01'
cam02='cam02'


# Toggle screen blanking on or off
blank=$2
if [ "$2" == "toggleblank" ]; then
if [ -e $modefile ]; then 
	blank='screenunblank'
else
	blank='screenblank'
fi
fi

# Blank screen
if [ "$blank" == "screenblank" ]; then
	[ -e $modefile ] || tvservice -s > $modefile
	tvservice -o
fi

# Unblank screen
if [ "$blank" == "screenunblank" ]; then
	tvservice -p
	[ -e $modefile ] && rm $modefile
	# Especially on RasPi 3B+ and 4B  when in X it
	# seems needed to jitter fb a bit to redisplay
	fbset -move up -step 0
	fbset -match	
	fbset -a -move up -step 0
	fbset -a -match	
fi

# additional useful commands related to screen blanking
# (sometimes) works to repaint the buffer
#	fbset -a -move up -step 0
#	fbset -a -match
# Hide and Shows blinking cursor 	
#	sudo echo -e '\x1b[?25l' > /dev/tty1
#	sudo echo -e '\x1b[?25h' > /dev/tty1
# Blacks out the screen, no power off though
# ideally you first need to use fbset to calculate buffer size
#	dd if=/dev/zero of=/dev/fb0 bs=7056000
#	dd if=/dev/zero of=/dev/fb0
# Power off and on screen
# ideally you first use -s to remember what mode to restart
#	tvservice -o
#	tvservice -p


# goto camera presets
if [ "$1" == "$cam01" ]; then
	host=$cam01
fi
if [ "$1" == "$cam02" ]; then
	host=$cam02
fi

# if a preset command for either camera 
if [ "$1" == "cam01" -o "$1" == "cam02" ]; then
action=$2
if [ "${action%%[0-9]*}" == "preset" ]; then
	preset=${action//[!0-9]/}
	url="http://${host}/cgi-bin/ptz.cgi?action=start&channel=0&code=GotoPreset&arg1=0&arg2=${preset}&arg3=0"
	curl --digest -n -s -g -m 1 -- "${url}"
fi
fi

#echo $key-mapper-macro

exit 0

