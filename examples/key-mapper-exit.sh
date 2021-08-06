#!/bin/bash
#
# this needs to be placed in $PATH with name key-mapper-exit for key-mapper to find this
# likely you will want to place a copy or a symbolic link there:
# sudo ln -s /home/pi/key-mapper/examples/key-mapper-exit.sh /usr/bin/key-mapper-exit

modefile='/tmp/screenblankmode'
mode='-p'
host=''
macro=''


# Camera devices to send CURL to should best resolve in DNS, straight from 
# their names as mentioned in KEY-MAPPER
# User and Passwords for those devices are best stored in system .netrc file
# where CURL will find them automatically.
cam01='cam01'
cam02='cam02'
user=''
pass=''


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
	# Especially on RasPi 3B+ and 4B when in X it
	# seems needed to jitter fb a bit to redisplay
	fbset -move up -step 0
	fbset -a -move up -step 0
fi

# additional useful commands related to screen blanking
# (sometimes) works to repaint the buffer
#	fbset -move up -step 0
#	fbset -a -move up -step 0
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


# if mon01 command 
if [ "$1" == "mon01" ]; then

	# Quit Camplayer command
	if [ "$2" == "stop"  -o "$2" == "preset8" ]; then
		macro='k(KEY_Q)'
		#systemctl stop camplayer
	fi

	# Restart Camplayer command
	if [ "$2" == "restart"  -o "$2" == "preset9" ]; then
		# should not need sudo, as this runs as root
		systemctl restart camplayer
	fi
fi


# if camera command for either camera
if [ "$1" == "cam01" -o "$1" == "cam02" ]; then
	[ "$1" == "cam01" ] && host=$cam01
	[ "$1" == "cam02" ] && host=$cam02

	# Goto Preset command
	action=$2
	if [ "${action%%[0-9]*}" == "preset" ]; then
		# reminder: user/pass are not encoded here but done by --digest -n
		preset=${action//[!0-9]/}
		url="http://${host}/cgi-bin/ptz.cgi?action=start&channel=0&code=GotoPreset&arg1=0&arg2=${preset}&arg3=0"
		curl --digest -n -s -g -m 1 -- "${url}"
	fi

	# Restart Auto-Tracking command
	# note that Preset 10 is the same as Preset 1, but with auto-tracking activated
	if [ "$2" == "auto" ]; then
		url="http://${host}/cgi-bin/ptz.cgi?action=start&channel=0&code=GotoPreset&arg1=0&arg2=10&arg3=0"
		curl --digest -n -s -g -m 1 -- "${url}"
	fi
fi


echo $macro

exit 0

