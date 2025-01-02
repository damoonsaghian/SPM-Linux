project_dir="$(dirname "$0")"

# https://gitlab.freedesktop.org/gstreamer/gstreamer
# gst-plugins-base: don't provide xlib
# gst-plugins-good: don't provide xlib gtk3 libsoup3
# gst-plugins-ugly: don't provide sidplay
# gst-plugins-bad: av1(aom-libs), h264(openh264), h265(libde265), and aac(faad2)
# 	don't provide xlib gtk3 directfb dc1394 libopenni openssl curl libneon microdns
# 	bluez libfreeaptx liblc3 libsbc libldacbt
# 	fdk-aac vo-aacenc vo-amrwbenc sndfile soundtouch spandsp libwildmidi2 libzxing2

# https://gitlab.freedesktop.org/pipewire/pipewire
# https://wiki.alpinelinux.org/wiki/PipeWire
# https://docs.voidlinux.org/config/media/pipewire.html
# https://wiki.archlinux.org/title/PipeWire
# gst-plugin-pipewire
mkdir -p etc/wireplumber/main.lua.d
echo 'device_defaults.properties = {
	["default-volume"] = 1.0,
	["default-input-volume"] = 1.0,
}' > etc/wireplumber/main.lua.d/51-default-volume.lua
