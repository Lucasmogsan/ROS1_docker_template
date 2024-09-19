#!/bin/bash

# 1. Create the udev rules file
RULES_FILE="/etc/udev/rules.d/99-usb-custom.rules"

if [ -f "$RULES_FILE" ]; then
    echo "File $RULES_FILE already exists."
else
    echo 'SUBSYSTEM=="usb", MODE="0666", GROUP="plugdev"' | sudo tee "$RULES_FILE" > /dev/null
    echo "Created $RULES_FILE with custom USB rules."
fi

# 2. Reload the udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# 3. Verify permissions
echo "Verifying USB device permissions for bus 004..."
ls -la /dev/bus/usb/004

echo "Script completed."
