#!/system/bin/sh
# Keep Mooninesria passive at boot. Runtime choices are made from the WebUI.
MODDIR=${0%/*}
chmod 0755 "$MODDIR/tools/lucreticus/measure_governor.sh" "$MODDIR/tools/lucreticus/ctl.sh" 2>/dev/null || true
