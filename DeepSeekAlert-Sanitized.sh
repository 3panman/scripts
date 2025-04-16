#!/bin/bash

# Alert user and log response
buttonReturned=$(osascript -e 'button returned of (display dialog "Deepseek has been detected on this Mac.

Deepseek is not permitted on AnyOrg computers. Please remove it as soon as possible." buttons {"Do it for me", "Do it myself", "No"} default button "Do it for me" with icon stop)')

if [[ $buttonReturned == "Do it for me" ]]; then
	# User chose "Do it for me". Run Jamf policy to remove DeepSeek and update inventory.
	echo "Do it for me"
	/usr/local/bin/jamf policy -event KillDeepSeek
	osascript -e 'display dialog "DeepSeek has been removed. Thank you." buttons {"OK"} default button "OK"'
elif [[ $buttonReturned == "Do it myself" ]]; then
	# User chose "Do it myself". Advise them to update inventory after removing deepseek.
	echo "Do it myself"
	osascript -e 'display dialog "After removing DeepSeek, please run Update Inventory in the Self Service app.

Thank you for your cooperation." buttons{"OK"} with icon caution'
	# Create a launchDaemon to trigger the DeepSeek removal policy in three days in case the user hasn't done it yet.
	/usr/local/bin/jamf policy -event KillDeepSeekDaemon
elif [[ $buttonReturned == "No" ]]; then
	# User chose "No". Advise them to contact Tim Scwhab for exemption and that we'll auto-kill deepseek if they dawdle.
	echo "No"
	osascript -e 'display dialog "If you require DeepSeek for your work, please contact AnyOrg Security Personnel as soon as possible to discuss an exemption.

If no action is taken, DeepSeek will be automatically removed from this Mac in three days." buttons {"OK"} with icon stop'
	# Create a launchDaemon which will auto-trigger the DeepSeek removal policy in three days if the user hasn't done it yet.
	/usr/local/bin/jamf policy -event KillDeepSeekDaemon
else
	# Script ran at login screen or something broke...
	echo "Something has gone terribly wrong."
fi