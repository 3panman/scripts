#!/bin/sh

# Written by Thom Martin for the College of Social & Behavioral Sciences at the University of Arizona.

#########################################
########### SETTING VARIABLES ###########
#########################################

# EDIT THESE ITEMS TO CUSTOMIZE YOUR ALERTS
# Notification window title
title="Patches Available"
# Path for icon to display in alerts
alertIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns"
# Initial Alert message. Carriage returns within the quotation marks will translate to carriage returns in the message.
PatchAlert="Updates are available for one or more Apps on this Mac.  Please install them from the Notifications section of Self Service at your earliest convenience.

If updates are not installed by their deadline they will install automatically, forcing the app to quit if it happens to be running at the time.

This alert will appear daily until all Apps are updated.

Thank you!"
# Patch Declined message.  Carriage returns within the quotation marks will translate to carriage returns in the message.
PatchDeclined="We understand this may not be a good time.

This reminder will reappear in roughly 24 hours if all patches are not installed by then.

Thank you!"

# DO NOT EDIT BELOW THIS POINT WITHOUT TESTING FIRST

# Get current console user for launching Self Service
consoleuser=`ls -l /dev/console | cut -d " " -f4`
# JamfHelper shortcut
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# current user check
currentUser=$(stat -f "%Su" /dev/console)

#########################################
################ SCRIPT #################
#########################################

# If current user is NOT root, run the JamfHelper patch notification.
if [[ currentUser != root ]]; then
  buttonResponse=$("$jamfHelper" -windowType utility -title "$title" -description "$PatchAlert" -icon "$alertIcon" -button1 "Self Service" -button2 "Not now" -defaultButton "1" -cancelButton "2" -timeout "3600")
# If user clicks Self Service, open Self Service to the Notifications tab.
  if [[ "$buttonResponse" == 0 ]]; then
    su - "${consoleuser}" -c 'open "jamfselfservice://content?action=notifications"'
# If user clicks "Not Now" display "We understand" notification.
	else
		"$jamfHelper" -windowType utility -title "$title" -description "$PatchDeclined" -icon "$alertIcon" -button1 "OK"
  fi
# If current user IS root, write "No user currently logged in." to the log.
else echo "No user currently logged in."
fi




