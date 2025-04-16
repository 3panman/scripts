#!/bin/bash

daemonPath="/Library/LaunchDaemons/com.AnyOrg.dscleanup.plist"

# Filter installed LLMs for deepseek and report version(s)
DeepSeekVersion=$(/usr/local/bin/ollama list | grep deepseek | awk '{print $1}')

# Remove detected DeepSeek versions and update Jamf inventory
ollama rm $DeepSeekVersion

# Boot-out and delete DeepSeek removal LaunchDaemon if it exists
if [[ -f "$daemonPath" ]]; then
	sudo launchctl bootout system "$daemonPath"
	rm -f "$daemonPath"
fi

echo "DeepSeek removed. Updating Jamf inventory."

# Update inventory
/usr/local/bin/jamf recon