#!/bin/bash

# Replace "AnyOrg" with your org identifier
daemonPath="/Library/LaunchDaemons/com.AnyOrg.dscleanup"

if [[ -f "$daemonPath" ]]; then
	echo "Daemon already present"
	exit
else
	cat > "$daemonPath" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
		<dict>
				<key>Label</key>
				<string>com.AnyOrg.dscleanup</string>
				<key>ProgramArguments</key>
				<array>
						<string>sh</string>
						<string>-c</string>
						<string>/usr/local/bin/jamf policy -event KillDeepSeek</string>
				</array>
				<key>StartInterval</key>
				<integer>259200</integer>
		</dict>
</plist>
EOF

	/bin/chmod 644 "$daemonPath".plist
	/usr/sbin/chown root:wheel "$daemonPath".plist
	sudo /bin/launchctl bootstrap system "$daemonPath".plist
fi
