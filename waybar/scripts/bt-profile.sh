#!/bin/bash
# Shows the active Bluetooth audio profile for the connected headset

card=$(pactl list cards short 2>/dev/null | grep bluez | head -1 | awk '{print $2}')

if [ -z "$card" ]; then
    echo '{"text": "", "class": "disconnected"}'
    exit 0
fi

profile=$(pactl list cards 2>/dev/null | grep -A 30 "$card" | grep "Active Profile:" | sed 's/.*Active Profile: //')

case "$profile" in
    a2dp-sink-aptx)
        echo "{\"text\": \"aptX\", \"tooltip\": \"Bluetooth: aptX (high quality)\", \"class\": \"a2dp\"}"
        ;;
    a2dp-sink-aptx_hd)
        echo "{\"text\": \"aptX HD\", \"tooltip\": \"Bluetooth: aptX HD (high quality)\", \"class\": \"a2dp\"}"
        ;;
    a2dp-sink)
        echo "{\"text\": \"LDAC\", \"tooltip\": \"Bluetooth: LDAC (high quality)\", \"class\": \"a2dp\"}"
        ;;
    a2dp-sink-aac)
        echo "{\"text\": \"AAC\", \"tooltip\": \"Bluetooth: AAC (high quality)\", \"class\": \"a2dp\"}"
        ;;
    a2dp-sink-sbc)
        echo "{\"text\": \"SBC\", \"tooltip\": \"Bluetooth: SBC (standard quality)\", \"class\": \"a2dp\"}"
        ;;
    a2dp-sink-sbc_xq)
        echo "{\"text\": \"SBC-XQ\", \"tooltip\": \"Bluetooth: SBC-XQ (high quality)\", \"class\": \"a2dp\"}"
        ;;
    headset-head-unit)
        echo "{\"text\": \"HFP\", \"tooltip\": \"Bluetooth: Handsfree (mic active, low quality)\", \"class\": \"hfp\"}"
        ;;
    headset-head-unit-cvsd)
        echo "{\"text\": \"HFP\", \"tooltip\": \"Bluetooth: Handsfree CVSD (mic active, low quality)\", \"class\": \"hfp\"}"
        ;;
    off)
        echo '{"text": "", "class": "disconnected"}'
        ;;
    *)
        echo "{\"text\": \"$profile\", \"tooltip\": \"Bluetooth: $profile\", \"class\": \"unknown\"}"
        ;;
esac
