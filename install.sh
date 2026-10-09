#!/usr/bin/env bash
# Install the Daedric Morrowind Plasma splash for the current user.  ./install.sh [--apply]
set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DST=${XDG_DATA_HOME:-$HOME/.local/share}/plasma/look-and-feel/scorn.daedricmorrowind
mkdir -p "$DST"
cp -r "$HERE/metadata.json" "$HERE/contents" "$DST"/
echo "Installed to $DST"
if [[ ${1:-} == --apply ]]; then
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme scorn.daedricmorrowind
    echo "Selected. It shows at next login."
else
    echo "Select it in System Settings > Colors & Themes > Splash Screen, or rerun with --apply."
fi
