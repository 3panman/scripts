#!/bin/bash

# Replace "AnyOrg" with your org identifier
daemonPath="/Library/LaunchDaemons/com.AnyOrg.dscleanup"

# Filter installed LLMs for deepseek and report version(s)
DeepSeekVersion=$(/usr/local/bin/ollama list | grep deepseek | awk '{print $1}')

# Remove detected DeepSeek versions and update Jamf inventory
ollama rm $DeepSeekVersion

# Boot-out and delete DeepSeek removal LaunchDaemon if it exists
if [[ -f "$daemonPath".plist ]]; then
	sudo launchctl bootout system "$daemonPath".plist
	rm -f "$daemonPath".plist
fi

echo "DeepSeek removed. Updating Jamf inventory."

# Update inventory
/usr/local/bin/jamf recon
