#!/bin/bash

# 1. Check for root/sudo and re-run with pkexec if necessary
if [ "$EUID" -ne 0 ]; then
    echo "Requesting privileges to install system-wide script..."
    pkexec "$0" "$@"
    exit
fi

# Paths
SCRIPT_PATH="/usr/local/bin/toggle_sleep.sh"
RULE_PATH="/etc/udev/rules.d/99-powertoggle.rules"

echo "Installing power management logic..."

# 2. Create the toggle script
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash
# Check AC status
AC_STATUS=$(cat /sys/class/power_supply/AC/online)

if [ "$AC_STATUS" -eq 1 ]; then
    # PLUGGED IN
    powerprofilesctl set performance
    systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    brightnessctl set 100%
    notify-send -i power-transmit-symbolic "Power Mode" "AC: Performance & No Sleep"
else
    # ON BATTERY
    powerprofilesctl set balanced
    systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
    brightnessctl set 30%
    notify-send -i battery-low-symbolic "Power Mode" "Battery: Balanced & Sleep Enabled"
fi
EOF

# 3. Set permissions and ownership
chmod +x $SCRIPT_PATH
chown root:root $SCRIPT_PATH

# 4. Create udev rule
echo 'SUBSYSTEM=="power_supply", ACTION=="change", RUN+="/usr/local/bin/toggle_sleep.sh"' > $RULE_PATH

# 5. Reload system rules
udevadm control --reload-rules
udevadm trigger

echo "Success! Logic installed and triggered."