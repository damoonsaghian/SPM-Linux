# https://pipewire.org/
# https://wiki.alpinelinux.org/wiki/PipeWire
# https://docs.voidlinux.org/config/media/pipewire.html
# https://wiki.archlinux.org/title/PipeWire

# don't build alsa, jack, v4l plugins

# gst-plugin

mkdir -p etc/wireplumber/main.lua.d
echo 'device_defaults.properties = {
	["default-volume"] = 1.0,
	["default-input-volume"] = 1.0,
}' > etc/wireplumber/main.lua.d/51-default-volume.lua
