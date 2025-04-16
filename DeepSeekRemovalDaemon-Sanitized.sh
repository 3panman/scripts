#!/bin/bash

daemonPath="/Library/LaunchDaemons/com.AnyOrg.dscleanup.plist"

if [[ -f "$daemonPath" ]]; then
	sudo launchctl bootout system "$daemonPath"
	rm -f "$daemonPath"
fi

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

/bin/chmod 644 "$daemonPath"
/usr/sbin/chown root:wheel "$daemonPath"
sudo /bin/launchctl bootstrap system "$daemonPath"