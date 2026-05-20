#!/bin/zsh --no-rcs

# Written by Thom Martin for The University of Arizona May 07, 2026.
# You will need an API Role configured on your Jamf server with "Read Smart Computer Groups" and "Read Mac Applications" privileges, as well as an API Client with that Role assigned to it.
# Edit lines 23, 24, and 25 with your org's client id, client secret, and Jamf Pro URL.
# Optionally, edit line 43 if you would like the report to go somewhere other than your Desktop folder.
# You will also need jq installed on the Mac running this script for working with JSON. https://jqlang.org/
# The /api/v1/app-installers/ endpoints are currently undocumented. There is currently no endpoint to toggle an App Installer off and back on to force a deployment recacluation, but this script will generate a report of titles which may need that done by hand.
# Credit where credit is due, super thanks to Jordy Thery and Neil Martin over on the Mac Admins Slack. I also got a lot of help sorting the App Installers endpoints from https://github.com/tyler-tee/JNUC-2023

# Check whether jq is installed.
if [[ ! -f /usr/bin/jq ]]; then
	# If jq is not found, notify that is needed and exit the script.
	echo "This script requires jq on this Mac. https://jqlang.org/ \nExiting."
	exit
else
	# If jq is found, proceed.
	echo "jq found, proceeding."
	
	##############################
	##### This Pulls a token #####
	##############################
	client_id="" 
	client_secret=""
	url="https://YOURJAMFSERVER.jamfcloud.com"
	##This output has multiple values, use plutil to extract the token
	getAccessToken() {
		response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
			--header "Content-Type: application/x-www-form-urlencoded" \
			--data-urlencode "client_id=${client_id}" \
			--data-urlencode "grant_type=client_credentials" \
			--data-urlencode "client_secret=${client_secret}")
		access_token=$(echo "$response" | plutil -extract access_token raw -)
		token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
		token_expiration_epoch=$(($current_epoch + $token_expires_in - 1))
	}
	getAccessToken 
	##############################
	##############################
	##############################
	
	# Directory to output report file to.
	reportPath=~/Desktop/
	
	# Get all currently deployed App Installer titles.
	allJamfApps=$(curl -X GET "$url/api/v1/app-installers/deployments" -H "accept: application/json" -H "Authorization: Bearer $access_token" | jq -c '.results[]')
	
	# Bring App Installer titles into a bash array.
	apps=()
	while read -r value; do 
		apps+=("$value")
	done < <(echo $allJamfApps)
	
	## Print the bash array - helpful to confirm things are working.
	#echo ${apps[@]}
	
	# Iterate over the bash array to do the things.
	for app in "${apps[@]}"; do 
		# Get the ID of the Jamf App Installer and remove surrounding quotes
		appID=$(jq -c '.id' <<< "${app}" | tr -d \")
		# Get the name of the Jamf App Installer
		appName=$(jq -c '.name' <<< "${app}")
		# Get the ID of the Smart Group the App Installer is scoped to and remove surrounding quotes
		smartGroupID=$(jq -c '.smartGroup.id' <<< "${app}" | tr -d \")
		# Get the Name of the Smart Group the App Installer is scoped to and remove surrounding quotes
		smartGroupName=$(jq -c '.smartGroup.name' <<< "${app}" | tr -d \")
		# Get the number of Macs in the Smart Group
		smartGroupCount=$(curl -X GET "$url/api/v2/computer-groups/smart-group-membership/$smartGroupID" -H "accept: application/json" -H "Authorization: Bearer $access_token" | jq '.members | length')
		# Calculate the number of Macs that Jamf thinks the App Installer should be scoped to
		deploySum=$(jq '.computerStatuses.installed + .computerStatuses.available + .computerStatuses.inProgress + .computerStatuses.failed + .computerStatuses.unqualified' <<< "${app}")	
#		# Test population of variables for each array item
#		echo "AppID: ${appID}"
#		echo "AppName: ${appName}"
#		echo "SmartGroupID: ${smartGroupID}"
#		echo "SmartGroupName: ${smartGroupName}"
#		echo "SmartGroupCount : ${smartGroupCount}"
#		echo "DeploymentCount: ${deploySum}"
#		echo
		if [[ "$smartGroupCount" != "$deploySum" ]]; then
			# If the number of Macs in the Smart Group is different than the number of Macs Jamf thinks the App Installer is deployed to, write it to a file for human evaluation and remediation.
			echo "${appName} is not recalculating its deployment scope. \n Toggle the app Installer off and back on to force it to recalculate. \n This may indicate a scoping conflict if it continues to occur. \n App URL: ${url}/view/computers/mac-apps/app-installers/deployments/${appID} \n App ID: ${appID} \n Deployment Count: ${deploySum} \n Smart Group: ${smartGroupName} \n Smart Group ID: ${smartGroupID} \n Smart Group Count: ${smartGroupCount} \n" >> "$reportPath"JamfAppConflicts.txt
		fi
	done
	# Check if report file exists.
	if [[ -f "$reportPath"JamfAppConflicts.txt ]]; then
		# If it exists, say so and open it.
		echo "Some App Installers may not be recalculating correctly. Opening report."
		open "$reportPath"JamfAppConflicts.txt
	else
		# If it does not exist, say so and exit.
		echo "All App Installers appear to be recalculating correctly. Exiting."
		exit 
	fi
fi
