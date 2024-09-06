#!/bin/bash

# current user check
currentUser=$(stat -f "%Su" /dev/console)
# Is Jamf Connect still the active login window?
loginwindow_check=$(security authorizationdb read system.login.console | grep 'loginwindow:login' 2>&1 > /dev/null; echo $?)

if [ $loginwindow_check == 0 ]; then
	# Mac has reverted to macOS login screen, needs fixing.
	echo "macOS Login Screen, resetting authdb"
	/usr/local/bin/authchanger -reset -JamfConnect
	# If someone is logged in, exit.
	if [[ $currentUser != root ]]; then
		echo "A user is logged in, exiting without reboot."
		exit 0
	else
	# If nobody is logged in, reboot.
		echo "No user is logged in, rebooting"
		shutdown -r now
	fi
else
	# Mac is still using Jamf Connect, nothing to do here.
	echo "Jamf Connect Login Screen, exiting."
	exit 0
fi