gst-plugin-pipewire
gst-plugins-good # mp4/matroska/webm containers, plus mp3 and vpx
gst-plugins-ugly
gst-plugins-bad # av1(aom-libs), h264(openh264), h265(libde265), and aac(fdk-aac)

# https://pipewire.org/
# https://wiki.alpinelinux.org/wiki/PipeWire
# https://docs.voidlinux.org/config/media/pipewire.html
# https://wiki.archlinux.org/title/PipeWire
# don't build alsa and jack plugins
# gst-plugin
mkdir -p etc/wireplumber/main.lua.d
echo 'device_defaults.properties = {
	["default-volume"] = 1.0,
	["default-input-volume"] = 1.0,
}' > etc/wireplumber/main.lua.d/51-default-volume.lua
