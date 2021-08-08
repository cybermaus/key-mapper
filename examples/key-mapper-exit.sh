#!/bin/bash
#
# this needs to be placed in $PATH with name key-mapper-exit for key-mapper to find this
# likely you will want to place a copy or a symbolic link there:
# sudo ln -s /home/pi/key-mapper/examples/key-mapper-exit.sh /usr/bin/key-mapper-exit

modefile='/tmp/screenblankmode'
mode='-p'
host=''
macro=''
timeout='300'


# Camera devices to send CURL to should best resolve in DNS, straight from 
# their names as mentioned in KEY-MAPPER
# User and Passwords for those devices are best stored in system .netrc file
# where CURL will find them automatically.
cam01='192.168.3.103'
cam02='192.168.3.68'
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
	[ -e $modefile ] && sudo -n rm -f $modefile
	# Especially on RasPi 3B+ and 4B when in X it
	# seems needed to prod fb a bit to redisplay
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
	
	# Restart Camplayer command
	if [ "$2" == "restart"  -o "$2" == "preset9" ]; then
		# should not need sudo, as this runs as root
		echo 'Restarting camplayer'
		sudo -n systemctl restart camplayer
	fi

	# Quit Camplayer command
	if [ "$2" == "stop"  -o "$2" == "preset8" ]; then
		macro='k(KEY_Q)'
		#echo 'Stopping camplayer'
		#sudo -n systemctl stop camplayer
	fi

	# Remove cache, force Cache rebuild on next restart
	if [ "$2" == "cache"  -o "$2" == "preset7" ]; then
		echo 'Rebuilding camplayer cache'
		rm -f /home/pi/.camplayer/cache/streaminfo
	fi

	# Power off RasPi completely
	if [ "$2" == "poweroff"  -o "$2" == "preset6" ]; then
		echo 'Powering off RasPi'
		[ -e $modefile ] && sudo -n rm -f $modefile
		sudo -n systemctl stop camplayer
		sudo -n poweroff
	fi
		
	# Channels 0 (auto), 1, 2, 3, 4) are camera display selections
	if [ "$2" == "auto" ]; then
		macro='k(KEY_0)'
	elif [ "$2" == "preset1" ]; then
		macro='k(KEY_1)'
	elif [ "$2" == "preset2" ]; then
		macro='k(KEY_2)'
	elif [ "$2" == "preset3" ]; then
		macro='k(KEY_3)'
	elif [ "$2" == "preset4" ]; then
		macro='k(KEY_4)'
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
		#echo "Preset ${url}"
		curl --digest -n -s -g -m 1 "${url}"
		# Also set channel 0 (=1-1) as auto-homing position
		url="http://${host}/cgi-bin/configManager.cgi?action=setConfig&Ptz[0].Homing[0]=0&Ptz[0].Homing[1]=${timeout}"
		curl --digest -n -s -g -m 1 -- "${url}"
	fi

	# Restart Auto-Tracking command
	# note that Preset 10 is the same as Preset 1, but with auto-tracking activated
	if [ "$2" == "auto" ]; then
		# Goto Preset 10 as Auto Track position
		url="http://${host}/cgi-bin/ptz.cgi?action=start&channel=0&code=GotoPreset&arg1=0&arg2=10&arg3=0"
		#echo "Preset ${url}"
		curl --digest -n -s -g -m 1 -- "${url}"
		# Also set channel 9 (=10-1) as auto-homing position
		url="http://${host}/cgi-bin/configManager.cgi?action=setConfig&Ptz[0].Homing[0]=9&Ptz[0].Homing[1]=${timeout}"
		curl --digest -n -s -g -m 1 -- "${url}"
	fi
fi


echo $macro

exit 0

