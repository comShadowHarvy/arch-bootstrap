#!/bin/bash

# This script downloads and executes the NonSteamLaunchers.sh script
# to configure launchers or shortcuts for newly installed applications.

curl -Ls https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh | nohup /bin/bash
